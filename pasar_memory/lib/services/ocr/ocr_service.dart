import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'screenshot_parser.dart';

class OcrExtractionResult {
  const OcrExtractionResult({
    required this.rawText,
    required this.parsed,
  });

  final String rawText;
  final ParsedScreenshot parsed;
}

class OcrService {
  OcrService({ScreenshotParser? parser}) : _parser = parser ?? ScreenshotParser();

  final ScreenshotParser _parser;

  Future<OcrExtractionResult> extractFromImagePath(String imagePath) async {
    if (kIsWeb) {
      const empty = ParsedScreenshot(amounts: <ParsedPaymentAmount>[], rawText: '');
      return const OcrExtractionResult(rawText: '', parsed: empty);
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognized = await recognizer.processImage(inputImage);
      final parsed = _parser.parseText(recognized.text);
      return OcrExtractionResult(rawText: recognized.text, parsed: parsed);
    } finally {
      await recognizer.close();
    }
  }

  ParsedScreenshot parseRawText(String rawText) {
    return _parser.parseText(rawText);
  }
}
