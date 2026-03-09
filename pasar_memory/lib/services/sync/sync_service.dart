import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/database.dart';

class SyncService {
  final _supabase = Supabase.instance.client;
  final _dbHelper = DatabaseHelper.instance;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Syncs all local tables to Supabase in parallel.
  Future<void> syncAll() async {
    final uid = _userId;
    if (uid == null) return;

    await Future.wait([
      syncMenuItems(uid),
      syncDailyLedgers(uid),
      syncTapEntries(uid),
      syncDailyEvidence(uid),
      syncExtractionRecords(uid),
      syncTranscriptRecords(uid),
      syncCorrectionRecords(uid),
    ]);
  }

  Future<void> syncMenuItems(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('menu_items', where: 'accountId = ?', whereArgs: [userId]);
    for (final row in rows) {
      try {
        await _supabase.from('menu_items').upsert({
          'id': row['id'],
          'user_id': userId,
          'name': row['name'],
          'price': row['price'],
          'is_active': (row['isActive'] as int? ?? 1) == 1,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // continue on individual row failure
      }
    }
  }

  /// Syncs local daily_ledgers → cloud daily_summaries with proper field mapping.
  Future<void> syncDailyLedgers([String? uid]) async {
    final userId = uid ?? _userId;
    if (userId == null) return;
    final db = await _dbHelper.database;
    final rows = await db.query('daily_ledgers', where: 'accountId = ?', whereArgs: [userId]);
    for (final row in rows) {
      try {
        await _supabase.from('daily_summaries').upsert({
          'id': row['id'],
          'user_id': userId,
          'date': row['date'],
          'total_sales': row['totalSales'],
          'digital_total': row['digitalTotal'],
          'cash_estimate': row['cashEstimate'],
          'unresolved_count': row['unresolvedCount'],
          'is_confirmed': (row['isConfirmed'] as int? ?? 0) == 1,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // continue on individual row failure
      }
    }
  }

  Future<void> syncTapEntries(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('tap_entries', where: 'accountId = ?', whereArgs: [userId]);
    for (final row in rows) {
      try {
        await _supabase.from('tap_entries').upsert({
          'id': row['id'],
          'user_id': userId,
          'menu_item_id': row['menuItemId'],
          'amount': row['amount'],
          'timestamp': row['timestamp'],
        });
      } catch (e) {
        // continue on individual row failure
      }
    }
  }

  Future<void> syncDailyEvidence(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('daily_evidence', where: 'accountId = ?', whereArgs: [userId]);
    for (final row in rows) {
      try {
        await _supabase.from('daily_evidence').upsert({
          'id': row['id'],
          'user_id': userId,
          'type': row['type'],
          'file_path': row['filePath'],
          'timestamp': row['timestamp'],
        });
      } catch (e) {
        // continue on individual row failure
      }
    }
  }

  Future<void> syncExtractionRecords(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('extraction_records', where: 'accountId = ?', whereArgs: [userId]);
    for (final row in rows) {
      try {
        await _supabase.from('extraction_records').upsert({
          'id': row['id'],
          'user_id': userId,
          'evidence_id': row['evidenceId'],
          'raw_text': row['rawText'],
          'amount': row['amount'],
          'reference_number': row['referenceNumber'],
          'confidence': row['confidence'],
          'status': row['status'] ?? 'pending',
        });
      } catch (e) {
        // continue on individual row failure
      }
    }
  }

  Future<void> syncTranscriptRecords(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('transcript_records', where: 'accountId = ?', whereArgs: [userId]);
    for (final row in rows) {
      try {
        await _supabase.from('transcript_records').upsert({
          'id': row['id'],
          'user_id': userId,
          'evidence_id': row['evidenceId'],
          'raw_text': row['rawText'],
          'parsed_json': row['parsedJson'],
          'confidence': row['confidence'],
        });
      } catch (e) {
        // continue on individual row failure
      }
    }
  }

  Future<void> syncCorrectionRecords(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('correction_records', where: 'accountId = ?', whereArgs: [userId]);
    for (final row in rows) {
      try {
        await _supabase.from('correction_records').upsert({
          'id': row['id'],
          'user_id': userId,
          'day_id': row['dayId'],
          'field_name': row['fieldName'],
          'old_value': row['oldValue'],
          'new_value': row['newValue'],
          'reason': row['reason'],
          'timestamp': row['timestamp'],
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // continue on individual row failure
      }
    }
  }

  /// Uploads a local evidence file to the `evidence` Storage bucket.
  /// Returns the signed URL on success, or null on failure.
  Future<String?> uploadEvidenceFile(String localFilePath, String evidenceId) async {
    final userId = _userId;
    if (userId == null) return null;
    try {
      final file = File(localFilePath);
      if (!await file.exists()) return null;
      final ext = localFilePath.contains('.') ? localFilePath.split('.').last : 'bin';
      final storagePath = '$userId/$evidenceId.$ext';
      await _supabase.storage.from('evidence').upload(storagePath, file);
      final signedUrl = await _supabase.storage
          .from('evidence')
          .createSignedUrl(storagePath, 60 * 60 * 24 * 7); // 7-day expiry
      return signedUrl;
    } catch (e) {
      return null;
    }
  }
}