import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../local/database.dart';
import 'package:sqflite/sqflite.dart';

import '../remote/supabase_account_service.dart';

class LedgerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SupabaseAccountService _supabaseAccountService = SupabaseAccountService();

  // ── Web (SharedPreferences) helpers ──────────────────────────────────────

  static const _webKeyPrefix = 'ledger_cache_v1_';

  Future<List<Map<String, dynamic>>> _webLoadAll(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_webKeyPrefix$accountId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _webSaveAll(String accountId, List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_webKeyPrefix$accountId', jsonEncode(rows));
  }

  Future<void> _webUpsertLedger(Map<String, dynamic> ledger, String accountId) async {
    final all = await _webLoadAll(accountId);
    final entry = {'accountId': accountId, ...ledger};
    final idx = all.indexWhere((e) => e['id'] == ledger['id']);
    if (idx >= 0) {
      all[idx] = entry;
    } else {
      all.add(entry);
    }
    await _webSaveAll(accountId, all);
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Map<String, dynamic> _mapRemoteLedger(Map<String, dynamic> row, String accountId) {
    return {
      'id': row['id'],
      'accountId': accountId,
      'date': row['date'],
      'totalSales': (row['total_sales'] as num?)?.toDouble() ?? 0,
      'digitalTotal': (row['digital_total'] as num?)?.toDouble() ?? 0,
      'cashEstimate': (row['cash_estimate'] as num?)?.toDouble() ?? 0,
      'unresolvedCount': (row['unresolved_count'] as num?)?.toInt() ?? 0,
      'isConfirmed': (row['is_confirmed'] as bool? ?? false) ? 1 : 0,
    };
  }

  // Merges remote rows into local without deleting any existing local rows.
  Future<void> _mergeRemote(Database db, List<Map<String, dynamic>> ledgers) async {
    if (ledgers.isEmpty) return;
    final batch = db.batch();
    for (final ledger in ledgers) {
      batch.insert('daily_ledgers', ledger, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> upsertLedger(Map<String, dynamic> ledger, {required String accountId}) async {
    if (kIsWeb) {
      await _webUpsertLedger(ledger, accountId);
      return;
    }

    final db = await _dbHelper.database;
    await db.insert(
      'daily_ledgers',
      {
        ...ledger,
        'accountId': accountId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (_supabaseAccountService.currentUser?.id == accountId) {
      try {
        await _supabaseAccountService.upsertDailySummary({
          ...ledger,
          'accountId': accountId,
        }).timeout(const Duration(seconds: 2));
      } catch (_) {
        // Local ledger save succeeds even when remote sync is unavailable.
      }
    }
  }

  Future<Map<String, dynamic>?> getLedgerByDate(DateTime date, {required String accountId}) async {
    final dateStr = date.toIso8601String().split('T')[0];

    if (kIsWeb) {
      final all = await _webLoadAll(accountId);
      try {
        return all.firstWhere((e) => e['date'] == dateStr);
      } catch (_) {
        return null;
      }
    }

    final db = await _dbHelper.database;
    final maps = await db.query(
      'daily_ledgers',
      where: 'accountId = ? AND date = ?',
      whereArgs: [accountId, dateStr],
    );

    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getRecentLedgers({required String accountId}) async {
    if (kIsWeb) {
      final all = await _webLoadAll(accountId);
      all.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return all;
    }

    final db = await _dbHelper.database;

    if (_supabaseAccountService.currentUser?.id == accountId) {
      try {
        final remoteRows = await _supabaseAccountService
            .fetchDailySummaries(limit: 1000)
            .timeout(const Duration(seconds: 2));
        final mappedRows = remoteRows
            .map((row) => _mapRemoteLedger(row, accountId))
            .toList(growable: false);
        // Merge remote into local — never delete existing local rows.
        await _mergeRemote(db, mappedRows);
      } catch (_) {
        // Remote fetch failed; continue with local data.
      }
    }

    return db.query(
      'daily_ledgers',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
  }

  Future<void> deleteLedger(String id, {required String accountId}) async {
    if (kIsWeb) {
      final all = await _webLoadAll(accountId);
      all.removeWhere((e) => e['id'] == id);
      await _webSaveAll(accountId, all);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete(
      'daily_ledgers',
      where: 'id = ? AND accountId = ?',
      whereArgs: [id, accountId],
    );
  }

  Future<void> updateLedger(
    String id,
    Map<String, dynamic> updates, {
    required String accountId,
  }) async {
    if (kIsWeb) {
      final all = await _webLoadAll(accountId);
      final idx = all.indexWhere((e) => e['id'] == id);
      if (idx >= 0) {
        all[idx] = {...all[idx], ...updates, 'id': id, 'accountId': accountId};
        await _webSaveAll(accountId, all);
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.update(
      'daily_ledgers',
      updates,
      where: 'id = ? AND accountId = ?',
      whereArgs: [id, accountId],
    );
  }
}
