import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../models/order_event.dart';
import '../../models/menu_item.dart';
import '../local/database.dart';

class OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create an order from tap inputs
  Future<void> createOrder(OrderEvent order) async {
    final db = await _dbHelper.database;
    await db.insert(
      'order_events',
      {
        'id': order.id,
        // Convert the list of items to a JSON string for storage
        'items': jsonEncode(order.items.map((e) => e.toJson()).toList()),
        'totalAmount': order.totalAmount,
        'timestamp': order.timestamp.toIso8601String(),
        'status': order.status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // List all orders for a specific day
  Future<List<OrderEvent>> getOrdersByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final String dateStr = date.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'order_events',
      where: "timestamp LIKE ?",
      whereArgs: ['$dateStr%'],
      orderBy: "timestamp DESC",
    );

    return List.generate(maps.length, (i) {
      final List<dynamic> itemsJson = jsonDecode(maps[i]['items'] as String);
      return OrderEvent(
        id: maps[i]['id'] as String,
        items: itemsJson.map((e) => MenuItem.fromJson(e)).toList(),
        totalAmount: maps[i]['totalAmount'] as double,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        status: maps[i]['status'] as String,
      );
    });
  }

  // Update order status (e.g., 'matched', 'pending')
  Future<void> updateOrderStatus(String id, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'order_events',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}