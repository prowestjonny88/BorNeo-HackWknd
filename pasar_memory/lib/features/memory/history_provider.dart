import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';
import '../auth/session_provider.dart';

/// Represents a day's ledger summary for history display
class HistoryDayEntry {
  const HistoryDayEntry({
    required this.id,
    required this.date,
    required this.totalSales,
    required this.digitalTotal,
    required this.cashTotal,
    required this.isConfirmed,
    this.itemCount,
    this.notes,
  });

  final String id;
  final DateTime date;
  final double totalSales;
  final double digitalTotal;
  final double cashTotal;
  final bool isConfirmed;
  final int? itemCount;
  final String? notes;

  factory HistoryDayEntry.fromMap(Map<String, dynamic> map) {
    return HistoryDayEntry(
      id: map['id']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      totalSales: (map['totalSales'] as num?)?.toDouble() ?? 0.0,
      digitalTotal: (map['digitalTotal'] as num?)?.toDouble() ?? 0.0,
      cashTotal: (map['cashEstimate'] as num?)?.toDouble() ?? 0.0,
      isConfirmed: map['isConfirmed'] == 1 || map['isConfirmed'] == true,
      itemCount: map['itemCount'] as int?,
      notes: map['notes'] as String?,
    );
  }

  String get dateFormatted {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String get dateShort {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${date.day.toString().padLeft(2, '0')}/${months[date.month - 1]}';
  }
}

/// State for history timeline
class HistoryState {
  const HistoryState({
    this.entries = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedEntry,
    this.filterType = HistoryFilterType.all,
  });

  final List<HistoryDayEntry> entries;
  final bool isLoading;
  final String? errorMessage;
  final HistoryDayEntry? selectedEntry;
  final HistoryFilterType filterType;

  /// Get filtered entries based on filter type
  List<HistoryDayEntry> get filteredEntries {
    switch (filterType) {
      case HistoryFilterType.all:
        return entries;
      case HistoryFilterType.confirmed:
        return entries.where((e) => e.isConfirmed).toList();
      case HistoryFilterType.unconfirmed:
        return entries.where((e) => !e.isConfirmed).toList();
      case HistoryFilterType.recent:
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        return entries.where((e) => e.date.isAfter(sevenDaysAgo)).toList();
    }
  }

  /// Calculate total for filtered entries
  double get totalSales => filteredEntries.fold(0.0, (sum, e) => sum + e.totalSales);

  /// Total days in filtered view
  int get dayCount => filteredEntries.length;

  HistoryState copyWith({
    List<HistoryDayEntry>? entries,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    HistoryDayEntry? selectedEntry,
    bool clearSelected = false,
    HistoryFilterType? filterType,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedEntry: clearSelected ? null : (selectedEntry ?? this.selectedEntry),
      filterType: filterType ?? this.filterType,
    );
  }
}

/// Filter types for history
enum HistoryFilterType {
  all,
  confirmed,
  unconfirmed,
  recent,
}

/// Controller for history timeline
class HistoryController extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    // Auto-load on init
    Future.microtask(() => loadHistory());
    return const HistoryState(isLoading: true);
  }

  /// Load history entries from database
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final accountId = ref.read(sessionProvider).accountKey;
      if (accountId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          entries: const [],
        );
        return;
      }

      final ledgerRepo = ref.read(ledgerRepositoryProvider);
      final rawEntries = await ledgerRepo.getRecentLedgers(accountId: accountId);

      final entries = rawEntries
          .map((map) => HistoryDayEntry.fromMap(map))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort newest first

      state = state.copyWith(
        isLoading: false,
        entries: entries,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load history: $e',
      );
    }
  }

  /// Refresh history
  Future<void> refresh() => loadHistory();

  /// Set filter type
  void setFilter(HistoryFilterType filter) {
    state = state.copyWith(filterType: filter);
  }

  /// Select a day entry for detail view
  void selectEntry(HistoryDayEntry entry) {
    state = state.copyWith(selectedEntry: entry);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(clearSelected: true);
  }
}

/// Provider for history timeline
final historyProvider = NotifierProvider<HistoryController, HistoryState>(
  HistoryController.new,
);

/// Provider for legacy memory timeline (backward compatibility)
final memoryTimelineProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final accountId = ref.watch(sessionProvider).accountKey;
  if (accountId.isEmpty) {
    return Future.value(const <Map<String, dynamic>>[]);
  }
  return ref.read(ledgerRepositoryProvider).getRecentLedgers(accountId: accountId);
});
