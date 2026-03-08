import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../models/match_record.dart';
import '../../models/correction_record.dart';
import '../local/database.dart';

class MatchRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save a new match between a payment and an order
  Future<void> saveMatch(MatchRecord match) async {
    final db = await _dbHelper.database;
    await db.insert(
      'match_records',
      {
        'id': match.id,
        'paymentEventId': match.paymentEventId,
        'orderEventId': match.orderEventId,
        'confidenceScore': match.confidenceScore,
        'reasons': jsonEncode(match.reasons), // List<String> to JSON string
        'matchedAt': match.matchedAt.toIso8601String(),
        'isManualCorrection': match.isManualCorrection ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get a match for a specific payment
  Future<MatchRecord?> getMatchByPaymentId(String paymentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'match_records',
      where: 'paymentEventId = ?',
      whereArgs: [paymentId],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return MatchRecord(
        id: map['id'] as String,
        paymentEventId: map['paymentEventId'] as String,
        orderEventId: map['orderEventId'] as String,
        confidenceScore: map['confidenceScore'] as double,
        reasons: List<String>.from(jsonDecode(map['reasons'] as String)),
        matchedAt: DateTime.parse(map['matchedAt'] as String),
        isManualCorrection: map['isManualCorrection'] == 1,
      );
    }
    return null;
  }

  // Log a manual correction
  Future<void> saveCorrection(CorrectionRecord correction) async {
    final db = await _dbHelper.database;
    await db.insert(
      'correction_records',
      {
        'id': correction.id,
        'matchRecordId': correction.matchRecordId,
        'oldOrderEventId': correction.oldOrderEventId,
        'newOrderEventId': correction.newOrderEventId,
        'reason': correction.reason,
        'correctedAt': correction.correctedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}