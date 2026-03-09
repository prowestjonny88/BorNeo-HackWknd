import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/menu_item.dart';

/// Stores menu items locally.
/// - Mobile/Desktop: real JSON file at app-documents/menu_cache/{accountId}.json
/// - Web (Chrome): shared_preferences (no file system available on web)
class MenuFileCache {
  static const _webPrefix = 'menu_cache_v1_';

  // ── Web (shared_preferences) ──────────────────────────────────────────────

  Future<void> _webSaveAll(String accountId, List<MenuItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_webPrefix$accountId',
      jsonEncode(items.map(_toJson).toList()),
    );
  }

  Future<List<MenuItem>> _webLoadAll(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_webPrefix$accountId');
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List).map((e) => _fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _webClear(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_webPrefix$accountId');
  }

  // ── Native (real JSON file) ───────────────────────────────────────────────

  Future<File> _nativeFile(String accountId) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(dir.path, 'menu_cache'));
    if (!cacheDir.existsSync()) await cacheDir.create(recursive: true);
    return File(p.join(cacheDir.path, '$accountId.json'));
  }

  Future<void> _nativeSaveAll(String accountId, List<MenuItem> items) async {
    final file = await _nativeFile(accountId);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(items.map(_toJson).toList()),
      flush: true,
    );
  }

  Future<List<MenuItem>> _nativeLoadAll(String accountId) async {
    final file = await _nativeFile(accountId);
    if (!file.existsSync()) return const [];
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return const [];
      return (jsonDecode(raw) as List).map((e) => _fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _nativeClear(String accountId) async {
    final file = await _nativeFile(accountId);
    if (file.existsSync()) await file.delete();
  }

  // ── Public API (delegates to web or native) ───────────────────────────────

  Future<void> saveAll(String accountId, List<MenuItem> items) =>
      kIsWeb ? _webSaveAll(accountId, items) : _nativeSaveAll(accountId, items);

  Future<List<MenuItem>> loadAll(String accountId) =>
      kIsWeb ? _webLoadAll(accountId) : _nativeLoadAll(accountId);

  Future<void> clear(String accountId) =>
      kIsWeb ? _webClear(accountId) : _nativeClear(accountId);

  Future<void> upsertItem(String accountId, MenuItem item) async {
    final current = await loadAll(accountId);
    final idx = current.indexWhere((m) => m.id == item.id);
    final updated = List<MenuItem>.from(current);
    if (idx >= 0) {
      updated[idx] = item;
    } else {
      updated.add(item);
    }
    await saveAll(accountId, updated);
  }

  Future<void> removeItem(String accountId, String itemId) async {
    final current = await loadAll(accountId);
    await saveAll(accountId, current.where((m) => m.id != itemId).toList());
  }

  Future<void> setActive(String accountId, String itemId, bool isActive) async {
    final current = await loadAll(accountId);
    await saveAll(accountId, current.map((m) {
      if (m.id == itemId) return MenuItem(id: m.id, name: m.name, price: m.price, isActive: isActive);
      return m;
    }).toList());
  }

  /// Returns a debug summary string — handy for verifying the cache.
  Future<String> debugSummary(String accountId) async {
    final items = await loadAll(accountId);
    if (items.isEmpty) return 'Cache is empty (0 items) for account: $accountId';
    final lines = items.map((i) => '  • ${i.name} — RM${i.price.toStringAsFixed(2)} (${i.isActive ? "active" : "inactive"})').join('\n');
    return 'Cache has ${items.length} item(s) for account $accountId:\n$lines';
  }

  Map<String, dynamic> _toJson(MenuItem item) => {
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'isActive': item.isActive,
      };

  MenuItem _fromJson(Map<String, dynamic> map) => MenuItem(
        id: map['id'] as String,
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        isActive: map['isActive'] as bool? ?? true,
      );
}

