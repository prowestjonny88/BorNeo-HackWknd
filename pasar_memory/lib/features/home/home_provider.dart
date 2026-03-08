import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/repository_providers.dart';

enum DayFlowState { initial, evidenceUploaded, recapDone, readyToReview, confirmed }

class HomeState {
  final DayFlowState flowState;
  final double totalSales;
  final int unresolvedMatches;

  HomeState({
    this.flowState = DayFlowState.initial,
    this.totalSales = 0.0,
    this.unresolvedMatches = 0,
  });
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref ref;
  HomeNotifier(this.ref) : super(HomeState()) {
    refreshStatus();
  }

  Future<void> refreshStatus() async {
    final today = DateTime.now();
    final evidence = await ref.read(evidenceRepositoryProvider).getEvidenceByDate(today);
    final ledger = await ref.read(ledgerRepositoryProvider).getLedgerByDate(today);

    DayFlowState newState = DayFlowState.initial;
    if (ledger != null && ledger['isConfirmed'] == 1) {
      newState = DayFlowState.confirmed;
    } else if (evidence.isNotEmpty) {
      // Check if any evidence is audio to determine if recap is done
      bool hasAudio = evidence.any((e) => e['type'] == 'audio');
      newState = hasAudio ? DayFlowState.readyToReview : DayFlowState.evidenceUploaded;
    }

    state = HomeState(
      flowState: newState,
      totalSales: ledger?['totalSales'] ?? 0.0,
      unresolvedMatches: ledger?['unresolvedCount'] ?? 0,
    );
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});