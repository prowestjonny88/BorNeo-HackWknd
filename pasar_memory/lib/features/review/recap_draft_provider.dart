import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';
import '../auth/session_provider.dart';
import '../cash_entry/cash_entry_provider.dart';
import '../selling/selling_provider.dart';

class RecapDraftState {
  const RecapDraftState({
    required this.transcript,
    required this.cashSuggestion,
    this.notes = '',
    this.isTranscriptConfirmed = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final String transcript;
  final String notes;
  final double? cashSuggestion;
  final bool isTranscriptConfirmed;
  final bool isSaving;
  final String? errorMessage;

  RecapDraftState copyWith({
    String? transcript,
    String? notes,
    double? cashSuggestion,
    bool setCashSuggestion = false,
    bool? isTranscriptConfirmed,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RecapDraftState(
      transcript: transcript ?? this.transcript,
      notes: notes ?? this.notes,
      cashSuggestion: setCashSuggestion ? cashSuggestion : (cashSuggestion ?? this.cashSuggestion),
      isTranscriptConfirmed: isTranscriptConfirmed ?? this.isTranscriptConfirmed,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RecapDraftController extends Notifier<RecapDraftState> {
  static const _defaultTranscript =
      'Sold quite a lot of bihun and mee goreng today. Teh tarik moved faster after lunch. Counted cash should be around RM 180.';

  @override
  RecapDraftState build() {
    return RecapDraftState(
      transcript: _defaultTranscript,
      cashSuggestion: _extractCashAmount(_defaultTranscript),
    );
  }

  void setTranscript(String value) {
    final suggestion = _extractCashAmount(value);
    state = state.copyWith(
      transcript: value,
      cashSuggestion: suggestion,
      setCashSuggestion: true,
      isTranscriptConfirmed: false,
      clearError: true,
    );
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value, clearError: true);
  }

  void resetTranscript() {
    state = RecapDraftState(
      transcript: '',
      cashSuggestion: null,
    );
    ref.read(spokenCashAmountProvider.notifier).clear();
  }

  bool confirmTranscript() {
    if (state.transcript.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Add your recap before continuing.');
      return false;
    }

    if (state.cashSuggestion != null) {
      ref.read(spokenCashAmountProvider.notifier).set(state.cashSuggestion);
    }

    state = state.copyWith(isTranscriptConfirmed: true, clearError: true);
    return true;
  }

  Future<bool> saveRecap() async {
    if (state.transcript.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Recap transcript cannot be empty.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final accountId = ref.read(sessionProvider).accountKey;
      if (accountId.isEmpty) {
        state = state.copyWith(isSaving: false, errorMessage: 'Please log in again before saving recap.');
        return false;
      }

      final sellingState = ref.read(sellingProvider);
      final cashState = ref.read(cashEntryProvider);
      final itemPayload = sellingState.menuItems
          .where((item) => (sellingState.countsByMenuItemId[item.id] ?? 0) > 0)
          .map(
            (item) => {
              'menuItemId': item.id,
              'name': item.name,
              'unitPrice': item.price,
              'quantity': sellingState.countsByMenuItemId[item.id] ?? 0,
              'subtotal': item.price * (sellingState.countsByMenuItemId[item.id] ?? 0),
            },
          )
          .toList(growable: false);

      await ref.read(recapRepositoryProvider).saveRecap({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'evidenceId': DateTime.now().toIso8601String().split('T').first,
        'rawText': state.transcript,
        'parsedJson': jsonEncode({
          'cashSuggestion': state.cashSuggestion,
          'confirmedCash': cashState.amount,
          'notes': state.notes,
          'items': itemPayload,
        }),
        'confidence': itemPayload.isEmpty ? 0.45 : 0.82,
      }, accountId: accountId);

      state = state.copyWith(isSaving: false, isTranscriptConfirmed: true);
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false, errorMessage: 'Could not save recap yet.');
      return false;
    }
  }

  double? _extractCashAmount(String transcript) {
    // Only extract amounts explicitly marked with RM prefix — avoids picking up item quantities
    final regex = RegExp(r'rm\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false);
    final matches = regex.allMatches(transcript);
    if (matches.isEmpty) return null;
    final last = matches.last.group(1);
    return last == null ? null : double.tryParse(last);
  }
}

final recapDraftProvider = NotifierProvider<RecapDraftController, RecapDraftState>(
  RecapDraftController.new,
);