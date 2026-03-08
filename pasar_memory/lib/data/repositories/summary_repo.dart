import 'package:sqflite/sqflite.dart';
import '../../models/daily_summary.dart';
import '../local/database.dart';

class SummaryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save or update a daily summary
  Future<void> saveSummary(DailySummary summary) async {
    final db = await _dbHelper.database;
    await db.insert(
      'daily_summaries',
      {
        'id': summary.id,
        'date': summary.date.toIso8601String().split('T')[0],
        'totalSales': summary.totalSales,
        'digitalTotal': summary.digitalTotal,
        'cashEstimate': summary.cashEstimate,
        'unresolvedCount': summary.unresolvedCount,
        'isConfirmed': summary.isConfirmed ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get summary for a specific date
  Future<DailySummary?> getSummaryByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final String dateStr = date.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'daily_summaries',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return DailySummary(
        id: map['id'] as String,
        date: DateTime.parse(map['date'] as String),
        totalSales: map['totalSales'] as double,
        digitalTotal: map['digitalTotal'] as double,
        cashEstimate: map['cashEstimate'] as double,
        unresolvedCount: map['unresolvedCount'] as int,
        isConfirmed: map['isConfirmed'] == 1,
      );
    }
    return null;
  }
}