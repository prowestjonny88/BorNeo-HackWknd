import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../cash_entry/cash_entry_provider.dart';
import '../selling/selling_provider.dart';
import '../voice_recap/voice_provider.dart';
import 'recap_draft_provider.dart';
import 'recap_review_provider.dart';
import '../../services/recap_parser/menu_aware_parser.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/confidence_badge.dart';
import '../../shared/widgets/progress_stepper.dart';

class RecapReviewScreen extends ConsumerStatefulWidget {
  const RecapReviewScreen({super.key});

  @override
  ConsumerState<RecapReviewScreen> createState() => _RecapReviewScreenState();
}

class _RecapReviewScreenState extends ConsumerState<RecapReviewScreen> {
  late final TextEditingController _notesController;
  late final ProviderSubscription<RecapDraftState> _recapSubscription;

  @override
  void initState() {
    super.initState();
    final recap = ref.read(recapDraftProvider);
    _notesController = TextEditingController(text: recap.notes);
    _recapSubscription = ref.listenManual<RecapDraftState>(recapDraftProvider, (prev, next) {
      if (next.notes != _notesController.text) {
        _notesController.value = _notesController.value.copyWith(
          text: next.notes,
          selection: TextSelection.collapsed(offset: next.notes.length),
        );
      }

      final prevError = prev?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != prevError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });
  }

  @override
  void dispose() {
    _recapSubscription.close();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellingState = ref.watch(sellingProvider);
    final sellingController = ref.read(sellingProvider.notifier);
    final recap = ref.watch(recapDraftProvider);
    final recapController = ref.read(recapDraftProvider.notifier);
    final voiceState = ref.watch(voiceProvider);
    final reviewState = ref.watch(recapReviewProvider);
    final reviewController = ref.read(recapReviewProvider.notifier);
    final cashState = ref.watch(cashEntryProvider);
    final textTheme = Theme.of(context).textTheme;
    
    // Get items from selling state (tapped) OR from voice parsed recap
    final tappedItems = sellingState.menuItems
        .where((item) => (sellingState.countsByMenuItemId[item.id] ?? 0) > 0)
        .toList(growable: false);
    
    // Get parsed items from voice recap
    final parsedItems = voiceState.parsedRecap?.items ?? [];
    final hasVoiceParsedItems = parsedItems.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.warmSurface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/voice-recap'),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.charcoal),
        ),
        title: Text('Review Recap', style: textTheme.headlineMedium?.copyWith(color: AppTheme.charcoal)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.deepForest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const ProgressStepper(currentStep: 3),
            ),
            const SizedBox(height: 20),
            
            // Show voice transcript if available
            if (voiceState.transcript != null && voiceState.transcript!.isNotEmpty) ...[
              Text('VOICE TRANSCRIPT', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    voiceState.transcript!,
                    style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            Text('ITEMS DETECTED FROM YOUR RECAP', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
            const SizedBox(height: 12),
            
            // Show parsed items from voice if available
            if (hasVoiceParsedItems)
              ...parsedItems.map((parsedItem) {
                final isRejected = reviewState.rejectedItemIds.contains(parsedItem.menuItemId);
                final effectiveQty = reviewState.getEffectiveQuantity(
                  parsedItem.menuItemId, 
                  parsedItem.quantity,
                );
                final menuItem = sellingState.menuItems.firstWhere(
                  (m) => m.id == parsedItem.menuItemId,
                  orElse: () => sellingState.menuItems.first,
                );
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: isRejected ? 0.5 : 1.0,
                    child: _ReviewItemRow(
                      name: parsedItem.menuItemName,
                      alias: parsedItem.isSoldOut 
                        ? 'Sold out (from voice)'
                        : parsedItem.isApproximate 
                          ? 'Approximate count from voice'
                          : 'From voice recap',
                      qty: effectiveQty,
                      subtotal: 'RM ${(menuItem.price * effectiveQty).toStringAsFixed(2)}',
                      badge: _mapConfidenceToBadge(parsedItem.confidence),
                      isRejected: isRejected,
                      onDecrement: isRejected ? () {} : () => reviewController.updateItemQuantity(
                        parsedItem.menuItemId, 
                        effectiveQty - 1,
                      ),
                      onIncrement: isRejected ? () {} : () => reviewController.updateItemQuantity(
                        parsedItem.menuItemId, 
                        effectiveQty + 1,
                      ),
                      onToggleReject: () => reviewController.toggleItemRejection(parsedItem.menuItemId),
                    ),
                  ),
                );
              })
            // Fallback to tapped items if no voice parsed items
            else if (tappedItems.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No items detected yet. You can still save the recap with notes and counted cash.',
                    style: textTheme.bodyLarge,
                  ),
                ),
              )
            else
              ...tappedItems.map(
                (item) {
                  final qty = sellingState.countsByMenuItemId[item.id] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReviewItemRow(
                      name: item.name,
                      alias: 'Tapped from live quick count',
                      qty: qty,
                      subtotal: 'RM ${(item.price * qty).toStringAsFixed(2)}',
                      badge: recap.isTranscriptConfirmed ? ConfidenceBadgeType.voice : ConfidenceBadgeType.estimated,
                      onDecrement: () => sellingController.updateCount(item, qty - 1),
                      onIncrement: () => sellingController.updateCount(item, qty + 1),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            
            // Show detected cash from voice
            Text('COUNTED CASH', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('RM', style: AppTheme.mono(size: 20, color: AppTheme.amber, weight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        Text(
                          (cashState.amount ?? 
                           voiceState.parsedRecap?.cashMention?.amount ?? 
                           recap.cashSuggestion ?? 0).toStringAsFixed(2), 
                          style: AppTheme.mono(size: 28, color: AppTheme.charcoal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConfidenceBadge(
                      type: cashState.isConfirmed 
                        ? ConfidenceBadgeType.confirmed 
                        : voiceState.parsedRecap?.cashMention != null
                          ? ConfidenceBadgeType.voice
                          : ConfidenceBadgeType.estimated,
                    ),
                    if (voiceState.parsedRecap?.cashMention?.isApproximate == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Note: This is an approximate amount from your voice recap',
                          style: textTheme.bodySmall?.copyWith(color: AppTheme.amber),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (cashState.isConfirmed)
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.jade, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Cash confirmed',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppTheme.jade,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            final amount = cashState.amount ??
                                voiceState.parsedRecap?.cashMention?.amount ??
                                recap.cashSuggestion ??
                                0.0;
                            ref.read(cashEntryProvider.notifier).confirmAmount(amount);
                          },
                          child: Text(
                            () {
                              final amount = cashState.amount ??
                                  voiceState.parsedRecap?.cashMention?.amount ??
                                  recap.cashSuggestion;
                              return (amount != null && amount > 0)
                                  ? 'Confirm Cash RM ${amount.toStringAsFixed(2)}'
                                  : 'No Cash Counted';
                            }(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Any corrections or notes?', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              onChanged: (value) {
                recapController.setNotes(value);
                reviewController.setNotes(value);
              },
              maxLines: 4,
              decoration: InputDecoration(hintText: 'Add notes about corrections, sold out items, or unusual sales...'),
            ),
            const SizedBox(height: 24),
            if (!cashState.isConfirmed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Confirm counted cash first before saving the recap.',
                  style: textTheme.bodyMedium?.copyWith(color: AppTheme.coral, fontWeight: FontWeight.w600),
                ),
              ),
            FilledButton(
              onPressed: recap.isSaving || !cashState.isConfirmed
                  ? null
                  : () async {
                      // Apply review state to selling
                      reviewController.applyToSelling();
                      
                      await recapController.saveRecap();
                      if (!context.mounted) return;
                      context.go('/ledger');
                    },
              child: const Text('Save Recap & Continue ->'),
            ),
          ],
        ),
      ),
    );
  }

  ConfidenceBadgeType _mapConfidenceToBadge(ParsedFieldConfidence confidence) {
    switch (confidence) {
      case ParsedFieldConfidence.high:
        return ConfidenceBadgeType.confirmed;
      case ParsedFieldConfidence.medium:
        return ConfidenceBadgeType.voice;
      case ParsedFieldConfidence.low:
        return ConfidenceBadgeType.estimated;
    }
  }
}

class _ReviewItemRow extends StatelessWidget {
  const _ReviewItemRow({
    required this.name,
    required this.alias,
    required this.qty,
    required this.subtotal,
    required this.badge,
    required this.onDecrement,
    required this.onIncrement,
    this.isRejected = false,
    this.onToggleReject,
  });

  final String name;
  final String alias;
  final int qty;
  final String subtotal;
  final ConfidenceBadgeType badge;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isRejected;
  final VoidCallback? onToggleReject;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isRejected 
                  ? AppTheme.coral.withValues(alpha: 0.14)
                  : AppTheme.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isRejected 
                ? const Icon(Icons.close_rounded, color: AppTheme.coral, size: 18)
                : const Text('🍜'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: isRejected ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isRejected ? 'Rejected' : alias, 
                    style: textTheme.bodySmall?.copyWith(
                      color: isRejected 
                        ? AppTheme.coral 
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConfidenceBadge(type: badge),
                ],
              ),
            ),
            if (!isRejected) ...[
              Row(
                children: [
                  _QtyButton(icon: Icons.remove_rounded, onTap: onDecrement),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('$qty', style: AppTheme.mono(size: 18, color: AppTheme.charcoal)),
                  ),
                  _QtyButton(icon: Icons.add_rounded, onTap: onIncrement),
                ],
              ),
              const SizedBox(width: 12),
              Text(subtotal, style: AppTheme.mono(size: 16, color: AppTheme.amber)),
            ],
            if (onToggleReject != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onToggleReject,
                icon: Icon(
                  isRejected ? Icons.undo_rounded : Icons.close_rounded,
                  color: isRejected ? AppTheme.jade : AppTheme.coral,
                  size: 20,
                ),
                tooltip: isRejected ? 'Restore item' : 'Reject item',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.warmSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}