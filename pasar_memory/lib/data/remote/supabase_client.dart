import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Replace with your actual Supabase project credentials.
// Get them from: https://supabase.com/dashboard -> Project Settings -> API
const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://placeholder.supabase.co',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'placeholder-anon-key',
);

class SupabaseClientProvider {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}