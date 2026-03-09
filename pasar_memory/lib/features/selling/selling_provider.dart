import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/menu_file_cache.dart';
import '../../data/repositories/repository_providers.dart';
import '../auth/session_provider.dart';
import '../../models/menu_item.dart';

class SellingState {
  final bool isLoading;
  final List<MenuItem> menuItems;
  final Map<String, int> countsByMenuItemId;
  final String? errorMessage;

  const SellingState({
    this.isLoading = false,
    this.menuItems = const <MenuItem>[],
    this.countsByMenuItemId = const <String, int>{},
    this.errorMessage,
  });

  SellingState copyWith({
    bool? isLoading,
    List<MenuItem>? menuItems,
    Map<String, int>? countsByMenuItemId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SellingState(
      isLoading: isLoading ?? this.isLoading,
      menuItems: menuItems ?? this.menuItems,
      countsByMenuItemId: countsByMenuItemId ?? this.countsByMenuItemId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int countFor(MenuItem item) => countsByMenuItemId[item.id] ?? 0;

  int get totalTaps => countsByMenuItemId.values.fold(0, (a, b) => a + b);

  double get estimatedTotal {
    var sum = 0.0;
    for (final item in menuItems) {
      final count = countsByMenuItemId[item.id] ?? 0;
      sum += (item.price * count);
    }
    return sum;
  }
}

class SellingController extends Notifier<SellingState> {
  @override
  SellingState build() {
    Future.microtask(_load);
    return const SellingState(isLoading: true);
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final accountId = ref.read(sessionProvider).accountKey;
      if (accountId.isEmpty) {
        state = state.copyWith(isLoading: false, menuItems: const [], errorMessage: 'Please log in first.');
        return;
      }

      // Fast path: load from local file cache instantly (no DB/network wait)
      final cached = await MenuFileCache().loadAll(accountId);
      if (cached.isNotEmpty) {
        final active = cached.where((e) => e.isActive).toList(growable: false)
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        state = state.copyWith(isLoading: false, menuItems: active);
        // Still refresh from SQLite in background to stay in sync
        _refreshFromDb(accountId);
        return;
      }

      // Fallback: slow path via SQLite (first run, cache not yet built)
      await _refreshFromDb(accountId);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Could not load menu.');
    }
  }

  Future<void> _refreshFromDb(String accountId) async {
    try {
      final repo = ref.read(menuRepositoryProvider);
      final all = await repo.getAllMenuItems(accountId: accountId);
      final active = all.where((e) => e.isActive).toList(growable: false)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final nextCounts = <String, int>{};
      for (final item in active) {
        final count = state.countsByMenuItemId[item.id] ?? 0;
        if (count > 0) nextCounts[item.id] = count;
      }

      state = state.copyWith(isLoading: false, menuItems: active, countsByMenuItemId: nextCounts);
    } catch (_) {
      // Already showing cached data or previous state — silently ignore
    }
  }

  Future<void> refreshMenu() => _load();

  void tap(MenuItem item) {
    final next = Map<String, int>.from(state.countsByMenuItemId);
    next[item.id] = (next[item.id] ?? 0) + 1;
    state = state.copyWith(countsByMenuItemId: next);
  }

  void removeTap(MenuItem item) {
    final next = Map<String, int>.from(state.countsByMenuItemId);
    final current = next[item.id] ?? 0;
    if (current <= 1) {
      next.remove(item.id);
    } else {
      next[item.id] = current - 1;
    }
    state = state.copyWith(countsByMenuItemId: next);
  }

  void updateCount(MenuItem item, int nextCount) {
    final next = Map<String, int>.from(state.countsByMenuItemId);
    if (nextCount <= 0) {
      next.remove(item.id);
    } else {
      next[item.id] = nextCount;
    }
    state = state.copyWith(countsByMenuItemId: next);
  }

  void resetAll() {
    state = state.copyWith(countsByMenuItemId: const <String, int>{});
  }

  /// Supplemental evidence payload (in-memory).
  /// Dev 1/Dev 3 can persist this later.
  List<({String menuItemId, int count})> exportTapCounts() {
    final out = <({String menuItemId, int count})>[];
    for (final entry in state.countsByMenuItemId.entries) {
      if (entry.value > 0) {
        out.add((menuItemId: entry.key, count: entry.value));
      }
    }
    return out;
  }
}

final sellingProvider =
    NotifierProvider<SellingController, SellingState>(
  SellingController.new,
);
