import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../remote/supabase_account_service.dart';
import '../../models/menu_item.dart';
import '../local/database.dart';

enum MenuCloudSyncState { pending, synced, failed }

typedef MenuCloudSyncCallback = void Function(MenuCloudSyncState state);

class MenuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SupabaseAccountService _supabaseAccountService = SupabaseAccountService();

  MenuItem _mapRow(Map<String, dynamic> row) {
    final rawPrice = row['price'];
    return MenuItem(
      id: row['id'] as String,
      name: row['name'] as String,
      price: rawPrice is num ? rawPrice.toDouble() : double.parse(rawPrice.toString()),
      isActive: row['isActive'] == 1 || row['is_active'] == true,
    );
  }

  Future<void> _replaceSnapshot(Database db, String accountId, List<MenuItem> items) async {
    final batch = db.batch();
    batch.delete('menu_items', where: 'accountId = ?', whereArgs: [accountId]);
    for (final item in items) {
      batch.insert(
        'menu_items',
        {
          'id': item.id,
          'accountId': accountId,
          'name': item.name,
          'price': item.price,
          'isActive': item.isActive ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<MenuItem?> _getMenuItemById(Database db, String id, String accountId) async {
    final rows = await db.query(
      'menu_items',
      where: 'id = ? AND accountId = ?',
      whereArgs: [id, accountId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return _mapRow(rows.first);
  }

  Future<void> upsertMenuItem(
    MenuItem item, {
    required String accountId,
    MenuCloudSyncCallback? onCloudSyncState,
  }) async {
    final db = await _dbHelper.database;
    await db.insert(
      'menu_items',
      {
        'id': item.id,
        'accountId': accountId,
        'name': item.name,
        'price': item.price,
        'isActive': item.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (_supabaseAccountService.currentUser?.id == accountId) {
      // Do not block UI save on network I/O when adding many items.
      onCloudSyncState?.call(MenuCloudSyncState.pending);
      unawaited(_syncUpsertInBackground(item, onCloudSyncState));
    }
  }

  Future<void> _syncUpsertInBackground(
    MenuItem item,
    MenuCloudSyncCallback? onCloudSyncState,
  ) async {
    try {
      await _supabaseAccountService
          .upsertMenuItem(item)
          .timeout(const Duration(seconds: 2));
      onCloudSyncState?.call(MenuCloudSyncState.synced);
    } catch (_) {
      // Local write already succeeded; background sync can retry later.
      onCloudSyncState?.call(MenuCloudSyncState.failed);
    }
  }

  Future<List<MenuItem>> getAllMenuItems({required String accountId}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'menu_items',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    final localItems = List.generate(maps.length, (i) => _mapRow(maps[i]));

    if (_supabaseAccountService.currentUser?.id != accountId) {
      return localItems;
    }

    try {
      final remoteItems = await _supabaseAccountService.fetchMenuItems().timeout(const Duration(seconds: 2));
      if (remoteItems.isNotEmpty || localItems.isEmpty) {
        await _replaceSnapshot(db, accountId, remoteItems);
        return remoteItems;
      }
    } catch (_) {
      // Fall back to local cache when network sync is unavailable.
    }

    return localItems;
  }

  Future<void> toggleMenuItemStatus(
    String id,
    bool isActive, {
    required String accountId,
    MenuCloudSyncCallback? onCloudSyncState,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      'menu_items',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ? AND accountId = ?',
      whereArgs: [id, accountId],
    );

    if (_supabaseAccountService.currentUser?.id == accountId) {
      onCloudSyncState?.call(MenuCloudSyncState.pending);
      unawaited(_syncToggleInBackground(db, id, accountId, onCloudSyncState));
    }
  }

  Future<void> _syncToggleInBackground(
    Database db,
    String id,
    String accountId,
    MenuCloudSyncCallback? onCloudSyncState,
  ) async {
    try {
      final item = await _getMenuItemById(db, id, accountId);
      if (item != null) {
        await _supabaseAccountService
            .upsertMenuItem(item)
            .timeout(const Duration(seconds: 2));
      }
      onCloudSyncState?.call(MenuCloudSyncState.synced);
    } catch (_) {
      // Local state already reflects the action.
      onCloudSyncState?.call(MenuCloudSyncState.failed);
    }
  }

  Future<void> deleteMenuItem(
    String id, {
    required String accountId,
    MenuCloudSyncCallback? onCloudSyncState,
  }) async {
    final db = await _dbHelper.database;
    await db.delete(
      'menu_items',
      where: 'id = ? AND accountId = ?',
      whereArgs: [id, accountId],
    );

    if (_supabaseAccountService.currentUser?.id == accountId) {
      onCloudSyncState?.call(MenuCloudSyncState.pending);
      unawaited(_syncDeleteInBackground(id, onCloudSyncState));
    }
  }

  Future<void> _syncDeleteInBackground(
    String id,
    MenuCloudSyncCallback? onCloudSyncState,
  ) async {
    try {
      await _supabaseAccountService
          .deleteMenuItem(id)
          .timeout(const Duration(seconds: 2));
      onCloudSyncState?.call(MenuCloudSyncState.synced);
    } catch (_) {
      // Ignore transient remote sync failures.
      onCloudSyncState?.call(MenuCloudSyncState.failed);
    }
  }
}