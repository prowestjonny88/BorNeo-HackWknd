import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/database.dart';

class SyncService {
  final _supabase = Supabase.instance.client;
  final _dbHelper = DatabaseHelper.instance;

  Future<void> syncDailyLedgers() async {
    final db = await _dbHelper.database;
    // Get unconfirmed or new ledgers
    final List<Map<String, dynamic>> localLedgers = await db.query('daily_ledgers');

    for (var ledger in localLedgers) {
      try {
        await _supabase.from('daily_summaries').upsert(ledger);
      } catch (e) {
        print('Sync failed for ledger ${ledger['id']}: $e');
      }
    }
  }

  Future<void> uploadEvidenceFile(String filePath, String fileName) async {
    try {
      // Logic for uploading the actual image/audio file to Supabase Storage
      // final file = File(filePath);
      // await _supabase.storage.from('evidence').upload(fileName, file);
    } catch (e) {
      print('File upload failed: $e');
    }
  }
}