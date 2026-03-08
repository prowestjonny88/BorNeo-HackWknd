import '../../models/menu_item.dart';

/// Confidence level for parsed fields
enum ParsedFieldConfidence {
  /// High confidence - exact match or explicit number
  high,
  /// Medium confidence - fuzzy match or approximate number
  medium,
  /// Low confidence - uncertain match or guessed quantity
  low,
}

/// Represents an item mentioned in the recap
class ParsedItemMention {
  const ParsedItemMention({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.confidence,
    this.rawMention,
    this.isApproximate = false,
    this.isSoldOut = false,
  });

  /// Matched menu item ID
  final String menuItemId;

  /// Menu item name for display
  final String menuItemName;

  /// Detected quantity
  final int quantity;

  /// Confidence level
  final ParsedFieldConfidence confidence;

  /// Raw text that was matched
  final String? rawMention;

  /// Whether quantity was approximate (e.g., "about 30", "dalam 30")
  final bool isApproximate;

  /// Whether item was mentioned as sold out
  final bool isSoldOut;

  Map<String, dynamic> toJson() => {
    'menuItemId': menuItemId,
    'menuItemName': menuItemName,
    'quantity': quantity,
    'confidence': confidence.name,
    'rawMention': rawMention,
    'isApproximate': isApproximate,
    'isSoldOut': isSoldOut,
  };
}

/// Detected cash mention from recap
class ParsedCashMention {
  const ParsedCashMention({
    required this.amount,
    required this.confidence,
    this.rawMention,
    this.isApproximate = false,
  });

  /// Detected cash amount
  final double amount;

  /// Confidence level
  final ParsedFieldConfidence confidence;

  /// Raw text that contained cash mention
  final String? rawMention;

  /// Whether the amount was approximate
  final bool isApproximate;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'confidence': confidence.name,
    'rawMention': rawMention,
    'isApproximate': isApproximate,
  };
}

/// Result of parsing a voice recap transcript
class ParsedRecap {
  const ParsedRecap({
    required this.items,
    this.cashMention,
    this.soldOutItems = const [],
    this.paymentModeHint,
    this.notes,
    this.rawTranscript = '',
    this.overallConfidence = ParsedFieldConfidence.medium,
  });

  /// Detected item mentions with quantities
  final List<ParsedItemMention> items;

  /// Detected cash amount if mentioned
  final ParsedCashMention? cashMention;

  /// Items explicitly mentioned as sold out
  final List<String> soldOutItems;

  /// Hint about payment mode ("mostly cash", "mostly QR", "mixed")
  final String? paymentModeHint;

  /// Additional notes extracted
  final String? notes;

  /// Original transcript
  final String rawTranscript;

  /// Overall confidence of parsing
  final ParsedFieldConfidence overallConfidence;

  /// Calculate estimated total from parsed items (requires menu item prices)
  double estimatedTotal(Map<String, double> prices) {
    return items.fold(0.0, (sum, item) {
      final price = prices[item.menuItemId] ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((i) => i.toJson()).toList(),
    'cashMention': cashMention?.toJson(),
    'soldOutItems': soldOutItems,
    'paymentModeHint': paymentModeHint,
    'notes': notes,
    'rawTranscript': rawTranscript,
    'overallConfidence': overallConfidence.name,
  };
}

/// Menu-aware parser for voice recap transcripts
/// 
/// Extracts structured data from natural language recaps:
/// - Item mentions with quantities
/// - Cash amounts
/// - Sold-out indicators
/// - Payment mode hints
class MenuAwareParser {
  MenuAwareParser({
    this.enableFuzzyMatching = true,
    this.defaultLanguage = 'ms',
  });

  /// Enable fuzzy matching for menu items
  final bool enableFuzzyMatching;

  /// Default language for parsing hints
  final String defaultLanguage;

  // Common Malay number words
  static const _malayNumbers = {
    'satu': 1, 'dua': 2, 'tiga': 3, 'empat': 4, 'lima': 5,
    'enam': 6, 'tujuh': 7, 'lapan': 8, 'sembilan': 9, 'sepuluh': 10,
    'sebelas': 11, 'dua belas': 12, 'tiga belas': 13, 'empat belas': 14, 'lima belas': 15,
    'dua puluh': 20, 'tiga puluh': 30, 'empat puluh': 40, 'lima puluh': 50,
    'seratus': 100, 'dua ratus': 200, 'tiga ratus': 300,
  };

  // Approximate quantity indicators
  static final _approximateIndicators = RegExp(
    r'\b(about|around|dalam|lebih kurang|agak|roughly|approximately|kira-kira|lebih dari|kurang dari)\b',
    caseSensitive: false,
  );

  // Sold out indicators
  static final _soldOutIndicators = RegExp(
    r'\b(sold out|habis|sold off|finished|all gone|tak ada dah|takda dah|licin)\b',
    caseSensitive: false,
  );

  // Cash keywords
  static final _cashKeywords = RegExp(
    r'\b(cash|tunai|duit cash|duit dalam tangan|counted cash|kira cash|cash yang|cash ada|wang tunai)\b',
    caseSensitive: false,
  );

  // Money amount patterns
  static final _amountPattern = RegExp(
    r'(?:rm\s*)?(\d+(?:\.\d{1,2})?)\s*(?:ringgit)?',
    caseSensitive: false,
  );

  // Payment mode hints
  static final _paymentModePatterns = {
    'mostly_cash': RegExp(r'\b(mostly cash|kebanyakan cash|semua cash|all cash|tunai semua)\b', caseSensitive: false),
    'mostly_qr': RegExp(r'\b(mostly qr|kebanyakan qr|semua qr|all digital|all e-wallet)\b', caseSensitive: false),
    'mixed': RegExp(r'\b(mixed|campuran|ada cash ada qr|some cash some qr)\b', caseSensitive: false),
  };

  /// Parse a transcript against a list of menu items
  /// 
  /// [transcript] - The raw transcript text
  /// [menuItems] - List of merchant's menu items to match against
  /// [aliases] - Optional map of menu item ID to list of aliases
  ParsedRecap parse(
    String transcript,
    List<MenuItem> menuItems, {
    Map<String, List<String>>? aliases,
  }) {
    final normalizedTranscript = transcript.toLowerCase();
    final detectedItems = <ParsedItemMention>[];
    final soldOutItems = <String>[];

    // Build search terms map (item name -> item)
    final searchTerms = <String, MenuItem>{};
    for (final item in menuItems) {
      searchTerms[item.name.toLowerCase()] = item;
      // Add aliases if available
      final itemAliases = aliases?[item.id] ?? [];
      for (final alias in itemAliases) {
        searchTerms[alias.toLowerCase()] = item;
      }
    }

    // Find item mentions
    for (final entry in searchTerms.entries) {
      final term = entry.key;
      final item = entry.value;

      // Skip if already detected this item
      if (detectedItems.any((d) => d.menuItemId == item.id)) continue;

      final termIndex = normalizedTranscript.indexOf(term);
      if (termIndex == -1) continue;

      // Extract surrounding context (50 chars before and after)
      final start = (termIndex - 50).clamp(0, normalizedTranscript.length);
      final end = (termIndex + term.length + 50).clamp(0, normalizedTranscript.length);
      final context = normalizedTranscript.substring(start, end);

      // Check if sold out
      final isSoldOut = _soldOutIndicators.hasMatch(context);
      if (isSoldOut) {
        soldOutItems.add(item.name);
      }

      // Try to extract quantity
      final quantityResult = _extractQuantity(context, term);
      final isApproximate = _approximateIndicators.hasMatch(context);

      if (quantityResult != null || isSoldOut) {
        detectedItems.add(ParsedItemMention(
          menuItemId: item.id,
          menuItemName: item.name,
          quantity: quantityResult ?? (isSoldOut ? 0 : 1),
          confidence: _determineItemConfidence(quantityResult, isApproximate, isSoldOut),
          rawMention: context.trim(),
          isApproximate: isApproximate,
          isSoldOut: isSoldOut,
        ));
      }
    }

    // Extract cash mention
    final cashMention = _extractCashMention(normalizedTranscript);

    // Detect payment mode hint
    String? paymentModeHint;
    for (final entry in _paymentModePatterns.entries) {
      if (entry.value.hasMatch(normalizedTranscript)) {
        paymentModeHint = entry.key;
        break;
      }
    }

    // Determine overall confidence
    final overallConfidence = _determineOverallConfidence(detectedItems, cashMention);

    return ParsedRecap(
      items: detectedItems,
      cashMention: cashMention,
      soldOutItems: soldOutItems,
      paymentModeHint: paymentModeHint,
      rawTranscript: transcript,
      overallConfidence: overallConfidence,
    );
  }

  /// Extract quantity from context around an item mention
  int? _extractQuantity(String context, String itemName) {
    // Pattern: number before or after item name
    // Examples: "30 bihun", "bihun 30", "dalam 30 portion"

    // Try digit patterns
    final digitMatches = RegExp(r'\b(\d+)\b').allMatches(context);
    for (final match in digitMatches) {
      final value = int.tryParse(match.group(1) ?? '');
      if (value != null && value > 0 && value < 500) {
        // Reasonable quantity range for hawker stall
        return value;
      }
    }

    // Try Malay number words
    for (final entry in _malayNumbers.entries) {
      if (context.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Extract cash mention from transcript
  ParsedCashMention? _extractCashMention(String transcript) {
    // Look for cash keyword followed by amount
    if (!_cashKeywords.hasMatch(transcript)) return null;

    // Find the cash context
    final cashMatch = _cashKeywords.firstMatch(transcript);
    if (cashMatch == null) return null;

    // Look for amount after the cash keyword
    final afterCash = transcript.substring(cashMatch.end);
    final amountMatch = _amountPattern.firstMatch(afterCash);

    if (amountMatch != null) {
      final amount = double.tryParse(amountMatch.group(1) ?? '');
      if (amount != null && amount > 0) {
        final isApproximate = _approximateIndicators.hasMatch(
          transcript.substring(
            (cashMatch.start - 30).clamp(0, transcript.length),
            (amountMatch.end + cashMatch.end).clamp(0, transcript.length),
          ),
        );

        return ParsedCashMention(
          amount: amount,
          confidence: isApproximate ? ParsedFieldConfidence.medium : ParsedFieldConfidence.high,
          rawMention: transcript.substring(
            cashMatch.start,
            (amountMatch.end + cashMatch.end).clamp(0, transcript.length),
          ),
          isApproximate: isApproximate,
        );
      }
    }

    // Try Malay number patterns for cash
    for (final entry in _malayNumbers.entries) {
      if (afterCash.contains(entry.key)) {
        return ParsedCashMention(
          amount: entry.value.toDouble(),
          confidence: ParsedFieldConfidence.medium,
          rawMention: '${cashMatch.group(0)} ${entry.key}',
          isApproximate: true,
        );
      }
    }

    return null;
  }

  /// Determine confidence for an item mention
  ParsedFieldConfidence _determineItemConfidence(
    int? quantity,
    bool isApproximate,
    bool isSoldOut,
  ) {
    if (isSoldOut && quantity == null) {
      return ParsedFieldConfidence.medium;
    }
    if (quantity != null && !isApproximate) {
      return ParsedFieldConfidence.medium; // Voice input inherently has some uncertainty
    }
    if (quantity != null && isApproximate) {
      return ParsedFieldConfidence.low;
    }
    return ParsedFieldConfidence.low;
  }

  /// Determine overall parsing confidence
  ParsedFieldConfidence _determineOverallConfidence(
    List<ParsedItemMention> items,
    ParsedCashMention? cashMention,
  ) {
    if (items.isEmpty && cashMention == null) {
      return ParsedFieldConfidence.low;
    }

    final hasHighConfidenceItems = items.any((i) => i.confidence == ParsedFieldConfidence.high);
    final hasMostlyMediumConfidence = items.where((i) => 
      i.confidence == ParsedFieldConfidence.medium || 
      i.confidence == ParsedFieldConfidence.high
    ).length > items.length / 2;

    if (hasHighConfidenceItems || (hasMostlyMediumConfidence && items.length >= 2)) {
      return ParsedFieldConfidence.medium;
    }

    return ParsedFieldConfidence.low;
  }
}
