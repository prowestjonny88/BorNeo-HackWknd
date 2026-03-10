import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/repository_providers.dart';
import '../../services/ocr/screenshot_parser.dart';
import '../../services/reconciliation/confidence_rules.dart';
import '../../services/reconciliation/reconciliation_engine.dart';
import '../auth/session_provider.dart';
import '../cash_entry/cash_entry_provider.dart';
import '../evidence/evidence_provider.dart';
import '../memory/history_provider.dart';
import '../review/recap_draft_provider.dart';
import '../review/recap_review_provider.dart';
import '../selling/selling_provider.dart';
import '../voice_recap/voice_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/confidence_badge.dart';
import '../../shared/widgets/progress_stepper.dart';
import '../../shared/widgets/reconciliation_summary_widget.dart';

class DailyLedgerScreen extends ConsumerWidget {
  const DailyLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellingState = ref.watch(sellingProvider);
    final cashState = ref.watch(cashEntryProvider);
    final evidenceState = ref.watch(evidenceProvider);
    final voiceState = ref.watch(voiceProvider);
    final reconciliationEngine = ref.watch(reconciliationEngineProvider);
    final textTheme = Theme.of(context).textTheme;

    final screenshotInputs = <ParsedScreenshot>[];
    final exportTotals = <double>[];
    for (final file in evidenceState.files) {
      final result = evidenceState.resultById[file.id];
      if (result == null || result.amounts.isEmpty) continue;

      if (file.source == EvidenceSource.export) {
        exportTotals.addAll(result.amounts.map((e) => e.amount));
        continue;
      }

      screenshotInputs.add(
        ParsedScreenshot(
          amounts: result.amounts
              .map(
                (amount) => ParsedPaymentAmount(
                  amount: amount.amount,
                  confidence: amount.confidence,
                  trustLabel: amount.trustLabel,
                ),
              )
              .toList(growable: false),
          rawText: result.amounts.map((e) => e.trustLabel).join(' | '),
        ),
      );
    }

    final reconciliation = reconciliationEngine.synthesize(
      ReconciliationInput(
        ocrScreenshots: screenshotInputs,
        exportTotals: exportTotals,
        countedCash: cashState.amount,
        cashTypedByMerchant: cashState.isConfirmed,
        parsedRecap: voiceState.parsedRecap,
        tapCountsByItemId: sellingState.countsByMenuItemId,
      ),
    );

    final evidenceDigitalTotal = evidenceState.resultById.values
        .expand((result) => result.amounts)
        .fold<double>(0, (sum, amount) => sum + amount.amount);

    final digitalTotal = evidenceDigitalTotal > 0
        ? evidenceDigitalTotal
        : reconciliation.digitalTotal;
    final cashTotal = reconciliation.countedCash;
    final tappedItems = sellingState.menuItems
        .where((item) => (sellingState.countsByMenuItemId[item.id] ?? 0) > 0)
        .toList(growable: false);
    final estimatedItems = sellingState.totalTaps;
    final estimatedItemValue = sellingState.estimatedTotal;
    final totalSales = digitalTotal + cashTotal;

    return Scaffold(
      body: Container(
        color: AppTheme.deepForest,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const ProgressStepper(currentStep: 4, completedStepCount: 4),
                    const SizedBox(height: 16),
                    Text('Today\'s Ledger', style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite)),
                    const SizedBox(height: 4),
                    Text(
                      _formattedToday(),
                      style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: 20),
                    ReconciliationSummaryWidget(
                      totalSales: 'RM ${totalSales.toStringAsFixed(2)}',
                      digitalTotal: 'RM ${digitalTotal.toStringAsFixed(2)}',
                      cash: 'RM ${cashTotal.toStringAsFixed(2)}',
                      estimatedItems: '$estimatedItems',
                    ),
                    if (estimatedItemValue > 0) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Estimated item value: RM ${estimatedItemValue.toStringAsFixed(2)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.softWhite.withValues(alpha: 0.72),
                        ),
                      ),
                      if ((estimatedItemValue - totalSales).abs() > 0.01)
                        Text(
                          'Note: This estimate is not added into total sales unless confirmed as cash/digital evidence.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppTheme.amber,
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    Text('BUILT FROM', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (evidenceState.files.isNotEmpty) ...[
                            _SourceChip(
                              label: '${evidenceState.files.length} Screenshot${evidenceState.files.length > 1 ? 's' : ''}',
                              icon: Icons.photo_camera_outlined,
                              active: reconciliation.evidenceSources.contains('From screenshot'),
                            ),
                            const SizedBox(width: 8),
                          ],
                          _SourceChip(
                            label: 'Voice Recap',
                            icon: Icons.mic_none_rounded,
                            active: reconciliation.evidenceSources.contains('From voice recap'),
                          ),
                          const SizedBox(width: 8),
                          _SourceChip(
                            label: cashState.isConfirmed ? 'Cash Confirmed' : 'Cash Entry',
                            icon: Icons.payments_outlined,
                            active: reconciliation.cashConfidence == ReconciliationConfidence.merchantConfirmed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('ESTIMATED ITEMS SOLD', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                    const SizedBox(height: 12),
                    if (tappedItems.isEmpty)
                      Text(
                        'No item-level sales were captured for this recap yet.',
                        style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.72)),
                      )
                    else
                      ...tappedItems.map(
                        (item) {
                          final qty = sellingState.countsByMenuItemId[item.id] ?? 0;
                          return _LedgerRow(
                            name: item.name,
                            qty: '$qty',
                            subtotal: 'RM ${(item.price * qty).toStringAsFixed(2)}',
                            badge: _badgeFromReconciliationConfidence(reconciliation.cashConfidence),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: const Border(left: BorderSide(color: AppTheme.amber, width: 4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fields marked "Estimated" are based on your voice recap. Tap any field to correct it.',
                            style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite),
                          ),
                          if ((estimatedItemValue - totalSales).abs() > 0.01) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Current total uses confirmed digital + confirmed cash only.',
                              style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.85)),
                            ),
                          ],
                          if (reconciliation.uncertaintyNotes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            for (final note in reconciliation.uncertaintyNotes.take(3))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '- $note',
                                  style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.85)),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        onPressed: () => context.go('/review'),
                        child: const Text('Edit any field'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                color: AppTheme.deepForest,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        final accountId = ref.read(sessionProvider).accountKey;

                        await ref.read(ledgerRepositoryProvider).upsertLedger({
                          'id': const Uuid().v4(),
                          'date': DateTime.now().toIso8601String().split('T').first,
                          'totalSales': totalSales,
                          'digitalTotal': digitalTotal,
                          'cashEstimate': cashTotal,
                          'unresolvedCount': evidenceState.statusById.values.where((status) => status == EvidenceProcessingStatus.error).length,
                          'isConfirmed': 1,
                        }, accountId: accountId);

                        // Reset all day-session providers so every page starts fresh
                        ref.read(sellingProvider.notifier).resetAll();
                        ref.read(cashEntryProvider.notifier).reset();
                        ref.read(voiceProvider.notifier).reset();
                        ref.read(evidenceProvider.notifier).reset();
                        ref.read(recapDraftProvider.notifier).resetTranscript();
                        ref.read(recapReviewProvider.notifier).reset();

                        // Refresh memory timeline so the new entry appears immediately
                        await ref.read(historyProvider.notifier).refresh();

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(const SnackBar(content: Text('Ledger saved to memory.')));
                        context.go('/memory');
                      },
                      child: const Text('Confirm & Save to Memory'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This day will be saved to your business memory timeline.',
                      style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedToday() {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label, required this.icon, this.active = false});

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.jade : AppTheme.softWhite;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.jade.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? AppTheme.jade.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.name, required this.qty, required this.subtotal, required this.badge});

  final String name;
  final String qty;
  final String subtotal;
  final ConfidenceBadgeType badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.softWhite, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ConfidenceBadge(type: badge),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(qty, style: AppTheme.mono(size: 16, color: AppTheme.softWhite)),
          ),
          Text(subtotal, style: AppTheme.mono(size: 16, color: AppTheme.amber)),
        ],
      ),
    );
  }
}

ConfidenceBadgeType _badgeFromReconciliationConfidence(ReconciliationConfidence confidence) {
  switch (confidence) {
    case ReconciliationConfidence.high:
      return ConfidenceBadgeType.screenshot;
    case ReconciliationConfidence.medium:
      return ConfidenceBadgeType.voice;
    case ReconciliationConfidence.low:
      return ConfidenceBadgeType.estimated;
    case ReconciliationConfidence.merchantConfirmed:
      return ConfidenceBadgeType.confirmed;
    case ReconciliationConfidence.needsReview:
      return ConfidenceBadgeType.needsReview;
  }
}