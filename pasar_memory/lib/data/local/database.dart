import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pasar_memory_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const idType = 'TEXT PRIMARY KEY';

    // 1.1.2 Merchant Profile
    await db.execute('''
      CREATE TABLE merchants (
        id $idType,
        name $textType,
        businessType $textType,
        createdAt $textType
      )
    ''');

    // 1.1.3 Menu Items & Aliases
    await db.execute('''
      CREATE TABLE menu_items (
        id $idType,
        name $textType,
        price $realType,
        isActive $boolType
      )
    ''');

    // 1.1.4 Daily Evidence (Screenshots, Audio, Exports)
    await db.execute('''
      CREATE TABLE daily_evidence (
        id $idType,
        type $textType, 
        filePath $textType,
        timestamp $textType
      )
    ''');

    // 1.1.5 Extraction Results (OCR & Export Parsing)
    await db.execute('''
      CREATE TABLE extraction_records (
        id $idType,
        evidenceId $textType,
        rawText $textType,
        amount $realType,
        referenceNumber $textType,
        confidence $realType,
        status $textType
      )
    ''');

    // 1.1.6 Transcript Records & Parsed Recaps
    await db.execute('''
      CREATE TABLE transcript_records (
        id $idType,
        evidenceId $textType,
        rawText $textType,
        parsedJson $textType,
        confidence $realType
      )
    ''');

    // 1.1.7 Daily Ledger
    await db.execute('''
      CREATE TABLE daily_ledgers (
        id $idType,
        date $textType,
        totalSales $realType,
        digitalTotal $realType,
        cashEstimate $realType,
        unresolvedCount INTEGER NOT NULL,
        isConfirmed $boolType
      )
    ''');

    // 1.1.8 Correction Records
    await db.execute('''
      CREATE TABLE correction_records (
        id $idType,
        dayId $textType,
        fieldName $textType,
        oldValue $textType,
        newValue $textType,
        reason $textType,
        timestamp $textType
      )
    ''');

    // Tap Entries (Quick input during selling)
    await db.execute('''
      CREATE TABLE tap_entries (
        id $idType,
        menuItemId $textType,
        timestamp $textType,
        amount $realType
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}