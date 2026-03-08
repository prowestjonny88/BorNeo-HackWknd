import '../local/database.dart';

class TapRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveTap(String menuItemId, double amount) async {
    final db = await _dbHelper.database;
    await db.insert('tap_entries', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'menuItemId': menuItemId,
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}