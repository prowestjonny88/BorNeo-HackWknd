import 'package:sqflite/sqflite.dart';
import '../../models/menu_item.dart';
import '../local/database.dart';

class MenuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> upsertMenuItem(MenuItem item) async {
    final db = await _dbHelper.database;
    await db.insert(
      'menu_items',
      {
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'isActive': item.isActive ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MenuItem>> getAllMenuItems() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('menu_items');

    return List.generate(maps.length, (i) {
      return MenuItem(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        price: maps[i]['price'] as double,
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }

  Future<void> toggleMenuItemStatus(String id, bool isActive) async {
    final db = await _dbHelper.database;
    await db.update(
      'menu_items',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMenuItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}