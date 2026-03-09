import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/local/database_factory_setup.dart';
import 'data/remote/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDatabaseFactory();
  await SupabaseClientProvider.initialize();
  runApp(
    const ProviderScope(
      child: PasarMemoryApp(),
    ),
  );
}