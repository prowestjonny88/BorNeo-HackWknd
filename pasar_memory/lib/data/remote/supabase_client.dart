import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool _initialized = false;

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (_initialized || !isConfigured) {
      return;
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _initialized = true;
  }

  static final client = Supabase.instance.client;
}