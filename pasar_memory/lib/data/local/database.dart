import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pasar_memory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE merchants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        businessType TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_events (
        id TEXT PRIMARY KEY,
        items TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_evidences (
        id TEXT PRIMARY KEY,
        imagePath TEXT NOT NULL,
        importedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_events (
        id TEXT PRIMARY KEY,
        evidenceId TEXT NOT NULL,
        amount REAL NOT NULL,
        timestamp TEXT NOT NULL,
        providerName TEXT NOT NULL,
        referenceNumber TEXT NOT NULL,
        rawText TEXT NOT NULL,
        extractionConfidence REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE match_records (
        id TEXT PRIMARY KEY,
        paymentEventId TEXT NOT NULL,
        orderEventId TEXT NOT NULL,
        confidenceScore REAL NOT NULL,
        reasons TEXT NOT NULL,
        matchedAt TEXT NOT NULL,
        isManualCorrection INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE correction_records (
        id TEXT PRIMARY KEY,
        matchRecordId TEXT NOT NULL,
        oldOrderEventId TEXT NOT NULL,
        newOrderEventId TEXT NOT NULL,
        reason TEXT NOT NULL,
        correctedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_summaries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        totalSales REAL NOT NULL,
        digitalTotal REAL NOT NULL,
        cashEstimate REAL NOT NULL,
        unresolvedCount INTEGER NOT NULL,
        isConfirmed INTEGER NOT NULL
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}