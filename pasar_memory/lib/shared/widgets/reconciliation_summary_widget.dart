import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ReconciliationSummaryWidget extends StatelessWidget {
  const ReconciliationSummaryWidget({
    super.key,
    required this.totalSales,
    required this.digitalTotal,
    required this.cash,
    required this.estimatedItems,
  });

  final String totalSales;
  final String digitalTotal;
  final String cash;
  final String estimatedItems;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.forestGradientBottom, AppTheme.deepForest],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL SALES TODAY',
            style: textTheme.labelMedium?.copyWith(color: AppTheme.amber),
          ),
          const SizedBox(height: 10),
          Text(totalSales, style: AppTheme.mono(size: 42, color: AppTheme.amber)),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatColumn(label: 'Digital Total', value: digitalTotal),
              _Divider(),
              _StatColumn(label: 'Cash', value: cash),
              _Divider(),
              _StatColumn(label: 'Estimated Items', value: estimatedItems),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTheme.mono(size: 16, weight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.softWhite.withValues(alpha: 0.65),
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}