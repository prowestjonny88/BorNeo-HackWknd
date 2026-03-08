import '../local/database.dart';

class ExtractionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveExtraction(Map<String, dynamic> record) async {
    final db = await _dbHelper.database;
    await db.insert('extraction_records', record);
  }

  Future<List<Map<String, dynamic>>> getExtractionsByDay(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.query(
      'extraction_records',
      where: "id IN (SELECT id FROM daily_evidence WHERE timestamp LIKE ?)",
      whereArgs: ['$dateStr%'],
    );
  }
}