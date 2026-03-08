import 'package:sqflite/sqflite.dart';
import '../../models/payment_evidence.dart';
import '../../models/payment_event.dart';
import '../local/database.dart';

class PaymentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save the image metadata after import
  Future<void> saveEvidence(PaymentEvidence evidence) async {
    final db = await _dbHelper.database;
    await db.insert(
      'payment_evidences',
      {
        'id': evidence.id,
        'imagePath': evidence.imagePath,
        'importedAt': evidence.importedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save the transaction data extracted from the image
  Future<void> savePaymentEvent(PaymentEvent event) async {
    final db = await _dbHelper.database;
    await db.insert(
      'payment_events',
      {
        'id': event.id,
        'evidenceId': event.evidenceId,
        'amount': event.amount,
        'timestamp': event.timestamp.toIso8601String(),
        'providerName': event.providerName,
        'referenceNumber': event.referenceNumber,
        'rawText': event.rawText,
        'extractionConfidence': event.extractionConfidence,
        'status': event.status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all payment events for a specific day to show in the list
  Future<List<PaymentEvent>> getPaymentsByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final String dateStr = date.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'payment_events',
      where: "timestamp LIKE ?",
      whereArgs: ['$dateStr%'],
      orderBy: "timestamp DESC",
    );

    return List.generate(maps.length, (i) {
      return PaymentEvent(
        id: maps[i]['id'] as String,
        evidenceId: maps[i]['evidenceId'] as String,
        amount: maps[i]['amount'] as double,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        providerName: maps[i]['providerName'] as String,
        referenceNumber: maps[i]['referenceNumber'] as String,
        rawText: maps[i]['rawText'] as String,
        extractionConfidence: maps[i]['extractionConfidence'] as double,
        status: maps[i]['status'] as String,
      );
    });
  }
}