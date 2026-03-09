import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/menu_repo.dart';
import '../../data/repositories/repository_providers.dart';
import '../auth/session_provider.dart';
import '../../models/menu_item.dart';

class MenuSetupState {
  final bool isLoading;
  final bool isSaving;
  final List<MenuItem> items;
  final Map<String, List<String>> aliasesById;
  final MenuCloudSyncState? cloudSyncState;
  final String? cloudSyncMessage;
  final String? errorMessage;

  const MenuSetupState({
    this.isLoading = false,
    this.isSaving = false,
    this.items = const <MenuItem>[],
    this.aliasesById = const <String, List<String>>{},
    this.cloudSyncState,
    this.cloudSyncMessage,
    this.errorMessage,
  });

  MenuSetupState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<MenuItem>? items,
    Map<String, List<String>>? aliasesById,
    MenuCloudSyncState? cloudSyncState,
    String? cloudSyncMessage,
    String? errorMessage,
    bool clearError = false,
    bool clearCloudSync = false,
  }) {
    return MenuSetupState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      items: items ?? this.items,
      aliasesById: aliasesById ?? this.aliasesById,
      cloudSyncState: clearCloudSync ? null : (cloudSyncState ?? this.cloudSyncState),
      cloudSyncMessage: clearCloudSync ? null : (cloudSyncMessage ?? this.cloudSyncMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MenuSetupController extends Notifier<MenuSetupState> {
  static const Uuid _uuid = Uuid();

  String get _accountId => ref.read(sessionProvider).accountKey;

  void _handleCloudSyncState(MenuCloudSyncState syncState) {
    switch (syncState) {
      case MenuCloudSyncState.pending:
        state = state.copyWith(
          cloudSyncState: MenuCloudSyncState.pending,
          cloudSyncMessage: 'Cloud sync pending...',
        );
      case MenuCloudSyncState.synced:
        state = state.copyWith(
          cloudSyncState: MenuCloudSyncState.synced,
          cloudSyncMessage: 'Cloud synced',
        );
      case MenuCloudSyncState.failed:
        state = state.copyWith(
          cloudSyncState: MenuCloudSyncState.failed,
          cloudSyncMessage: 'Cloud sync failed (saved locally)',
        );
    }
  }

  @override
  MenuSetupState build() {
    Future.microtask(_load);
    return const MenuSetupState(isLoading: true);
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (_accountId.isEmpty) {
        state = state.copyWith(isLoading: false, items: const [], errorMessage: 'Please register or log in first.');
        return;
      }

      final repo = ref.read(menuRepositoryProvider);
      final items = await repo.getAllMenuItems(accountId: _accountId);
      items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      state = state.copyWith(isLoading: false, items: items);
    } catch (e, st) {
      debugPrint('MenuSetupController._load failed: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load menu items.',
      );
    }
  }

  Future<void> refresh() => _load();

  List<String> aliasesFor(String itemId) =>
      state.aliasesById[itemId] ?? const <String>[];

  void setAliases(String itemId, List<String> aliases) {
    final next = Map<String, List<String>>.from(state.aliasesById);
    next[itemId] = aliases;
    state = state.copyWith(aliasesById: next);
  }

  Future<bool> addMenuItem({
    required String name,
    required double price,
    List<String> aliases = const <String>[],
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'Item name is required.');
      return false;
    }
    if (!price.isFinite || price.isNaN || price <= 0) {
      state = state.copyWith(errorMessage: 'Price must be greater than 0.');
      return false;
    }
    if (_accountId.isEmpty) {
      state = state.copyWith(errorMessage: 'Please register or log in before saving menu items.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearCloudSync: true);
    try {
      final repo = ref.read(menuRepositoryProvider);
      final item = MenuItem(
        id: _uuid.v4(),
        name: trimmedName,
        price: price,
        isActive: true,
      );
      await repo
          .upsertMenuItem(
            item,
            accountId: _accountId,
            onCloudSyncState: _handleCloudSyncState,
          )
          .timeout(const Duration(seconds: 5));

      final nextItems = [...state.items, item];
      nextItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final nextAliases = Map<String, List<String>>.from(state.aliasesById);
      if (aliases.isNotEmpty) {
        nextAliases[item.id] = aliases;
      }

      state = state.copyWith(
        items: nextItems,
        aliasesById: nextAliases,
      );
      return true;
    } on TimeoutException {
      state = state.copyWith(
        errorMessage: 'Saving is taking too long. Please check connection and try again.',
      );
      return false;
    } catch (e, st) {
      debugPrint('MenuSetupController.addMenuItem failed: $e\n$st');
      state = state.copyWith(
        errorMessage: 'Could not save item. Please try again.',
      );
      return false;
    } finally {
      if (state.isSaving) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  Future<void> updateMenuItem({
    required MenuItem item,
    required String name,
    required double price,
    required bool isActive,
    List<String>? aliases,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'Item name is required.');
      return;
    }
    if (!price.isFinite || price.isNaN || price <= 0) {
      state = state.copyWith(errorMessage: 'Price must be greater than 0.');
      return;
    }
    if (_accountId.isEmpty) {
      state = state.copyWith(errorMessage: 'Please register or log in before editing menu items.');
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearCloudSync: true);
    try {
      final repo = ref.read(menuRepositoryProvider);
      final updated = item.copyWith(name: trimmedName, price: price, isActive: isActive);
        await repo
          .upsertMenuItem(
            updated,
            accountId: _accountId,
            onCloudSyncState: _handleCloudSyncState,
          )
          .timeout(const Duration(seconds: 5));

      final nextItems = state.items
          .map((e) => e.id == updated.id ? updated : e)
          .toList(growable: false);
      final sorted = [...nextItems]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      var nextAliases = state.aliasesById;
      if (aliases != null) {
        nextAliases = Map<String, List<String>>.from(state.aliasesById);
        nextAliases[updated.id] = aliases;
      }

      state = state.copyWith(items: sorted, aliasesById: nextAliases);
    } on TimeoutException {
      state = state.copyWith(
        errorMessage: 'Update timed out. Please retry in a moment.',
      );
    } catch (e, st) {
      debugPrint('MenuSetupController.updateMenuItem failed: $e\n$st');
      state = state.copyWith(
        errorMessage: 'Could not update item.',
      );
    } finally {
      if (state.isSaving) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  Future<void> toggleActive(MenuItem item, bool isActive) async {
    if (_accountId.isEmpty) {
      state = state.copyWith(errorMessage: 'Please register or log in before updating menu items.');
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearCloudSync: true);
    try {
      final repo = ref.read(menuRepositoryProvider);
      await repo
          .toggleMenuItemStatus(
            item.id,
            isActive,
            accountId: _accountId,
            onCloudSyncState: _handleCloudSyncState,
          )
          .timeout(const Duration(seconds: 5));

      final updated = item.copyWith(isActive: isActive);
      final nextItems = state.items
          .map((e) => e.id == updated.id ? updated : e)
          .toList(growable: false);

      state = state.copyWith(items: nextItems);
    } on TimeoutException {
      state = state.copyWith(errorMessage: 'Status update timed out. Please retry.');
    } catch (e, st) {
      debugPrint('MenuSetupController.toggleActive failed: $e\n$st');
      state = state.copyWith(errorMessage: 'Could not update status.');
    } finally {
      if (state.isSaving) {
        state = state.copyWith(isSaving: false);
      }
    }
  }

  Future<void> deleteMenuItem(String id) async {
    if (_accountId.isEmpty) {
      state = state.copyWith(errorMessage: 'Please register or log in before deleting menu items.');
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearCloudSync: true);
    try {
      final repo = ref.read(menuRepositoryProvider);
      await repo
          .deleteMenuItem(
            id,
            accountId: _accountId,
            onCloudSyncState: _handleCloudSyncState,
          )
          .timeout(const Duration(seconds: 5));

      final nextItems = state.items.where((e) => e.id != id).toList(growable: false);
      final nextAliases = Map<String, List<String>>.from(state.aliasesById);
      nextAliases.remove(id);

      state = state.copyWith(items: nextItems, aliasesById: nextAliases);
    } on TimeoutException {
      state = state.copyWith(errorMessage: 'Delete timed out. Please retry.');
    } catch (e, st) {
      debugPrint('MenuSetupController.deleteMenuItem failed: $e\n$st');
      state = state.copyWith(errorMessage: 'Could not delete item.');
    } finally {
      if (state.isSaving) {
        state = state.copyWith(isSaving: false);
      }
    }
  }
}

final menuSetupProvider =
    NotifierProvider<MenuSetupController, MenuSetupState>(
  MenuSetupController.new,
);
