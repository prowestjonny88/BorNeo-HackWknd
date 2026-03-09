import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> configureDatabaseFactoryImpl() async {
  // Use no-worker mode — avoids needing sqflite_sw.js in the web folder.
  // SQLite runs on the main thread via WASM; fine for this app's data size.
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
