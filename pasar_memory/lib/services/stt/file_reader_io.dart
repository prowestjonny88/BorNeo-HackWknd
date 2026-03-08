import 'dart:io';
import 'dart:typed_data';

/// Read file bytes on mobile/desktop platforms
Future<Uint8List?> readFileBytes(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  } catch (_) {
    return null;
  }
}
