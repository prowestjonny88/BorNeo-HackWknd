import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/repository_providers.dart';
import '../auth/session_provider.dart';
import 'history_provider.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';

class MemoryTimelineScreen extends ConsumerWidget {
  const MemoryTimelineScreen({super.key});

  /// Groups entries by calendar date (newest group first).
  List<({String label, List<HistoryDayEntry> entries})> _groupByDay(
    List<HistoryDayEntry> entries,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<HistoryDayEntry>> grouped = {};
    for (final e in entries) {
      final key = e.date.toIso8601String().split('T').first;
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    return sortedKeys.map((key) {
      final date = DateTime.tryParse(key)!;
      final day = DateTime(date.year, date.month, date.day);
      final String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        label = '${date.day} ${months[date.month - 1]} ${date.year}';
      }
      return (label: label, entries: grouped[key]!);
    }).toList();
  }

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
                      'RECENT HISTORY',
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
                    // Day entries grouped by date
                    else
                      ...() {
                        final groups = _groupByDay(historyState.filteredEntries);
                        final widgets = <Widget>[];
                        for (final group in groups) {
                          widgets.add(
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, top: 4),
                              child: Text(
                                group.label,
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppTheme.amber,
                                ),
                              ),
                            ),
                          );
                          for (final entry in group.entries) {
                            widgets.add(
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _DayHistoryCard(
                                  entry: entry,
                                  onEdit: () => _showEditSheet(context, entry),
                                  onDelete: () => _showDeleteDialog(context, ref, entry),
                                ),
                              ),
                            );
                          }
                        }
                        return widgets;
                      }(),
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

/// Opens the edit bottom sheet for a ledger entry.
void _showEditSheet(BuildContext context, HistoryDayEntry entry) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF111827), // AppTheme.deepForest
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _EditLedgerSheet(entry: entry),
  );
}

/// Shows a delete-confirmation dialog and, if confirmed, deletes the entry.
Future<void> _showDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  HistoryDayEntry entry,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Delete record?', style: TextStyle(color: Color(0xFFF8FBFF))),
      content: Text(
        'Are you sure you want to delete the record for ${entry.dateFormatted}?\n\nThis action cannot be undone.',
        style: const TextStyle(color: Color(0xAAF8FBFF)),
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF7A59)),
              child: const Text('Delete'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF7A59),
                side: const BorderSide(color: Color(0xFFFF7A59)),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(historyProvider.notifier).deleteEntry(entry.id);
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
  const _DayHistoryCard({
    required this.entry,
    this.onEdit,
    this.onDelete,
  });

  final HistoryDayEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = entry.isConfirmed ? AppTheme.jade : AppTheme.coral;
    final textTheme = Theme.of(context).textTheme;
    return Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            // ── Main info row ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
                      style: textTheme.bodySmall?.copyWith(
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
                              style: textTheme.bodySmall?.copyWith(
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
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.softWhite.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        'Cash',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.softWhite.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // ── Action row ─────────────────────────────────────────────────
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.amber,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.1)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 14),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.coral,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit ledger bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditLedgerSheet extends ConsumerStatefulWidget {
  const _EditLedgerSheet({required this.entry});
  final HistoryDayEntry entry;

  @override
  ConsumerState<_EditLedgerSheet> createState() => _EditLedgerSheetState();
}

class _EditLedgerSheetState extends ConsumerState<_EditLedgerSheet> {
  late final TextEditingController _totalCtrl;
  late final TextEditingController _digitalCtrl;
  late final TextEditingController _cashCtrl;
  late final TextEditingController _notesCtrl;
  late bool _isConfirmed;

  List<Map<String, dynamic>> _evidenceFiles = [];
  bool _loadingEvidence = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _totalCtrl = TextEditingController(text: e.totalSales.toStringAsFixed(2));
    _digitalCtrl = TextEditingController(text: e.digitalTotal.toStringAsFixed(2));
    _cashCtrl = TextEditingController(text: e.cashTotal.toStringAsFixed(2));
    _notesCtrl = TextEditingController(text: e.notes ?? '');
    _isConfirmed = e.isConfirmed;
    _loadEvidence();
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _digitalCtrl.dispose();
    _cashCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEvidence() async {
    if (kIsWeb) return; // Evidence file paths are not usable on web
    setState(() => _loadingEvidence = true);
    try {
      final accountId = ref.read(sessionProvider).accountKey;
      final evidenceRepo = ref.read(evidenceRepositoryProvider);
      final files = await evidenceRepo.getEvidenceByDate(
        widget.entry.date,
        accountId: accountId,
      );
      if (mounted) {
        setState(() {
          _evidenceFiles = files
              .where((f) => f['type'] == 'screenshot')
              .toList();
          _loadingEvidence = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingEvidence = false);
    }
  }

  Future<void> _onSave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Save changes?',
          style: TextStyle(color: Color(0xFFF8FBFF)),
        ),
        content: const Text(
          'Are you sure you want to save these changes?\n\nThis action cannot be undone.',
          style: TextStyle(color: Color(0xAAF8FBFF)),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB15E), // amber
                  foregroundColor: const Color(0xFF172033), // charcoal
                ),
                child: const Text('Save changes'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF7A59),
                  side: const BorderSide(color: Color(0xFFFF7A59)),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    final notesText = _notesCtrl.text.trim();
    final updated = widget.entry.copyWith(
      totalSales: double.tryParse(_totalCtrl.text) ?? widget.entry.totalSales,
      digitalTotal: double.tryParse(_digitalCtrl.text) ?? widget.entry.digitalTotal,
      cashTotal: double.tryParse(_cashCtrl.text) ?? widget.entry.cashTotal,
      notes: notesText.isEmpty ? null : notesText,
      clearNotes: notesText.isEmpty,
      isConfirmed: _isConfirmed,
    );

    await ref.read(historyProvider.notifier).updateEntry(updated);
    if (mounted) Navigator.pop(context);
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFFF8FBFF).withValues(alpha: 0.3)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFFB15E), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.labelSmall?.copyWith(
      color: const Color(0xFFF8FBFF).withValues(alpha: 0.5),
      letterSpacing: 0.8,
    );
    final fieldText = textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Edit Record',
                  style: textTheme.titleLarge?.copyWith(color: AppTheme.softWhite, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.entry.dateFormatted,
                    style: textTheme.labelMedium?.copyWith(color: AppTheme.amber, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),

          // ── Scrollable body ───────────────────────────────────────────────
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [

                // ── Screenshots ────────────────────────────────────────────
                if (!kIsWeb) ...[
                  Text('SCREENSHOTS', style: labelStyle),
                  const SizedBox(height: 8),
                  if (_loadingEvidence)
                    const Center(child: CircularProgressIndicator())
                  else if (_evidenceFiles.isEmpty)
                    Text(
                      'No screenshots attached to this day.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.softWhite.withValues(alpha: 0.45),
                      ),
                    )
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _evidenceFiles.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final path = _evidenceFiles[i]['filePath'] as String? ?? '';
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(path),
                              width: 120,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 120,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // ── Total Sales ────────────────────────────────────────────
                Text('TOTAL SALES (RM)', style: labelStyle),
                const SizedBox(height: 6),
                TextField(
                  controller: _totalCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: fieldText,
                  decoration: _fieldDecoration(hint: '0.00'),
                ),
                const SizedBox(height: 16),

                // ── Digital Total ──────────────────────────────────────────
                Text('DIGITAL TOTAL (RM)', style: labelStyle),
                const SizedBox(height: 6),
                TextField(
                  controller: _digitalCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: fieldText,
                  decoration: _fieldDecoration(hint: '0.00'),
                ),
                const SizedBox(height: 16),

                // ── Cash Estimate ──────────────────────────────────────────
                Text('CASH ESTIMATE (RM)', style: labelStyle),
                const SizedBox(height: 6),
                TextField(
                  controller: _cashCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: fieldText,
                  decoration: _fieldDecoration(hint: '0.00'),
                ),
                const SizedBox(height: 16),

                // ── Notes ──────────────────────────────────────────────────
                Text('NOTES', style: labelStyle),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: fieldText,
                  decoration: _fieldDecoration(hint: 'Optional notes…'),
                ),
                const SizedBox(height: 20),

                // ── Confirmed toggle ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mark as Confirmed',
                          style: textTheme.bodyMedium?.copyWith(color: AppTheme.softWhite),
                        ),
                      ),
                      Switch(
                        value: _isConfirmed,
                        onChanged: (v) => setState(() => _isConfirmed = v),
                        activeThumbColor: AppTheme.jade,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Save button ────────────────────────────────────────────
                FilledButton(
                  onPressed: _saving ? null : _onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.amber,
                    foregroundColor: AppTheme.charcoal,
                    disabledBackgroundColor: AppTheme.amber.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF172033)),
                        )
                      : Text(
                          'Save Changes',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppTheme.charcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}