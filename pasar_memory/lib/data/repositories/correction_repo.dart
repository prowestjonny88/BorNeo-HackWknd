import '../local/database.dart';

class CorrectionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveCorrection(Map<String, dynamic> correction) async {
    final db = await _dbHelper.database;
    await db.insert('correction_records', {
      'id': correction['id'],
      'dayId': correction['dayId'],
      'fieldName': correction['fieldName'],
      'oldValue': correction['oldValue'],
      'newValue': correction['newValue'],
      'reason': correction['reason'],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCorrectionsByDay(String dayId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'correction_records',
      where: 'dayId = ?',
      whereArgs: [dayId],
    );
  }
}