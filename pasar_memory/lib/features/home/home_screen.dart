import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Pasar Memory")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusCard(homeState),
            const SizedBox(height: 40),
            _buildContextualCTA(context, homeState.flowState),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(HomeState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Today's Sales", style: TextStyle(fontSize: 16)),
            Text("RM ${state.totalSales.toStringAsFixed(2)}", 
                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            if (state.unresolvedMatches > 0)
              Text("${state.unresolvedMatches} items need review", 
                   style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualCTA(BuildContext context, DayFlowState flow) {
    String label;
    IconData icon;
    Color color = Colors.teal;

    switch (flow) {
      case DayFlowState.initial:
        label = "Upload Evidence";
        icon = Icons.upload_file;
        break;
      case DayFlowState.evidenceUploaded:
        label = "Record Voice Recap";
        icon = Icons.mic;
        break;
      case DayFlowState.readyToReview:
        label = "Review Daily Ledger";
        icon = Icons.rate_review;
        break;
      case DayFlowState.confirmed:
        label = "Day Confirmed";
        icon = Icons.check_circle;
        color = Colors.green;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
        onPressed: () { /* Navigation handled in Step 1.1.16 */ },
        icon: Icon(icon),
        label: Text(label, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}