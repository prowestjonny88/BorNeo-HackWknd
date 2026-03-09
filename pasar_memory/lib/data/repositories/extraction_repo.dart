import '../local/database.dart';
import 'package:sqflite/sqflite.dart';

class ExtractionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveExtraction(Map<String, dynamic> record) async {
    final db = await _dbHelper.database;
    await db.insert(
      'extraction_records',
      record,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteByEvidenceId(String evidenceId, {required String accountId}) async {
    final db = await _dbHelper.database;
    await db.delete(
      'extraction_records',
      where: 'evidenceId = ? AND accountId = ?',
      whereArgs: [evidenceId, accountId],
    );
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