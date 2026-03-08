import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL_HERE',
      anonKey: 'YOUR_SUPABASE_ANON_KEY_HERE',
    );
  }

  static final client = Supabase.instance.client;
}