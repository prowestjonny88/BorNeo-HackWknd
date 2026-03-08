import 'dart:io';

/// Delete file on mobile/desktop platforms
void deleteFileSync(String path) {
  try {
    File(path).deleteSync();
  } catch (_) {
    // Ignore errors - this is just cleanup
  }
}
