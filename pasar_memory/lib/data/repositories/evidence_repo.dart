import '../local/database.dart';
import 'package:uuid/uuid.dart';

class EvidenceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveEvidence(String type, String filePath) async {
    final db = await _dbHelper.database;
    await db.insert('daily_evidence', {
      'id': const Uuid().v4(),
      'type': type, // 'screenshot', 'audio', 'export'
      'filePath': filePath,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getEvidenceByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    return await db.query(
      'daily_evidence',
      where: "timestamp LIKE ?",
      whereArgs: ['$dateStr%'],
    );
  }
}