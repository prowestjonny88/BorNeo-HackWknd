import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'history_provider.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';

class MemoryTimelineScreen extends ConsumerWidget {
  const MemoryTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final historyController = ref.read(historyProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

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
                    Row(
                      children: [
                        Expanded(
                          child: Text('Memory', style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite)),
                        ),
                        IconButton(
                          onPressed: historyController.refresh,
                          icon: historyState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.softWhite,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, color: AppTheme.softWhite),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All', 
                            active: historyState.filterType == HistoryFilterType.all,
                            onTap: () => historyController.setFilter(HistoryFilterType.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Recent',
                            active: historyState.filterType == HistoryFilterType.recent,
                            onTap: () => historyController.setFilter(HistoryFilterType.recent),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Confirmed',
                            active: historyState.filterType == HistoryFilterType.confirmed,
                            onTap: () => historyController.setFilter(HistoryFilterType.confirmed),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Draft',
                            active: historyState.filterType == HistoryFilterType.unconfirmed,
                            onTap: () => historyController.setFilter(HistoryFilterType.unconfirmed),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Error state
                    if (historyState.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.coral.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          historyState.errorMessage!,
                          style: textTheme.bodyMedium?.copyWith(color: AppTheme.coral),
                        ),
                      ),

                    // Summary card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SAVED TOTAL', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                          const SizedBox(height: 8),
                          Text(
                            'RM ${historyState.totalSales.toStringAsFixed(2)}', 
                            style: AppTheme.mono(size: 30, color: AppTheme.amber),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${historyState.dayCount} saved day${historyState.dayCount == 1 ? '' : 's'} in memory',
                            style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.72)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'RECENT DAYS', 
                      style: textTheme.labelMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 12),
                    
                    // Loading state
                    if (historyState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    // Empty state
                    else if (historyState.filteredEntries.isEmpty)
                      Text(
                        'No saved ledgers yet. Finish one recap and save it to memory.',
                        style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.72)),
                      )
                    // Day entries
                    else
                      ...historyState.filteredEntries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DayHistoryCard(
                            entry: entry,
                            onTap: () {
                              historyController.selectEntry(entry);
                              context.push('/ledger?date=${entry.date.toIso8601String().split('T').first}');
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
              const AppBottomNav(currentRoute: '/memory'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppTheme.amber : AppTheme.softWhite.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: active ? AppTheme.charcoal : AppTheme.softWhite,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _DayHistoryCard extends StatelessWidget {
  const _DayHistoryCard({required this.entry, this.onTap});

  final HistoryDayEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = entry.isConfirmed ? AppTheme.jade : AppTheme.coral;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 4, 
              height: 48,
              decoration: BoxDecoration(
                color: accent, 
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2), 
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                entry.dateShort, 
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accent, 
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RM ${entry.totalSales.toStringAsFixed(2)}', 
                    style: AppTheme.mono(size: 18, color: AppTheme.softWhite),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Total Sales', 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.softWhite.withValues(alpha: 0.6),
                        ),
                      ),
                      if (entry.isConfirmed) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: AppTheme.jade,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RM ${entry.cashTotal.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.softWhite.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  'Cash',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.softWhite.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.softWhite.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}