import '../local/database.dart';

class LedgerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> upsertLedger(Map<String, dynamic> ledger) async {
    final db = await _dbHelper.database;
    await db.insert(
      'daily_ledgers',
      ledger,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getLedgerByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final maps = await db.query(
      'daily_ledgers',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isNotEmpty) return maps.first;
    return null;
  }
}