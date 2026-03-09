import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/menu_item.dart';
import 'supabase_client.dart';

class SupabaseAccountService {
  SupabaseClient get _client => SupabaseClientProvider.client;

  bool get isConfigured => SupabaseClientProvider.isConfigured;

  User? get currentUser => isConfigured ? _client.auth.currentUser : null;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  String normalizePhone(String rawPhone) {
    return rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  void _validateEmail(String email) {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty || !_emailPattern.hasMatch(trimmed)) {
      throw const FormatException('Please provide a valid email address.');
    }
  }

  void _validatePassword(String password) {
    if (password.trim().length < 6) {
      throw const FormatException('Password must be at least 6 characters.');
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    _validateEmail(email);
    _validatePassword(password);
    try {
      return await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } catch (e, st) {
      debugPrint('SupabaseAccountService.signUp failed: $e\n$st');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _validateEmail(email);
    if (password.trim().isEmpty) {
      throw const FormatException('Password is required.');
    }
    try {
      return await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } catch (e, st) {
      debugPrint('SupabaseAccountService.signIn failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    return _client.from('profiles').select().eq('id', user.id).maybeSingle();
  }

  Future<String?> lookupEmailByPhone(String phoneOrRaw) async {
    final phone = normalizePhone(phoneOrRaw);
    if (phone.isEmpty) {
      return null;
    }

    try {
      final result = await _client.rpc('resolve_login_email_by_phone', params: {
        'input_phone': phone,
      });

      if (result is String && result.trim().isNotEmpty) {
        final email = result.trim().toLowerCase();
        if (_emailPattern.hasMatch(email)) {
          return email;
        }
      }
      return null;
    } catch (e, st) {
      debugPrint('SupabaseAccountService.lookupEmailByPhone failed: $e\n$st');
      return null;
    }
  }

  Future<void> upsertProfile({
    required String displayName,
    required String businessName,
    required String businessType,
    required String preferredLanguage,
    required String email,
    String? phone,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('No authenticated Supabase user.');
    }

    if (displayName.trim().isEmpty) {
      throw const FormatException('Display name is required.');
    }
    if (businessName.trim().isEmpty) {
      throw const FormatException('Business name is required.');
    }
    if (businessType.trim().isEmpty) {
      throw const FormatException('Business type is required.');
    }
    _validateEmail(email);

    await _client.from('profiles').upsert({
      'id': user.id,
      'display_name': displayName.trim(),
      'business_name': businessName.trim(),
      'business_type': businessType.trim(),
      'preferred_language': preferredLanguage.trim().isEmpty ? 'English' : preferredLanguage.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone?.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<MenuItem>> fetchMenuItems() async {
    final user = currentUser;
    if (user == null) {
      return const <MenuItem>[];
    }

    final rows = await _client
        .from('menu_items')
        .select()
        .eq('user_id', user.id)
        .order('name');

    return rows
        .map<MenuItem>(
          (row) => MenuItem(
            id: row['id'] as String,
            name: row['name'] as String,
            price: (row['price'] as num).toDouble(),
            isActive: row['is_active'] as bool? ?? true,
          ),
        )
        .toList(growable: false);
  }

  Future<void> upsertMenuItem(MenuItem item) async {
    final user = currentUser;
    if (user == null) {
      return;
    }

    if (item.name.trim().isEmpty) {
      throw const FormatException('Menu item name is required.');
    }
    if (!item.price.isFinite || item.price <= 0) {
      throw const FormatException('Menu item price must be greater than 0.');
    }

    try {
      await _client.from('menu_items').upsert({
        'id': item.id,
        'user_id': user.id,
        'name': item.name.trim(),
        'price': item.price,
        'is_active': item.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e, st) {
      debugPrint('SupabaseAccountService.upsertMenuItem failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> deleteMenuItem(String id) async {
    final user = currentUser;
    if (user == null) {
      return;
    }

    if (id.trim().isEmpty) {
      throw const FormatException('Menu item id is required.');
    }

    try {
      await _client.from('menu_items').delete().eq('id', id).eq('user_id', user.id);
    } catch (e, st) {
      debugPrint('SupabaseAccountService.deleteMenuItem failed: $e\n$st');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDailySummaries({int limit = 14}) async {
    final user = currentUser;
    if (user == null) {
      return const <Map<String, dynamic>>[];
    }

    final rows = await _client
        .from('daily_summaries')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false)
        .limit(limit);

    return rows.cast<Map<String, dynamic>>();
  }

  Future<void> upsertDailySummary(Map<String, dynamic> ledger) async {
    final user = currentUser;
    if (user == null) {
      return;
    }

    await _client.from('daily_summaries').upsert({
      'id': ledger['id'],
      'user_id': user.id,
      'date': ledger['date'],
      'total_sales': ledger['totalSales'],
      'digital_total': ledger['digitalTotal'],
      'cash_estimate': ledger['cashEstimate'],
      'unresolved_count': ledger['unresolvedCount'],
      'is_confirmed': ledger['isConfirmed'] == 1 || ledger['isConfirmed'] == true,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}