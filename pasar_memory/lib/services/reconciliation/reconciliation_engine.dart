import '../ocr/screenshot_parser.dart';
import '../../services/recap_parser/menu_aware_parser.dart';
import 'confidence_rules.dart';

class ReconciliationItemEstimate {
  const ReconciliationItemEstimate({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.source,
    required this.confidence,
  });

  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final String source;
  final ReconciliationConfidence confidence;
}

class ReconciliationInput {
  const ReconciliationInput({
    required this.ocrScreenshots,
    this.exportTotals = const <double>[],
    this.countedCash,
    this.cashTypedByMerchant = false,
    this.parsedRecap,
    this.tapCountsByItemId = const <String, int>{},
  });

  final List<ParsedScreenshot> ocrScreenshots;
  final List<double> exportTotals;
  final double? countedCash;
  final bool cashTypedByMerchant;
  final ParsedRecap? parsedRecap;
  final Map<String, int> tapCountsByItemId;
}

class ReconciliationResult {
  const ReconciliationResult({
    required this.digitalTotal,
    required this.countedCash,
    required this.grossTotal,
    required this.itemEstimates,
    required this.evidenceSources,
    required this.uncertaintyNotes,
    required this.digitalConfidence,
    required this.cashConfidence,
  });

  final double digitalTotal;
  final double countedCash;
  final double grossTotal;
  final List<ReconciliationItemEstimate> itemEstimates;
  final List<String> evidenceSources;
  final List<String> uncertaintyNotes;
  final ReconciliationConfidence digitalConfidence;
  final ReconciliationConfidence cashConfidence;
}

class ReconciliationEngine {
  ReconciliationEngine({ConfidenceRules? confidenceRules})
      : _confidenceRules = confidenceRules ?? const ConfidenceRules();

  final ConfidenceRules _confidenceRules;

  ReconciliationResult synthesize(ReconciliationInput input) {
    final uncertaintyNotes = <String>[];

    final digitalCandidates = <double>[];
    var hasHistoryStyle = false;
    var hasSettlementStyle = false;
    var sourceConfidence = 0.0;

    for (final screenshot in input.ocrScreenshots) {
      final amounts = screenshot.amounts;
      if (amounts.isNotEmpty) {
        final contextAmounts = amounts
            .where((a) => a.trustLabel.toLowerCase().contains('context amount'))
            .toList(growable: false);

        if (contextAmounts.isNotEmpty) {
          // If parser found a likely explicit total, use the strongest explicit total.
          final explicitTotal = contextAmounts
              .map((a) => a.amount)
              .reduce((a, b) => a > b ? a : b);
          digitalCandidates.add(explicitTotal);
        } else if (amounts.length == 1) {
          digitalCandidates.add(amounts.first.amount);
        } else {
          // History-style screenshot: sum extracted rows and mark as lower certainty.
          digitalCandidates.addAll(amounts.map((a) => a.amount));
          uncertaintyNotes.add('History screenshot values were summed; please review for duplicates.');
        }

        for (final amount in amounts) {
          sourceConfidence = sourceConfidence > amount.confidence
              ? sourceConfidence
              : amount.confidence;
        }
      }

      if (amounts.length > 1) {
        hasHistoryStyle = true;
      }
      if (screenshot.rawText.toLowerCase().contains('settlement')) {
        hasSettlementStyle = true;
      }

      uncertaintyNotes.addAll(screenshot.notes);
    }

    for (final value in input.exportTotals) {
      if (value > 0) {
        digitalCandidates.add(value);
      }
    }

    final dedupedDigital = _dedupeRounded(digitalCandidates);
    final digitalTotal = dedupedDigital.fold<double>(0, (sum, amount) => sum + amount);

    if (dedupedDigital.length > 1) {
      uncertaintyNotes.add('Multiple digital totals were combined. Please verify duplicates.');
    }

    final recapCash = input.parsedRecap?.cashMention?.amount;
    final countedCash = input.countedCash ?? recapCash ?? 0;
    if (input.countedCash == null && recapCash != null) {
      uncertaintyNotes.add('Cash value came from voice recap and should be confirmed.');
    }
    if (input.countedCash == null && recapCash == null) {
      uncertaintyNotes.add('Cash not entered yet. Gross total is incomplete.');
    }

    final itemEstimates = _buildItemEstimates(input);
    final grossTotal = digitalTotal + countedCash;

    final evidenceSources = <String>[];
    if (input.ocrScreenshots.isNotEmpty) {
      evidenceSources.add('From screenshot');
    }
    if (input.exportTotals.isNotEmpty) {
      evidenceSources.add('From export');
    }
    if (input.parsedRecap != null) {
      evidenceSources.add('From voice recap');
    }
    if (input.countedCash != null) {
      evidenceSources.add('Confirmed by merchant');
    }
    if (input.tapCountsByItemId.isNotEmpty) {
      evidenceSources.add('From live taps');
    }

    final digitalConfidence = _confidenceRules.forDigitalAmount(
      sourceConfidence: sourceConfidence,
      fromSettlementStyle: hasSettlementStyle,
      fromHistoryStyle: hasHistoryStyle,
    );

    final cashConfidence = _confidenceRules.forCash(
      typedByMerchant: input.cashTypedByMerchant,
      fromVoice: recapCash != null,
    );

    return ReconciliationResult(
      digitalTotal: digitalTotal,
      countedCash: countedCash,
      grossTotal: grossTotal,
      itemEstimates: itemEstimates,
      evidenceSources: evidenceSources,
      uncertaintyNotes: uncertaintyNotes.toSet().toList(growable: false),
      digitalConfidence: digitalConfidence,
      cashConfidence: cashConfidence,
    );
  }

  List<ReconciliationItemEstimate> _buildItemEstimates(ReconciliationInput input) {
    final fromRecap = <String, ReconciliationItemEstimate>{};
    final recapItems = input.parsedRecap?.items ?? const <ParsedItemMention>[];

    for (final item in recapItems) {
      fromRecap[item.menuItemId] = ReconciliationItemEstimate(
        menuItemId: item.menuItemId,
        menuItemName: item.menuItemName,
        quantity: item.quantity,
        source: 'voice_recap',
        confidence: _confidenceRules.forItemCount(
          fromTap: false,
          isApproximate: item.isApproximate,
        ),
      );
    }

    for (final entry in input.tapCountsByItemId.entries) {
      final existing = fromRecap[entry.key];
      if (existing == null) {
        fromRecap[entry.key] = ReconciliationItemEstimate(
          menuItemId: entry.key,
          menuItemName: entry.key,
          quantity: entry.value,
          source: 'live_tap',
          confidence: _confidenceRules.forItemCount(fromTap: true, isApproximate: false),
        );
      } else {
        // Prefer higher observed quantity between recap and tap as a simple enrichment strategy.
        fromRecap[entry.key] = ReconciliationItemEstimate(
          menuItemId: existing.menuItemId,
          menuItemName: existing.menuItemName,
          quantity: entry.value > existing.quantity ? entry.value : existing.quantity,
          source: 'voice_recap+live_tap',
          confidence: _confidenceRules.forItemCount(fromTap: true, isApproximate: false),
        );
      }
    }

    return fromRecap.values.toList(growable: false);
  }

  List<double> _dedupeRounded(List<double> values) {
    final seen = <String>{};
    final out = <double>[];
    for (final value in values) {
      final key = value.toStringAsFixed(2);
      if (seen.add(key)) {
        out.add(double.parse(key));
      }
    }
    return out;
  }
}
