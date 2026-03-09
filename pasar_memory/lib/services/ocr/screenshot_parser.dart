class ParsedPaymentAmount {
  const ParsedPaymentAmount({
    required this.amount,
    required this.confidence,
    required this.trustLabel,
  });

  final double amount;
  final double confidence;
  final String trustLabel;
}

class ParsedScreenshot {
  const ParsedScreenshot({
    required this.amounts,
    required this.rawText,
    this.provider,
    this.timestamp,
    this.notes = const <String>[],
  });

  final List<ParsedPaymentAmount> amounts;
  final String rawText;
  final String? provider;
  final DateTime? timestamp;
  final List<String> notes;
}

class ScreenshotParser {
  static final RegExp _contextPattern = RegExp(
    r'(?:total|jumlah|amount|bayaran|payment|received|dibayar|transfer|charged|tolak|settlement|credited)'
    r'\s*[:\-]?\s*(?:RM|MYR)?\s*(\d{1,6}(?:[.,]\d{1,2})?)',
    caseSensitive: false,
  );

  static final RegExp _rmPattern = RegExp(
    r'(?:RM|MYR)\s*(\d{1,6}(?:[.,]\d{1,2})?)',
    caseSensitive: false,
  );

  static final RegExp _providerPattern = RegExp(
    r'(touch\s*n\s*go|duitnow|boost|grabpay|maybank|cimb|bank islam|tng)',
    caseSensitive: false,
  );

  static final RegExp _datePattern = RegExp(
    r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})(?:\s+(\d{1,2}:\d{2}(?::\d{2})?))?',
    caseSensitive: false,
  );

  ParsedScreenshot parseText(String rawText) {
    final cleanedText = rawText.trim();
    if (cleanedText.isEmpty) {
      return const ParsedScreenshot(amounts: <ParsedPaymentAmount>[], rawText: '');
    }

    final normalizedText = cleanedText.replaceAll('\n', ' ');
    final values = <double, ParsedPaymentAmount>{};

    for (final match in _contextPattern.allMatches(normalizedText)) {
      final parsed = _toAmount(match.group(1));
      if (parsed != null && parsed >= 0.10) {
        values[parsed] = ParsedPaymentAmount(
          amount: parsed,
          confidence: 0.9,
          trustLabel: 'From screenshot (context amount)',
        );
      }
    }

    for (final match in _rmPattern.allMatches(normalizedText)) {
      final parsed = _toAmount(match.group(1));
      if (parsed != null && parsed >= 0.10 && !values.containsKey(parsed)) {
        values[parsed] = ParsedPaymentAmount(
          amount: parsed,
          confidence: 0.7,
          trustLabel: 'From screenshot',
        );
      }
    }

    final amounts = values.values.toList(growable: false)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final providerMatch = _providerPattern.firstMatch(normalizedText);
    final provider = providerMatch?.group(0);

    DateTime? parsedTimestamp;
    final dateMatch = _datePattern.firstMatch(normalizedText);
    if (dateMatch != null) {
      parsedTimestamp = _tryParseDate(dateMatch.group(1), dateMatch.group(2));
    }

    final notes = <String>[];
    if (amounts.isEmpty) {
      notes.add('No amount detected from screenshot OCR text.');
    }
    if (amounts.length > 1) {
      notes.add('Multiple amounts detected; review before final reconciliation.');
    }

    return ParsedScreenshot(
      amounts: amounts,
      rawText: cleanedText,
      provider: provider,
      timestamp: parsedTimestamp,
      notes: notes,
    );
  }

  double? _toAmount(String? raw) {
    if (raw == null) return null;
    return double.tryParse(raw.replaceAll(',', '.').trim());
  }

  DateTime? _tryParseDate(String? datePart, String? timePart) {
    if (datePart == null) return null;
    final normalized = datePart.replaceAll('-', '/');
    final pieces = normalized.split('/');
    if (pieces.length != 3) return null;

    final day = int.tryParse(pieces[0]);
    final month = int.tryParse(pieces[1]);
    final yearRaw = int.tryParse(pieces[2]);
    if (day == null || month == null || yearRaw == null) return null;
    final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;

    var hour = 0;
    var minute = 0;
    var second = 0;
    if (timePart != null) {
      final t = timePart.split(':');
      if (t.isNotEmpty) hour = int.tryParse(t[0]) ?? 0;
      if (t.length > 1) minute = int.tryParse(t[1]) ?? 0;
      if (t.length > 2) second = int.tryParse(t[2]) ?? 0;
    }

    return DateTime(year, month, day, hour, minute, second);
  }
}
