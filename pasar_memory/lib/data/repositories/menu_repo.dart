import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

import '../local/menu_file_cache.dart';
import '../../models/menu_item.dart';
import '../local/database.dart';

class MenuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final MenuFileCache _fileCache = MenuFileCache();

  MenuItem _mapRow(Map<String, dynamic> row) {
    final rawPrice = row['price'];
    return MenuItem(
      id: row['id'] as String,
      name: row['name'] as String,
      price: rawPrice is num ? rawPrice.toDouble() : double.parse(rawPrice.toString()),
      isActive: row['isActive'] == 1 || row['is_active'] == true,
    );
  }

  Future<void> upsertMenuItem(
    MenuItem item, {
    required String accountId,
  }) async {
    // Web: file cache only (SQLite/sqflite not available without web worker setup)
    if (!kIsWeb) {
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
    }
    await _fileCache.upsertItem(accountId, item);
  }

  Future<List<MenuItem>> getAllMenuItems({required String accountId}) async {
    // Web: read directly from file cache
    if (kIsWeb) {
      return _fileCache.loadAll(accountId);
    }

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'menu_items',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    final localItems = List.generate(maps.length, (i) => _mapRow(maps[i]));

    if (localItems.isNotEmpty) {
      unawaited(_fileCache.saveAll(accountId, localItems));
    }

    return localItems;
  }

  Future<void> toggleMenuItemStatus(
    String id,
    bool isActive, {
    required String accountId,
  }) async {
    if (!kIsWeb) {
      final db = await _dbHelper.database;
      await db.update(
        'menu_items',
        {'isActive': isActive ? 1 : 0},
        where: 'id = ? AND accountId = ?',
        whereArgs: [id, accountId],
      );
    }
    await _fileCache.setActive(accountId, id, isActive);
  }

  Future<void> deleteMenuItem(
    String id, {
    required String accountId,
  }) async {
    if (!kIsWeb) {
      final db = await _dbHelper.database;
      await db.delete(
        'menu_items',
        where: 'id = ? AND accountId = ?',
        whereArgs: [id, accountId],
      );
    }
    await _fileCache.removeItem(accountId, id);
  }
}