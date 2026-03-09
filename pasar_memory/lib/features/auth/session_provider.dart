import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/repository_providers.dart';
import '../../models/merchant.dart';

enum SessionTimeOfDay {
  morning,
  afternoon,
  evening,
  night,
}

enum LoginTarget {
  register,
  menuSetup,
  home,
}

class SessionState {
  static const String localGuestAccountId = 'local-device';

  const SessionState({
    this.isReady = false,
    this.isBusy = false,
    this.isLoggedIn = false,
    this.accountId = '',
    this.displayName = 'Your Name',
    this.businessName = 'Your Stall',
    this.businessType = 'Hawker',
    this.preferredLanguage = 'English',
    this.phoneOrEmail = '',
    this.menuSetupComplete = false,
    this.totalTapCount = 0,
    this.errorMessage,
  });

  final bool isReady;
  final bool isBusy;
  final bool isLoggedIn;
  final String accountId;
  final String displayName;
  final String businessName;
  final String businessType;
  final String preferredLanguage;
  final String phoneOrEmail;
  final bool menuSetupComplete;
  final int totalTapCount;
  final String? errorMessage;

  String get accountKey {
    if (accountId.isNotEmpty) return accountId;
    final normalized = normalizeAccountKey(phoneOrEmail);
    if (normalized.isNotEmpty) return normalized;
    return localGuestAccountId;
  }

  SessionTimeOfDay get timeOfDay {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return SessionTimeOfDay.morning;
    if (hour >= 12 && hour < 18) return SessionTimeOfDay.afternoon;
    if (hour >= 18 && hour < 21) return SessionTimeOfDay.evening;
    return SessionTimeOfDay.night;
  }

  bool get isNight => timeOfDay == SessionTimeOfDay.night;

  SessionState copyWith({
    bool? isReady,
    bool? isBusy,
    bool? isLoggedIn,
    String? accountId,
    String? displayName,
    String? businessName,
    String? businessType,
    String? preferredLanguage,
    String? phoneOrEmail,
    bool? menuSetupComplete,
    int? totalTapCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionState(
      isReady: isReady ?? this.isReady,
      isBusy: isBusy ?? this.isBusy,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      accountId: accountId ?? this.accountId,
      displayName: displayName ?? this.displayName,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      phoneOrEmail: phoneOrEmail ?? this.phoneOrEmail,
      menuSetupComplete: menuSetupComplete ?? this.menuSetupComplete,
      totalTapCount: totalTapCount ?? this.totalTapCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SessionController extends Notifier<SessionState> {
  static const _displayNameKey = 'session.displayName';
  static const _businessNameKey = 'session.businessName';
  static const _businessTypeKey = 'session.businessType';
  static const _preferredLanguageKey = 'session.preferredLanguage';
  static const _phoneOrEmailKey = 'session.phoneOrEmail';
  static const _accountIdKey = 'session.accountId';
  static const _accountAuthEmailKey = 'session.accountAuthEmail';
  static const _phoneToEmailPrefix = 'session.phoneToEmail';
  static const _phoneToAccountPrefix = 'session.phoneToAccount';
  static const _isLoggedInKey = 'session.isLoggedIn';
  static const _menuSetupCompleteKey = 'session.menuSetupComplete';
  int _mutationCounter = 0;
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  String _scopedKey(String baseKey, String accountId) => '$baseKey.$accountId';

  String _normalizePhoneKey(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  String _phoneToEmailKey(String normalizedPhone) => '$_phoneToEmailPrefix.$normalizedPhone';

  String _phoneToAccountKey(String normalizedPhone) => '$_phoneToAccountPrefix.$normalizedPhone';

  @override
  SessionState build() {
    Future.microtask(_bootstrap);
    return const SessionState();
  }

  String _resolvedDisplayName({
    required SharedPreferences prefs,
    String fallback = 'Your Name',
    String? accountId,
  }) {
    final scopedSavedName = accountId == null || accountId.isEmpty
        ? null
        : prefs.getString(_scopedKey(_displayNameKey, accountId))?.trim();
    if (scopedSavedName != null && scopedSavedName.isNotEmpty) {
      return scopedSavedName;
    }

    final savedName = prefs.getString(_displayNameKey)?.trim();
    if (savedName != null && savedName.isNotEmpty) {
      return savedName;
    }

    return fallback;
  }

  bool _hasStoredAccount(SharedPreferences prefs, String accountId) {
    if (accountId.isEmpty) {
      return false;
    }

    final displayName = prefs.getString(_scopedKey(_displayNameKey, accountId))?.trim();
    final businessName = prefs.getString(_scopedKey(_businessNameKey, accountId))?.trim();
    return (displayName != null && displayName.isNotEmpty) || (businessName != null && businessName.isNotEmpty);
  }

  void _syncMerchantProfile({
    required String accountId,
    required String businessName,
    required String businessType,
  }) {
    if (accountId.isEmpty) {
      return;
    }

    unawaited(() async {
      try {
        final merchantRepo = ref.read(merchantRepositoryProvider);
        final existing = await merchantRepo.getMerchant(accountId: accountId).timeout(const Duration(seconds: 2));
        final merchant = Merchant(
          id: accountId,
          name: businessName,
          businessType: businessType,
          createdAt: existing?.createdAt ?? DateTime.now(),
        );

        if (existing == null) {
          await merchantRepo.createMerchant(merchant).timeout(const Duration(seconds: 2));
        } else {
          await merchantRepo.updateMerchant(merchant).timeout(const Duration(seconds: 2));
        }
      } catch (_) {
        // Auth must not block on best-effort local profile sync.
      }
    }());
  }

  Future<void> _bootstrap() async {
    final mutationAtStart = _mutationCounter;
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final supabaseService = ref.read(supabaseAccountServiceProvider);
      final remoteUser = supabaseService.currentUser;
      final savedPhoneOrEmail = prefs.getString(_phoneOrEmailKey) ?? remoteUser?.email ?? '';
      final accountId = prefs.getString(_accountIdKey) ?? remoteUser?.id ?? normalizeAccountKey(savedPhoneOrEmail);
      Map<String, dynamic>? remoteProfile;

      if (supabaseService.isConfigured && remoteUser != null) {
        try {
          remoteProfile = await supabaseService.fetchProfile().timeout(const Duration(seconds: 3));
        } catch (_) {
          remoteProfile = null;
        }
      }

      var menuSetupComplete = accountId.isNotEmpty
          ? (prefs.getBool(_scopedKey(_menuSetupCompleteKey, accountId)) ?? false)
          : false;
      if (!menuSetupComplete && remoteUser != null) {
        try {
          final items = await ref.read(menuRepositoryProvider).getAllMenuItems(accountId: accountId).timeout(const Duration(seconds: 3));
          menuSetupComplete = items.isNotEmpty;
          if (menuSetupComplete) {
            await prefs.setBool(_scopedKey(_menuSetupCompleteKey, accountId), true);
          }
        } catch (_) {
          // Leave menu setup status as the last known local value.
        }
      }

      if (mutationAtStart != _mutationCounter) {
        return;
      }

      state = state.copyWith(
        isReady: true,
        isBusy: false,
        isLoggedIn: remoteUser != null || (prefs.getBool(_isLoggedInKey) ?? false),
        accountId: accountId,
        displayName: accountId.isEmpty
            ? 'Your Name'
            : (remoteProfile?['display_name'] as String? ?? _resolvedDisplayName(prefs: prefs, accountId: accountId)),
        businessName: accountId.isEmpty
            ? 'Your Stall'
            : (remoteProfile?['business_name'] as String? ?? prefs.getString(_scopedKey(_businessNameKey, accountId)) ?? 'Your Stall'),
        businessType: accountId.isEmpty
            ? 'Hawker'
            : (remoteProfile?['business_type'] as String? ?? prefs.getString(_scopedKey(_businessTypeKey, accountId)) ?? 'Hawker'),
        preferredLanguage: accountId.isEmpty
            ? 'English'
            : (remoteProfile?['preferred_language'] as String? ?? prefs.getString(_scopedKey(_preferredLanguageKey, accountId)) ?? 'English'),
        phoneOrEmail: remoteProfile?['email'] as String? ?? savedPhoneOrEmail,
        menuSetupComplete: menuSetupComplete,
      );
    } catch (_) {
      if (mutationAtStart != _mutationCounter) {
        return;
      }
      state = state.copyWith(
        isReady: true,
        isBusy: false,
        errorMessage: 'Could not restore your session.',
      );
      return;
    }
  }

  Future<void> register({
    required String displayName,
    required String phoneOrEmail,
    required String password,
    required String businessName,
    required String businessType,
    required String preferredLanguage,
    String? email,
  }) async {
    _mutationCounter++;
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final normalizedDisplayName = displayName.trim();
      final normalizedBusinessName = businessName.trim();
      final normalizedBusinessType = businessType.trim();
      final normalizedPhoneOrEmail = phoneOrEmail.trim();
      final normalizedEmail = (email ?? '').trim().toLowerCase();

      if (normalizedDisplayName.isEmpty) {
        state = state.copyWith(errorMessage: 'Display name is required.');
        return;
      }
      if (normalizedBusinessName.isEmpty) {
        state = state.copyWith(errorMessage: 'Business name is required.');
        return;
      }
      if (normalizedBusinessType.isEmpty) {
        state = state.copyWith(errorMessage: 'Business type is required.');
        return;
      }
      if (normalizedPhoneOrEmail.isEmpty) {
        state = state.copyWith(errorMessage: 'Phone number or email is required.');
        return;
      }
      if (password.trim().length < 6) {
        state = state.copyWith(errorMessage: 'Password must be at least 6 characters.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final supabaseService = ref.read(supabaseAccountServiceProvider);
      final authEmail = normalizedEmail.isNotEmpty
          ? normalizedEmail
          : (normalizedPhoneOrEmail.contains('@') ? normalizedPhoneOrEmail.toLowerCase() : '');
      var accountId = normalizeAccountKey(normalizedPhoneOrEmail);
      var identityValue = normalizedPhoneOrEmail;

      if (supabaseService.isConfigured) {
        if (authEmail.isEmpty || !_emailPattern.hasMatch(authEmail)) {
          state = state.copyWith(errorMessage: 'Valid email is required for cloud account sync.');
          return;
        }

        final authResponse = await supabaseService.signUp(
          email: authEmail,
          password: password,
        ).timeout(const Duration(seconds: 8));

        final authUser = authResponse.user ?? supabaseService.currentUser;
        if (authUser == null) {
          state = state.copyWith(errorMessage: 'Registration needs email confirmation before sign in.');
          return;
        }

        accountId = authUser.id;
        identityValue = authUser.email ?? authEmail;
        await supabaseService.upsertProfile(
          displayName: displayName,
          businessName: normalizedBusinessName,
          businessType: normalizedBusinessType,
          preferredLanguage: preferredLanguage,
          email: authEmail,
          phone: normalizedPhoneOrEmail.contains('@') ? null : normalizedPhoneOrEmail,
        ).timeout(const Duration(seconds: 8));
      }

      await prefs.setString(_displayNameKey, normalizedDisplayName);
      await prefs.setString(_accountIdKey, accountId);
      await prefs.setString(_scopedKey(_displayNameKey, accountId), normalizedDisplayName);
      await prefs.setString(_scopedKey(_businessNameKey, accountId), normalizedBusinessName);
      await prefs.setString(_scopedKey(_businessTypeKey, accountId), normalizedBusinessType);
      await prefs.setString(_scopedKey(_preferredLanguageKey, accountId), preferredLanguage);
      await prefs.setString(_scopedKey(_accountAuthEmailKey, accountId), authEmail);
      await prefs.setString(_phoneOrEmailKey, identityValue);
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setBool(_scopedKey(_menuSetupCompleteKey, accountId), false);

      final phoneLookup = _normalizePhoneKey(normalizedPhoneOrEmail);
      if (phoneLookup.isNotEmpty && authEmail.isNotEmpty) {
        await prefs.setString(_phoneToEmailKey(phoneLookup), authEmail);
        await prefs.setString(_phoneToAccountKey(phoneLookup), accountId);
      }

      state = state.copyWith(
        isReady: true,
        isLoggedIn: true,
        accountId: accountId,
        displayName: normalizedDisplayName,
        businessName: normalizedBusinessName,
        businessType: normalizedBusinessType,
        preferredLanguage: preferredLanguage,
        phoneOrEmail: identityValue,
        menuSetupComplete: false,
      );

      _syncMerchantProfile(
        accountId: accountId,
        businessName: normalizedBusinessName,
        businessType: normalizedBusinessType,
      );
      return;
    } catch (e, st) {
      debugPrint('SessionController.register failed: $e\n$st');
      state = state.copyWith(errorMessage: 'Could not create account.');
      return;
    } finally {
      if (state.isBusy) {
        state = state.copyWith(isBusy: false);
      }
    }
  }

  Future<LoginTarget> login({
    required String phoneOrEmail,
    required String password,
  }) async {
    _mutationCounter++;
    state = state.copyWith(isBusy: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (phoneOrEmail.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Enter your login details.');
      return LoginTarget.register;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final supabaseService = ref.read(supabaseAccountServiceProvider);
      var accountId = normalizeAccountKey(phoneOrEmail.trim());
      var identityValue = phoneOrEmail.trim();

      if (supabaseService.isConfigured) {
        final input = phoneOrEmail.trim();
        var authEmail = input.toLowerCase();

        if (!_emailPattern.hasMatch(authEmail)) {
          // Cross-device path: resolve phone from cloud-side profile mapping.
          final resolvedFromCloud = await supabaseService.lookupEmailByPhone(input);
          if (resolvedFromCloud != null && _emailPattern.hasMatch(resolvedFromCloud)) {
            authEmail = resolvedFromCloud;
          }

          final phoneLookup = _normalizePhoneKey(input);
          final mappedAccountId = phoneLookup.isEmpty ? '' : (prefs.getString(_phoneToAccountKey(phoneLookup)) ?? '');
          var mappedEmail = phoneLookup.isEmpty ? '' : (prefs.getString(_phoneToEmailKey(phoneLookup)) ?? '');
          if (mappedEmail.isEmpty && mappedAccountId.isNotEmpty) {
            mappedEmail = prefs.getString(_scopedKey(_accountAuthEmailKey, mappedAccountId)) ?? '';
          }

          if (!_emailPattern.hasMatch(authEmail)) {
            if (mappedEmail.isNotEmpty && _emailPattern.hasMatch(mappedEmail)) {
              authEmail = mappedEmail;
            }
          }

          if (mappedEmail.isEmpty && mappedAccountId.isNotEmpty) {
            // Keep previous local mapping behavior when available.
            accountId = mappedAccountId;
          }

          if (authEmail.isEmpty || !_emailPattern.hasMatch(authEmail)) {
            state = state.copyWith(
              errorMessage: 'This phone number is not linked yet. Please login once with email on this project, then phone login will work everywhere.',
            );
            return LoginTarget.register;
          }
        }

        final authResponse = await supabaseService.signIn(
          email: authEmail,
          password: password,
        ).timeout(const Duration(seconds: 8));
        final authUser = authResponse.user;
        if (authUser == null) {
          state = state.copyWith(errorMessage: 'Could not sign in with Supabase.');
          return LoginTarget.register;
        }

        accountId = authUser.id;
        identityValue = authUser.email ?? authEmail;
        await prefs.setString(_scopedKey(_accountAuthEmailKey, accountId), authEmail);

        final phoneLookup = _normalizePhoneKey(input);
        if (phoneLookup.isNotEmpty) {
          await prefs.setString(_phoneToEmailKey(phoneLookup), authEmail);
          await prefs.setString(_phoneToAccountKey(phoneLookup), accountId);
        }
      }

      if (!_hasStoredAccount(prefs, accountId)) {
        if (supabaseService.isConfigured && supabaseService.currentUser != null) {
          try {
            final remoteProfile = await supabaseService.fetchProfile().timeout(const Duration(seconds: 3));
            if (remoteProfile != null) {
              await prefs.setString(_accountIdKey, accountId);
              await prefs.setString(_scopedKey(_displayNameKey, accountId), remoteProfile['display_name'] as String? ?? '');
              await prefs.setString(_scopedKey(_businessNameKey, accountId), remoteProfile['business_name'] as String? ?? '');
              await prefs.setString(_scopedKey(_businessTypeKey, accountId), remoteProfile['business_type'] as String? ?? 'Hawker');
              await prefs.setString(_scopedKey(_preferredLanguageKey, accountId), remoteProfile['preferred_language'] as String? ?? 'English');
            }
          } catch (_) {}
        }

        if (!_hasStoredAccount(prefs, accountId)) {
          state = state.copyWith(errorMessage: 'No account found yet. Register first.');
          return LoginTarget.register;
        }
      }

      await prefs.setString(_accountIdKey, accountId);
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_phoneOrEmailKey, identityValue);

      var menuSetupComplete = prefs.getBool(_scopedKey(_menuSetupCompleteKey, accountId)) ?? false;
      if (!menuSetupComplete && supabaseService.currentUser != null) {
        try {
          final items = await ref.read(menuRepositoryProvider).getAllMenuItems(accountId: accountId).timeout(const Duration(seconds: 3));
          menuSetupComplete = items.isNotEmpty;
          if (menuSetupComplete) {
            await prefs.setBool(_scopedKey(_menuSetupCompleteKey, accountId), true);
          }
        } catch (_) {
          // Keep the cached onboarding state if remote hydration fails.
        }
      }

      state = state.copyWith(
        isLoggedIn: true,
        isReady: true,
        accountId: accountId,
        phoneOrEmail: identityValue,
        businessName: prefs.getString(_scopedKey(_businessNameKey, accountId)) ?? state.businessName,
        businessType: prefs.getString(_scopedKey(_businessTypeKey, accountId)) ?? state.businessType,
        displayName: prefs.getString(_scopedKey(_displayNameKey, accountId)) ?? _resolvedDisplayName(
              prefs: prefs,
              accountId: accountId,
              fallback: state.displayName,
            ),
        menuSetupComplete: menuSetupComplete,
      );

      return menuSetupComplete ? LoginTarget.home : LoginTarget.menuSetup;
    } catch (e, st) {
      debugPrint('SessionController.login failed: $e\n$st');
      state = state.copyWith(errorMessage: 'Could not log in.');
      return LoginTarget.register;
    } finally {
      if (state.isBusy) {
        state = state.copyWith(isBusy: false);
      }
    }
  }

  Future<void> completeMenuSetup() async {
    _mutationCounter++;
    final prefs = await SharedPreferences.getInstance();
    final accountId = state.accountKey;
    if (accountId.isNotEmpty) {
      await prefs.setBool(_scopedKey(_menuSetupCompleteKey, accountId), true);
    }
    state = state.copyWith(menuSetupComplete: true);
  }

  void setTotalTapCount(int value) {
    state = state.copyWith(totalTapCount: value);
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);

String normalizeAccountKey(String raw) => raw.trim().toLowerCase();