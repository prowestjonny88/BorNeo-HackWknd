import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';
import '../../services/recap_parser/menu_aware_parser.dart';
import '../auth/session_provider.dart';
import '../cash_entry/cash_entry_provider.dart';
import '../selling/selling_provider.dart';
import '../voice_recap/voice_provider.dart';

/// State for managing recap review and editing
class RecapReviewState {
  const RecapReviewState({
    this.parsedRecap,
    this.editedItems = const {},
    this.rejectedItemIds = const {},
    this.editedCashAmount,
    this.notes = '',
    this.isSaving = false,
    this.errorMessage,
  });

  /// The parsed recap from voice recording
  final ParsedRecap? parsedRecap;

  /// Edited quantities by menu item ID
  final Map<String, int> editedItems;

  /// IDs of items rejected by user
  final Set<String> rejectedItemIds;

  /// User-edited cash amount (overrides parsed)
  final double? editedCashAmount;

  /// Additional notes from user
  final String notes;

  /// Whether saving is in progress
  final bool isSaving;

  /// Error message if any
  final String? errorMessage;

  /// Get effective quantity for an item (edited or parsed)
  int getEffectiveQuantity(String menuItemId, int parsedQuantity) {
    if (rejectedItemIds.contains(menuItemId)) return 0;
    return editedItems[menuItemId] ?? parsedQuantity;
  }

  /// Get effective cash amount
  double? get effectiveCash {
    return editedCashAmount ?? parsedRecap?.cashMention?.amount;
  }

  /// Get list of accepted items (not rejected)
  List<ParsedItemMention> get acceptedItems {
    if (parsedRecap == null) return [];
    return parsedRecap!.items
        .where((item) => !rejectedItemIds.contains(item.menuItemId))
        .toList();
  }

  RecapReviewState copyWith({
    ParsedRecap? parsedRecap,
    bool clearParsedRecap = false,
    Map<String, int>? editedItems,
    Set<String>? rejectedItemIds,
    double? editedCashAmount,
    bool clearEditedCash = false,
    String? notes,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RecapReviewState(
      parsedRecap: clearParsedRecap ? null : (parsedRecap ?? this.parsedRecap),
      editedItems: editedItems ?? this.editedItems,
      rejectedItemIds: rejectedItemIds ?? this.rejectedItemIds,
      editedCashAmount: clearEditedCash ? null : (editedCashAmount ?? this.editedCashAmount),
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Controller for recap review screen
class RecapReviewController extends Notifier<RecapReviewState> {
  @override
  RecapReviewState build() {
    // Get parsed recap from voice provider
    final voiceState = ref.watch(voiceProvider);
    return RecapReviewState(
      parsedRecap: voiceState.parsedRecap,
    );
  }

  /// Update quantity for an item
  void updateItemQuantity(String menuItemId, int quantity) {
    final newEdits = Map<String, int>.from(state.editedItems);
    if (quantity <= 0) {
      newEdits.remove(menuItemId);
    } else {
      newEdits[menuItemId] = quantity;
    }
    state = state.copyWith(editedItems: newEdits);
  }

  /// Reject/restore a parsed item
  void toggleItemRejection(String menuItemId) {
    final newRejected = Set<String>.from(state.rejectedItemIds);
    if (newRejected.contains(menuItemId)) {
      newRejected.remove(menuItemId);
    } else {
      newRejected.add(menuItemId);
    }
    state = state.copyWith(rejectedItemIds: newRejected);
  }

  /// Accept an item (remove from rejected)
  void acceptItem(String menuItemId) {
    if (!state.rejectedItemIds.contains(menuItemId)) return;
    final newRejected = Set<String>.from(state.rejectedItemIds);
    newRejected.remove(menuItemId);
    state = state.copyWith(rejectedItemIds: newRejected);
  }

  /// Reject an item
  void rejectItem(String menuItemId) {
    if (state.rejectedItemIds.contains(menuItemId)) return;
    final newRejected = Set<String>.from(state.rejectedItemIds);
    newRejected.add(menuItemId);
    state = state.copyWith(rejectedItemIds: newRejected);
  }

  /// Set user-edited cash amount
  void setCashAmount(double? amount) {
    state = state.copyWith(
      editedCashAmount: amount,
      clearEditedCash: amount == null,
    );
  }

  /// Update notes
  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Apply accepted items to selling provider
  void applyToSelling() {
    final sellingController = ref.read(sellingProvider.notifier);
    final sellingState = ref.read(sellingProvider);

    for (final item in state.acceptedItems) {
      final quantity = state.getEffectiveQuantity(item.menuItemId, item.quantity);
      final menuItem = sellingState.menuItems.firstWhere(
        (m) => m.id == item.menuItemId,
        orElse: () => throw Exception('Menu item not found: ${item.menuItemId}'),
      );
      sellingController.updateCount(menuItem, quantity);
    }

    // Apply cash to spoken cash provider
    if (state.effectiveCash != null) {
      ref.read(spokenCashAmountProvider.notifier).set(state.effectiveCash);
    }
  }

  /// Save the reviewed recap to database
  Future<bool> saveRecap() async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final accountId = ref.read(sessionProvider).accountKey;
      if (accountId.isEmpty) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Please log in to save recap',
        );
        return false;
      }

      // Build item payload with edits applied
      final items = state.acceptedItems.map((item) {
        final qty = state.getEffectiveQuantity(item.menuItemId, item.quantity);
        return {
          'menuItemId': item.menuItemId,
          'name': item.menuItemName,
          'quantity': qty,
          'confidence': item.confidence.name,
          'isApproximate': item.isApproximate,
          'isSoldOut': item.isSoldOut,
        };
      }).toList();

      // Get cash state
      final cashState = ref.read(cashEntryProvider);

      await ref.read(recapRepositoryProvider).saveRecap({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'evidenceId': DateTime.now().toIso8601String().split('T').first,
        'rawText': state.parsedRecap?.rawTranscript ?? '',
        'parsedJson': jsonEncode({
          'items': items,
          'rejectedItems': state.rejectedItemIds.toList(),
          'cashAmount': state.effectiveCash,
          'confirmedCash': cashState.amount,
          'notes': state.notes,
          'soldOutItems': state.parsedRecap?.soldOutItems ?? [],
          'paymentModeHint': state.parsedRecap?.paymentModeHint,
        }),
        'confidence': _calculateOverallConfidence(),
      }, accountId: accountId);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save recap: $e',
      );
      return false;
    }
  }

  double _calculateOverallConfidence() {
    if (state.acceptedItems.isEmpty) return 0.3;
    
    final highCount = state.acceptedItems
        .where((i) => i.confidence == ParsedFieldConfidence.high).length;
    final mediumCount = state.acceptedItems
        .where((i) => i.confidence == ParsedFieldConfidence.medium).length;
    
    final total = state.acceptedItems.length;
    return (highCount * 0.9 + mediumCount * 0.7 + (total - highCount - mediumCount) * 0.4) / total;
  }

  /// Reset state
  void reset() {
    state = const RecapReviewState();
  }
}

/// Provider for recap review state
final recapReviewProvider = NotifierProvider<RecapReviewController, RecapReviewState>(
  RecapReviewController.new,
);
