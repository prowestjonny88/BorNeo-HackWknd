import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../models/menu_item.dart';
import 'menu_aware_parser.dart';

/// Result from Gemini parsing — includes structured recap plus any unknown items
class GeminiParseResult {
  const GeminiParseResult({
    required this.parsedRecap,
    this.unknownItems = const [],
    this.correctedTranscript,
    this.orderingError = false,
    this.orderingErrorItems = const [],
  });

  final ParsedRecap parsedRecap;

  /// Food names mentioned by the user that do NOT match any menu item
  final List<String> unknownItems;

  /// Gemini-corrected version of the raw STT transcript (typos, mishears fixed)
  final String? correctedTranscript;

  /// True if any item was said with quantity before name (e.g. "10 mee")
  final bool orderingError;

  /// The specific phrases that had wrong ordering
  final List<String> orderingErrorItems;

  bool get hasUnknownItems => unknownItems.isNotEmpty;
  bool get hasOrderingError => orderingError && orderingErrorItems.isNotEmpty;
}

/// Calls Gemini 1.5 Flash to intelligently parse a voice recap transcript
/// against the merchant's menu items.
class GeminiRecapService {
  static const _apiKey = 'AIzaSyCEpT14N0-JS-U2nliBO79ARoAImI_8uRg';

  late final GenerativeModel _model;

  GeminiRecapService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<GeminiParseResult> parse(
    String transcript,
    List<MenuItem> menuItems,
  ) async {
    final menuList = menuItems.map((m) => '- ${m.name} (id: ${m.id})').join('\n');

    final prompt = '''
You are correcting a speech-to-text transcript from a Malaysian hawker stall seller doing an end-of-day sales recap.

CRITICAL CONTEXT — READ THIS FIRST:
- The speaker is Malaysian, speaking Malay-English mix (Manglish/Bahasa Malaysia).
- Speech-to-text engines FREQUENTLY mishear NUMBERS as random English words in Malaysian accents.
- This recap is about SALES: how many of each food item was sold + total cash collected.
- Every non-food word adjacent to a food item name is ALMOST CERTAINLY a number (quantity sold).
- If any word in the transcript makes no logical sense in a hawker sales context, treat it as a misheard number.

COMMON STT MISHEAR PATTERNS (number → what STT outputs):
- 10 → "Dan", "Dad", "den", "ten", "tan", "Dann"
- 5 → "five", "fab", "far", "fire", "phi"
- 20 → "twenty", "Wendy", "twin tea"
- 30 → "thirty", "dirty", "Bertie"
- 50 → "fifty", "Fifi", "Philly"
- 100 → "hundred", "Honda", "wonder"
- 2 → "dua", "to", "too", "do"
- 3 → "tiga", "tree", "three"
- 15 → "fifteen", "Fifi teen"
- Any random English name (Dad, Dan, Bob, etc.) next to food = number mishear
- Any nonsense word next to food = number mishear

Available menu items:
$menuList

Raw STT transcript (treat ALL random non-food words near food names as misheard numbers):
"$transcript"

Do TWO things and return ONLY valid JSON — no markdown, no explanation:
1. CORRECT THE TRANSCRIPT: Reconstruct what the seller actually said. Replace every misheard number word with the most plausible integer. If a word adjacent to a food name makes no logical sense as English/Malay, it is a number — pick the most phonetically similar integer.
2. EXTRACT STRUCTURED DATA from the corrected transcript.

{
  "correctedTranscript": "<corrected human-readable transcript>",
  "items": [
    {
      "menuItemId": "<exact id from list above>",
      "menuItemName": "<exact name from list above>",
      "quantity": <integer>,
      "confidence": "<high|medium|low>",
      "isApproximate": <true|false>,
      "isSoldOut": <true|false>
    }
  ],
  "cashAmount": <number or null>,
  "cashIsApproximate": <true|false>,
  "paymentModeHint": "<mostly_cash|mostly_qr|mixed|null>",
  "unknownItems": ["<food/drink names mentioned that do NOT match any menu item even approximately>"],
  "soldOutItems": ["<menu item names mentioned as sold out or habis>"],
  "orderingError": <true|false>,
  "orderingErrorItems": ["<e.g. '10 mee' — quantity came before item name>"]
}

Rules:
- ORDERING RULE (strict): Only accept an item if the item name comes FIRST, then the quantity after it (if a quantity is given). Example: "mee 10" ✓, "bihun 30" ✓. If quantities appear before an item name (e.g. "10 mee"), do NOT accept that entry. If an item is mentioned with NO quantity, that is fine — assume quantity=1. Do NOT reject items just because no quantity was stated.
- correctedTranscript: fix ALL mishears. Example: "mee Dad" → "mee 10", "bihun dirty" → "bihun 30", "nasi Dan" → "nasi 10".
- Only match items that exist in the provided menu list. Never invent new menu item ids.
- Manglish vocab: "habis"/"licin" = sold out, "dalam/lebih kurang/kira-kira" = approximately, "dua" = 2, "tiga" = 3, "empat" = 4, "lima" = 5, "tiga puluh" = 30, "seratus" = 100.
- If a food name is mentioned but genuinely has NO match in the menu (even fuzzy), put it in unknownItems.
- Do NOT put an item in unknownItems if you can reasonably match it (e.g. "bihun" matches "bihun goreng").
- cashAmount: null if not mentioned. Set only if explicitly mentioned (e.g. "cash 120", "tunai 150 ringgit").
- paymentModeHint: null if not mentioned.
- orderingError: true if ANY item was said with quantity before name (e.g. "10 mee"). In that case also populate orderingErrorItems with what was said wrong.
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';

    final jsonStr = _extractJson(text);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Parse items — only keep valid menu item ids
    final rawItems = (json['items'] as List? ?? []);
    final items = <ParsedItemMention>[];
    for (final raw in rawItems) {
      final map = raw as Map<String, dynamic>;
      final menuItemId = map['menuItemId'] as String? ?? '';
      if (!menuItems.any((m) => m.id == menuItemId)) continue;
      items.add(ParsedItemMention(
        menuItemId: menuItemId,
        menuItemName: map['menuItemName'] as String? ?? '',
        quantity: (map['quantity'] as num? ?? 0).toInt(),
        confidence: _parseConfidence(map['confidence'] as String? ?? 'medium'),
        isApproximate: map['isApproximate'] as bool? ?? false,
        isSoldOut: map['isSoldOut'] as bool? ?? false,
      ));
    }

    // Parse cash
    final cashAmount = (json['cashAmount'] as num?)?.toDouble();
    final cashIsApproximate = json['cashIsApproximate'] as bool? ?? false;
    ParsedCashMention? cashMention;
    if (cashAmount != null && cashAmount > 0) {
      cashMention = ParsedCashMention(
        amount: cashAmount,
        confidence: cashIsApproximate ? ParsedFieldConfidence.medium : ParsedFieldConfidence.high,
        isApproximate: cashIsApproximate,
      );
    }

    // Ordering error
    final orderingError = json['orderingError'] as bool? ?? false;
    final orderingErrorItems = (json['orderingErrorItems'] as List? ?? [])
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Unknown items — merge ordering errors in so user sees both
    final unknownItems = [
      ...(json['unknownItems'] as List? ?? [])
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty),
      if (orderingError) ...orderingErrorItems,
    ];

    // Sold out
    final soldOutItems = (json['soldOutItems'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    // Payment mode
    final paymentModeRaw = json['paymentModeHint'];
    final paymentModeHint =
        (paymentModeRaw == null || paymentModeRaw == 'null') ? null : paymentModeRaw as String;

    // Corrected transcript
    final correctedTranscript = json['correctedTranscript'] as String?;

    final overallConfidence = (items.isNotEmpty || cashMention != null)
        ? ParsedFieldConfidence.high
        : ParsedFieldConfidence.low;

    return GeminiParseResult(
      parsedRecap: ParsedRecap(
        items: items,
        cashMention: cashMention,
        soldOutItems: soldOutItems,
        paymentModeHint: paymentModeHint,
        rawTranscript: correctedTranscript ?? transcript,
        overallConfidence: overallConfidence,
      ),
      unknownItems: unknownItems,
      correctedTranscript: correctedTranscript,
      orderingError: orderingError,
      orderingErrorItems: orderingErrorItems,
    );
  }

  String _extractJson(String text) {
    final codeBlock = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = codeBlock.firstMatch(text);
    if (match != null) return match.group(1)!.trim();

    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text.trim();
  }

  ParsedFieldConfidence _parseConfidence(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return ParsedFieldConfidence.high;
      case 'low':
        return ParsedFieldConfidence.low;
      default:
        return ParsedFieldConfidence.medium;
    }
  }
}
