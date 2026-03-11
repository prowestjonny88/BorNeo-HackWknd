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

  static const Map<String, int> _unitWords = {
    'satu': 1,
    'dua': 2,
    'tiga': 3,
    'empat': 4,
    'lima': 5,
    'enam': 6,
    'tujuh': 7,
    'lapan': 8,
    'sembilan': 9,
    'sepuluh': 10,
    'sebelas': 11,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
  };

  static const Map<String, int> _tensWords = {
    'dua puluh': 20,
    'tiga puluh': 30,
    'empat puluh': 40,
    'lima puluh': 50,
    'enam puluh': 60,
    'tujuh puluh': 70,
    'lapan puluh': 80,
    'sembilan puluh': 90,
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
  };

  static const Map<String, int> _hundredsWords = {
    'seratus': 100,
    'dua ratus': 200,
    'tiga ratus': 300,
    'empat ratus': 400,
    'lima ratus': 500,
    'enam ratus': 600,
    'tujuh ratus': 700,
    'lapan ratus': 800,
    'sembilan ratus': 900,
    'hundred': 100,
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

  static final _cashKeywords = RegExp(
    r'\b(cash|tunai|duit cash|duit dalam tangan|counted cash|kira cash|cash yang|cash ada|wang tunai|tunai ada|cash received|cash dapat)\b',
    caseSensitive: false,
  );

  static final _amountPattern = RegExp(
    r'(?:rm\s*)?(\d+(?:\.\d{1,2})?)\s*(?:ringgit)?',
    caseSensitive: false,
  );

  static final _wordTokenPattern = RegExp(r'[a-z0-9]+', caseSensitive: false);

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
    final normalizedTranscript = _normalizeText(transcript);
    final detectedItems = <ParsedItemMention>[];
    final soldOutItems = <String>[];

    final searchTerms = <String, MenuItem>{};
    for (final item in menuItems) {
      searchTerms[_normalizeText(item.name)] = item;
      final itemAliases = aliases?[item.id] ?? [];
      for (final alias in itemAliases) {
        final normalizedAlias = _normalizeText(alias);
        if (normalizedAlias.isNotEmpty) {
          searchTerms[normalizedAlias] = item;
        }
      }
    }

    // Step 1: Collect all (term, item, matchStart, matchEnd) without duplicates.
    final allCandidates = <(String, MenuItem, int, int)>[];
    for (final entry in searchTerms.entries) {
      final term = entry.key;
      final item = entry.value;
      if (term.isEmpty) continue;
      if (allCandidates.any((c) => c.$2.id == item.id)) continue;
      final matches = _findTermMatches(normalizedTranscript, term);
      if (matches.isEmpty) continue;
      final best = matches.first;
      allCandidates.add((term, item, best.$1, best.$2));
    }

    // Step 2: Sort left-to-right so earlier items claim their numbers first.
    allCandidates.sort((a, b) => a.$3.compareTo(b.$3));

    // Step 3: Process in order, tracking which term ranges have been claimed.
    final claimedTermRanges = <(int, int)>[];
    for (final candidate in allCandidates) {
      final item = candidate.$2;
      final termStart = candidate.$3;
      final termEnd = candidate.$4;

      final context = _contextWindow(normalizedTranscript, termStart, termEnd, 50);

      final isSoldOut = _soldOutIndicators.hasMatch(context);
      if (isSoldOut) {
        soldOutItems.add(item.name);
      }

      final quantityResult = _extractQuantityNearTerm(
        normalizedTranscript, termStart, termEnd,
        priorTermRanges: claimedTermRanges,
      );
      final isApproximate = _approximateIndicators.hasMatch(context);

      detectedItems.add(ParsedItemMention(
        menuItemId: item.id,
        menuItemName: item.name,
        quantity: quantityResult ?? (isSoldOut ? 0 : 1),
        confidence: _determineItemConfidence(quantityResult, isApproximate, isSoldOut),
        rawMention: context.trim(),
        isApproximate: isApproximate,
        isSoldOut: isSoldOut,
      ));

      claimedTermRanges.add((termStart, termEnd));
    }

    final cashMention = _extractCashMention(normalizedTranscript);

    String? paymentModeHint;
    for (final entry in _paymentModePatterns.entries) {
      if (entry.value.hasMatch(normalizedTranscript)) {
        paymentModeHint = entry.key;
        break;
      }
    }

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

  List<(int, int)> _findTermMatches(String text, String term) {
    final escaped = RegExp.escape(term);
    final regex = RegExp('(^|\\s)$escaped(\\s|\$)', caseSensitive: false);
    final matches = <(int, int)>[];
    for (final match in regex.allMatches(text)) {
      final start = match.start + (match.group(1)?.length ?? 0);
      final end = start + term.length;
      matches.add((start, end));
    }

    if (matches.isEmpty && enableFuzzyMatching) {
      final idx = text.indexOf(term);
      if (idx >= 0) {
        matches.add((idx, idx + term.length));
      }
    }

    return matches;
  }

  String _normalizeText(String raw) {
    final lowered = raw.toLowerCase();
    return lowered.replaceAll(RegExp(r'[^a-z0-9\.\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _contextWindow(String text, int start, int end, int padding) {
    final left = (start - padding).clamp(0, text.length);
    final right = (end + padding).clamp(0, text.length);
    return text.substring(left, right);
  }

  int? _extractQuantityNearTerm(String transcript, int termStart, int termEnd, {
    List<(int, int)> priorTermRanges = const [],
  }) {
    // Extract text BEFORE the item term (up to 15 chars before termStart)
    final beforeStart = (termStart - 15).clamp(0, transcript.length);
    final before = transcript.substring(beforeStart, termStart);
    
    // Extract text AFTER the item term (up to 15 chars after termEnd)
    final afterEnd = (termEnd + 15).clamp(0, transcript.length);
    final after = transcript.substring(termEnd, afterEnd);

    final beforeValue = _extractLastSmallNumber(before);
    final afterValue = _extractFirstSmallNumber(after);

    // If the number in the before-window is the cash amount itself, reject it.
    // Works for both digit ("cash 32 nasi") and word ("cash six nasi") forms.
    if (beforeValue != null && _isCashFollowedByValue(before, beforeValue)) {
      return afterValue;
    }

    // Check if extracted numbers are near cash keywords - if so, reject them
    if (beforeValue != null && _isNearCashKeyword(transcript, termStart - 15, termStart, beforeValue)) {
      // beforeValue is contaminated by cash mention, skip it
      return afterValue != null && !_isNearCashKeyword(transcript, termEnd, termEnd + 15, afterValue) 
        ? afterValue 
        : null;
    }
    if (afterValue != null && _isNearCashKeyword(transcript, termEnd, termEnd + 15, afterValue)) {
      // afterValue is contaminated by cash mention, use beforeValue
      return beforeValue;
    }

    // Prefer the value immediately before the term (like "6 nasi kukus")
    // over the value after (like "nasi kukus 6"), UNLESS a prior detected item
    // sits inside the before-window — in that case the before-number was already
    // claimed by that item (e.g. "mee 3 nasi 5" → 3 belongs to mee, not nasi).
    if (beforeValue != null && afterValue != null) {
      final beforeStart = (termStart - 15).clamp(0, transcript.length);
      final priorTermInWindow = priorTermRanges.any(
        (r) => r.$2 > beforeStart && r.$2 <= termStart,
      );
      if (priorTermInWindow) return afterValue;
      return beforeValue;
    }
    return beforeValue ?? afterValue;
  }

  int? _extractLastSmallNumber(String text) {
    final tokenMatches = _wordTokenPattern.allMatches(text).toList(growable: false);
    for (var i = tokenMatches.length - 1; i >= 0; i--) {
      final parsed = _parseNumberishTokens(tokenMatches, i, reverse: true);
      if (parsed != null && parsed > 0 && parsed <= 500) {
        return parsed;
      }
    }
    return null;
  }

  bool _isNearCashKeyword(String transcript, int start, int end, int value) {
    // Small quantities (< 50) are very unlikely to be cash amounts
    // Even if they appear near cash keywords, they're probably item quantities
    if (value < 50) return false;
    
    final snippet = transcript.substring(
      start.clamp(0, transcript.length),
      end.clamp(0, transcript.length),
    );
    
    // Check if this snippet contains cash keywords
    final cashMatch = _cashKeywords.firstMatch(snippet);
    if (cashMatch == null) return false;
    
    // Find the position of the value (as string) in the snippet
    final valueStr = value.toString();
    final valueIndex = snippet.indexOf(valueStr);
    if (valueIndex < 0) return false;
    
    // Get the distance between the number and the cash keyword
    final cashStart = cashMatch.start;
    final cashEnd = cashMatch.end;
    final valueEnd = valueIndex + valueStr.length;
    
    // Consider contaminated if:
    // 1. Number appears within 8 chars AFTER cash keyword (likely "cash 200")
    // 2. Cash keyword appears within 8 chars AFTER number (likely "200 cash" or "200 tunai")
    final numberAfterCash = valueIndex >= cashEnd && valueIndex - cashEnd <= 8;
    final cashAfterNumber = cashStart >= valueEnd && cashStart - valueEnd <= 8;
    
    return numberAfterCash || cashAfterNumber;
  }

  int? _extractFirstSmallNumber(String text) {
    final tokenMatches = _wordTokenPattern.allMatches(text).toList(growable: false);
    for (var i = 0; i < tokenMatches.length; i++) {
      final parsed = _parseNumberishTokens(tokenMatches, i);
      if (parsed != null && parsed > 0 && parsed <= 500) {
        return parsed;
      }
    }
    return null;
  }

  int? _parseNumberishTokens(List<RegExpMatch> tokens, int index, {bool reverse = false}) {
    final token = tokens[index].group(0) ?? '';
    final directInt = int.tryParse(token);
    if (directInt != null) return directInt;

    final maxLen = 3;
    for (var len = maxLen; len >= 1; len--) {
      int start;
      int end;
      if (reverse) {
        start = index - len + 1;
        end = index;
      } else {
        start = index;
        end = index + len - 1;
      }
      if (start < 0 || end >= tokens.length) continue;

      final phrase = <String>[];
      for (var i = start; i <= end; i++) {
        phrase.add(tokens[i].group(0) ?? '');
      }

      final parsed = _parseNumberPhrase(phrase);
      if (parsed != null) return parsed;
    }

    return null;
  }

  int? _parseNumberPhrase(List<String> words) {
    if (words.isEmpty) return null;
    final joined = words.join(' ');
    if (_hundredsWords.containsKey(joined)) return _hundredsWords[joined];
    if (_tensWords.containsKey(joined)) return _tensWords[joined];
    if (_unitWords.containsKey(joined)) return _unitWords[joined];

    if (words.length == 2) {
      final first = words[0];
      final second = words[1];
      if (_tensWords.containsKey(first) && _unitWords.containsKey(second)) {
        return (_tensWords[first] ?? 0) + (_unitWords[second] ?? 0);
      }
      if (_unitWords.containsKey(first) && second == 'hundred') {
        return (_unitWords[first] ?? 0) * 100;
      }
      if (_unitWords.containsKey(first) && second == 'ratus') {
        return (_unitWords[first] ?? 0) * 100;
      }
    }

    if (words.length == 3) {
      final first = words[0];
      final second = words[1];
      final third = words[2];
      if (_unitWords.containsKey(first) && (second == 'hundred' || second == 'ratus') && _unitWords.containsKey(third)) {
        return (_unitWords[first] ?? 0) * 100 + (_unitWords[third] ?? 0);
      }
      if (_unitWords.containsKey(first) && (second == 'hundred' || second == 'ratus') && _tensWords.containsKey(third)) {
        return (_unitWords[first] ?? 0) * 100 + (_tensWords[third] ?? 0);
      }
    }

    return null;
  }

  ParsedCashMention? _extractCashMention(String transcript) {
    if (!_cashKeywords.hasMatch(transcript)) return null;

    ParsedCashMention? best;
    for (final cashMatch in _cashKeywords.allMatches(transcript)) {
      // Prefer the number immediately AFTER the cash keyword (e.g. "cash 1 nasi 6").
      // Only fall back to immediately BEFORE if nothing follows.
      final afterEnd = (cashMatch.end + 15).clamp(0, transcript.length);
      final afterText = transcript.substring(cashMatch.end, afterEnd);
      double? amount = _extractFirstMoneyAmount(afterText);

      if (amount == null || amount <= 0) {
        final beforeStart = (cashMatch.start - 15).clamp(0, transcript.length);
        final beforeText = transcript.substring(beforeStart, cashMatch.start);
        amount = _extractLastMoneyAmount(beforeText);
      }

      if (amount == null || amount <= 0) continue;

      final around = _contextWindow(transcript, cashMatch.start, cashMatch.end, 28);
      final isApproximate = _approximateIndicators.hasMatch(around);
      final current = ParsedCashMention(
        amount: amount,
        confidence: isApproximate ? ParsedFieldConfidence.medium : ParsedFieldConfidence.high,
        rawMention: around,
        isApproximate: isApproximate,
      );

      if (best == null || current.amount > best.amount) {
        best = current;
      }
    }

    return best;
  }

  double? _extractBestMoneyAmount(String text) {
    final numericMatches = _amountPattern.allMatches(text).toList(growable: false);
    if (numericMatches.isNotEmpty) {
      double? best;
      for (final match in numericMatches) {
        final parsed = double.tryParse((match.group(1) ?? '').trim());
        if (parsed == null) continue;
        if (parsed <= 0) continue;
        if (best == null || parsed > best) {
          best = parsed;
        }
      }
      if (best != null) return best;
    }

    final wordTokens = _wordTokenPattern.allMatches(text).toList(growable: false);
    for (var i = 0; i < wordTokens.length; i++) {
      final parsed = _parseNumberishTokens(wordTokens, i);
      if (parsed != null && parsed > 0) {
        return parsed.toDouble();
      }
    }

    return null;
  }

  /// Returns the first valid amount in [text] (left-to-right).
  /// Competes digit-based amounts (handles decimals like 6.50) against
  /// word numbers (e.g. "five") and returns whichever appears earliest.
  double? _extractFirstMoneyAmount(String text) {
    // Earliest digit/decimal match via _amountPattern
    int? digitStart;
    double? digitValue;
    for (final match in _amountPattern.allMatches(text)) {
      final parsed = double.tryParse((match.group(1) ?? '').trim());
      if (parsed != null && parsed > 0) {
        digitStart = match.start;
        digitValue = parsed;
        break;
      }
    }

    // Earliest word-number token
    int? wordStart;
    double? wordValue;
    final wordTokens = _wordTokenPattern.allMatches(text).toList(growable: false);
    for (var i = 0; i < wordTokens.length; i++) {
      final parsed = _parseNumberishTokens(wordTokens, i);
      if (parsed != null && parsed > 0) {
        wordStart = wordTokens[i].start;
        wordValue = parsed.toDouble();
        break;
      }
    }

    if (digitStart == null && wordStart == null) return null;
    if (digitStart == null) return wordValue;
    if (wordStart == null) return digitValue;
    // Both found: whichever starts earlier in the text wins
    return digitStart <= wordStart ? digitValue : wordValue;
  }

  /// Returns true when [before] contains a cash keyword immediately
  /// followed by [value] (as a digit or word number), meaning this
  /// number is the cash amount and should not be used as an item quantity.
  /// Also rejects the fractional part of a decimal cash (e.g. 50 from 6.50).
  bool _isCashFollowedByValue(String before, int value) {
    for (final cashMatch in _cashKeywords.allMatches(before)) {
      final afterCash = before.substring(cashMatch.end);
      // Try decimal-aware pattern first so "6.50" is treated as one amount.
      final amountMatch = _amountPattern.firstMatch(afterCash.trimLeft());
      if (amountMatch != null) {
        final amountStr = (amountMatch.group(1) ?? '').trim();
        final parsed = double.tryParse(amountStr);
        if (parsed != null && parsed > 0) {
          // Reject if value is the integer part (6 from 6.50)
          if (parsed.toInt() == value) return true;
          // Reject if value is the fractional digit sequence (50 from 6.50)
          final dotIdx = amountStr.indexOf('.');
          if (dotIdx >= 0) {
            final fracPart = int.tryParse(amountStr.substring(dotIdx + 1));
            if (fracPart == value) return true;
          }
          // Reject if value matches the rounded whole amount
          if (parsed.round() == value) return true;
        }
      }
      // Word number fallback (e.g. "cash five")
      final firstVal = _extractFirstSmallNumber(afterCash);
      if (firstVal == value) return true;
    }
    return false;
  }

  /// Returns the last valid amount in [text] (right-to-left).
  double? _extractLastMoneyAmount(String text) {
    final numericMatches = _amountPattern.allMatches(text).toList(growable: false);
    for (var i = numericMatches.length - 1; i >= 0; i--) {
      final parsed = double.tryParse((numericMatches[i].group(1) ?? '').trim());
      if (parsed != null && parsed > 0) return parsed;
    }
    final wordTokens = _wordTokenPattern.allMatches(text).toList(growable: false);
    for (var i = wordTokens.length - 1; i >= 0; i--) {
      final parsed = _parseNumberishTokens(wordTokens, i, reverse: true);
      if (parsed != null && parsed > 0) return parsed.toDouble();
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
