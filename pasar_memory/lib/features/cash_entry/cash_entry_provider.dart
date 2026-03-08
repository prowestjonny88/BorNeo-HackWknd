import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dev 4 hook: set this when a voice recap parser detects a cash amount.
///
/// Example (elsewhere): `ref.read(spokenCashAmountProvider.notifier).state = 123.45;`
class SpokenCashAmount extends Notifier<double?> {
  @override
  double? build() => null;

  void set(double? value) => state = value;

  void clear() => state = null;
}

final spokenCashAmountProvider =
    NotifierProvider<SpokenCashAmount, double?>(SpokenCashAmount.new);

class CashEntryState {
  final String amountText;
  final double? amount;
  final bool isConfirmed;
  final bool wasPrefilled;
  final String? bannerMessage;

  const CashEntryState({
    this.amountText = '',
    this.amount,
    this.isConfirmed = false,
    this.wasPrefilled = false,
    this.bannerMessage,
  });

  bool get canConfirm => amount != null && amount! > 0 && !isConfirmed;

  CashEntryState copyWith({
    String? amountText,
    double? amount,
    bool? isConfirmed,
    bool? wasPrefilled,
    String? bannerMessage,
    bool clearBanner = false,
  }) {
    return CashEntryState(
      amountText: amountText ?? this.amountText,
      amount: amount ?? this.amount,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      wasPrefilled: wasPrefilled ?? this.wasPrefilled,
      bannerMessage: clearBanner ? null : (bannerMessage ?? this.bannerMessage),
    );
  }
}

class CashEntryController extends Notifier<CashEntryState> {
  @override
  CashEntryState build() {
    ref.listen<double?>(spokenCashAmountProvider, (prev, next) {
      if (next == null) return;
      if (prev == next) return;
      if (state.isConfirmed) return;
      if (state.amountText.trim().isNotEmpty) return; // don't override manual input
      prefillFromVoice(next);
    });
    return const CashEntryState();
  }

  void setAmountText(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9\.]'), '');
    final parsed = double.tryParse(cleaned);
    state = state.copyWith(
      amountText: cleaned,
      amount: parsed,
      wasPrefilled: false,
      clearBanner: true,
    );
  }

  void prefillFromVoice(double amount) {
    final fixed = amount.toStringAsFixed(2);
    state = state.copyWith(
      amountText: fixed,
      amount: amount,
      wasPrefilled: true,
      bannerMessage: 'Prefilled from voice recap',
    );
  }

  void confirm() {
    if (!state.canConfirm) return;
    state = state.copyWith(
      isConfirmed: true,
      bannerMessage: 'Cash confirmed (merchant-confirmed)',
    );
  }

  void confirmAmount(double amount) {
    final fixed = amount.toStringAsFixed(2);
    state = state.copyWith(
      amountText: fixed,
      amount: amount,
      isConfirmed: true,
      bannerMessage: amount > 0 ? 'Cash confirmed' : 'No cash counted for this session',
    );
  }

  void reset() {
    state = const CashEntryState();
  }
}

final cashEntryProvider =
    NotifierProvider<CashEntryController, CashEntryState>(
  CashEntryController.new,
);
