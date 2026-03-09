import 'dart:async';

import '../local/database.dart';
import 'package:sqflite/sqflite.dart';

import '../remote/supabase_account_service.dart';

class LedgerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SupabaseAccountService _supabaseAccountService = SupabaseAccountService();

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

  Future<void> _replaceSnapshot(Database db, String accountId, List<Map<String, dynamic>> ledgers) async {
    final batch = db.batch();
    batch.delete('daily_ledgers', where: 'accountId = ?', whereArgs: [accountId]);
    for (final ledger in ledgers) {
      batch.insert('daily_ledgers', ledger, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsertLedger(Map<String, dynamic> ledger, {required String accountId}) async {
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
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final maps = await db.query(
      'daily_ledgers',
      where: 'accountId = ? AND date = ?',
      whereArgs: [accountId, dateStr],
    );

    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getRecentLedgers({required String accountId, int limit = 14}) async {
    final db = await _dbHelper.database;
    final localRows = await db.query(
      'daily_ledgers',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
      limit: limit,
    );

    if (_supabaseAccountService.currentUser?.id != accountId) {
      return localRows;
    }

    try {
      final remoteRows = await _supabaseAccountService.fetchDailySummaries(limit: limit).timeout(const Duration(seconds: 2));
      final mappedRows = remoteRows.map((row) => _mapRemoteLedger(row, accountId)).toList(growable: false);
      if (mappedRows.isNotEmpty || localRows.isEmpty) {
        await _replaceSnapshot(db, accountId, mappedRows);
        return mappedRows;
      }
    } catch (_) {
      // Use cached ledger history if the remote fetch fails.
    }

    return localRows;
  }
}