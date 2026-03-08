import 'package:sqflite/sqflite.dart';
import '../../models/merchant.dart';
import '../local/database.dart';

class MerchantRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> createMerchant(Merchant merchant) async {
    final db = await _dbHelper.database;
    await db.insert(
      'merchants',
      {
        'id': merchant.id,
        'name': merchant.name,
        'businessType': merchant.businessType,
        'createdAt': merchant.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Merchant?> getMerchant() async {
    final db = await _dbHelper.database;
    final maps = await db.query('merchants', limit: 1);

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Merchant(
        id: map['id'] as String,
        name: map['name'] as String,
        businessType: map['businessType'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    }
    return null;
  }

  Future<void> updateMerchant(Merchant merchant) async {
    final db = await _dbHelper.database;
    await db.update(
      'merchants',
      {
        'name': merchant.name,
        'businessType': merchant.businessType,
      },
      where: 'id = ?',
      whereArgs: [merchant.id],
    );
  }
}