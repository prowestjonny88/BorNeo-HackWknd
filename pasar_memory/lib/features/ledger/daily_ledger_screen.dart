import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/repository_providers.dart';
import '../auth/session_provider.dart';
import '../cash_entry/cash_entry_provider.dart';
import '../evidence/evidence_provider.dart';
import '../selling/selling_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/confidence_badge.dart';
import '../../shared/widgets/progress_stepper.dart';
import '../../shared/widgets/reconciliation_summary_widget.dart';

class DailyLedgerScreen extends ConsumerWidget {
  const DailyLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellingState = ref.watch(sellingProvider);
    final cashState = ref.watch(cashEntryProvider);
    final evidenceState = ref.watch(evidenceProvider);
    final textTheme = Theme.of(context).textTheme;
    final digitalTotal = evidenceState.resultById.values
        .expand((result) => result.amounts)
        .fold<double>(0, (sum, amount) => sum + amount.amount);
    final cashTotal = cashState.amount ?? 0;
    final tappedItems = sellingState.menuItems
        .where((item) => (sellingState.countsByMenuItemId[item.id] ?? 0) > 0)
        .toList(growable: false);
    final estimatedItems = sellingState.totalTaps;
    final fallbackSales = sellingState.estimatedTotal + cashTotal;
    final totalSales = (digitalTotal > 0 ? digitalTotal + cashTotal : fallbackSales);

    return Scaffold(
      body: Container(
        color: AppTheme.deepForest,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const ProgressStepper(currentStep: 4, completedStepCount: 4),
                    const SizedBox(height: 16),
                    Text('Today\'s Ledger', style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite)),
                    const SizedBox(height: 4),
                    Text(
                      _formattedToday(),
                      style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: 20),
                    ReconciliationSummaryWidget(
                      totalSales: 'RM ${totalSales.toStringAsFixed(2)}',
                      digitalTotal: 'RM ${digitalTotal.toStringAsFixed(2)}',
                      cash: 'RM ${cashTotal.toStringAsFixed(2)}',
                      estimatedItems: '$estimatedItems',
                    ),
                    const SizedBox(height: 20),
                    Text('BUILT FROM', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (evidenceState.files.isNotEmpty) ...[
                            _SourceChip(
                              label: '${evidenceState.files.length} Screenshot${evidenceState.files.length > 1 ? 's' : ''}',
                              icon: Icons.photo_camera_outlined,
                              active: digitalTotal > 0,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _SourceChip(
                            label: 'Voice Recap',
                            icon: Icons.mic_none_rounded,
                            active: true,
                          ),
                          const SizedBox(width: 8),
                          _SourceChip(
                            label: cashState.isConfirmed ? 'Cash Confirmed' : 'Cash Entry',
                            icon: Icons.payments_outlined,
                            active: cashState.isConfirmed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('ESTIMATED ITEMS SOLD', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                    const SizedBox(height: 12),
                    if (tappedItems.isEmpty)
                      Text(
                        'No item-level sales were captured for this recap yet.',
                        style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.72)),
                      )
                    else
                      ...tappedItems.map(
                        (item) {
                          final qty = sellingState.countsByMenuItemId[item.id] ?? 0;
                          return _LedgerRow(
                            name: item.name,
                            qty: '$qty',
                            subtotal: 'RM ${(item.price * qty).toStringAsFixed(2)}',
                            badge: cashState.isConfirmed ? ConfidenceBadgeType.confirmed : ConfidenceBadgeType.estimated,
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: const Border(left: BorderSide(color: AppTheme.amber, width: 4)),
                      ),
                      child: Text(
                        'Fields marked "Estimated" are based on your voice recap. Tap any field to correct it.',
                        style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        onPressed: () => context.go('/review'),
                        child: const Text('Edit any field'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                color: AppTheme.deepForest,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        final accountId = ref.read(sessionProvider).accountKey;
                        if (accountId.isEmpty) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(const SnackBar(content: Text('Please log in again before saving the ledger.')));
                          return;
                        }

                        await ref.read(ledgerRepositoryProvider).upsertLedger({
                          'id': DateTime.now().toIso8601String().split('T').first,
                          'date': DateTime.now().toIso8601String().split('T').first,
                          'totalSales': totalSales,
                          'digitalTotal': digitalTotal,
                          'cashEstimate': cashTotal,
                          'unresolvedCount': evidenceState.statusById.values.where((status) => status == EvidenceProcessingStatus.error).length,
                          'isConfirmed': 1,
                        }, accountId: accountId);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(const SnackBar(content: Text('Ledger saved to memory.')));
                        context.go('/memory');
                      },
                      child: const Text('Confirm & Save to Memory'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This day will be saved to your business memory timeline.',
                      style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedToday() {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label, required this.icon, this.active = false});

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.jade : AppTheme.softWhite;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.jade.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? AppTheme.jade.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.name, required this.qty, required this.subtotal, required this.badge});

  final String name;
  final String qty;
  final String subtotal;
  final ConfidenceBadgeType badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.softWhite, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ConfidenceBadge(type: badge),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(qty, style: AppTheme.mono(size: 16, color: AppTheme.softWhite)),
          ),
          Text(subtotal, style: AppTheme.mono(size: 16, color: AppTheme.amber)),
        ],
      ),
    );
  }
}