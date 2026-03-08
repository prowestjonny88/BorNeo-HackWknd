import 'dart:typed_data';

/// Stub implementation for web - file reading not supported
Future<Uint8List?> readFileBytes(String path) async {
  // Web doesn't support file system access
  return null;
}
