import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session_provider.dart';
import 'home_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/quick_tap_button.dart';
import '../selling/selling_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final session = ref.watch(sessionProvider);
    final sellingState = ref.watch(sellingProvider);
    final textTheme = Theme.of(context).textTheme;
    final displayName = _displayNameFor(session);
    final greeting = _greetingFor(session, displayName);
    final visibleItems = sellingState.menuItems.take(8).toList(growable: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [session.isNight ? const Color(0xFF0A1020) : AppTheme.deepForest, AppTheme.forestGradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          child: Text(
                            _initialsFor(displayName),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppTheme.softWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_rounded, color: AppTheme.softWhite),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${greeting.text} ${greeting.emoji}',
                      style: textTheme.titleMedium?.copyWith(color: AppTheme.softWhite),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.businessName} • ${session.businessType}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.softWhite.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.all(18),
                      borderColor: greeting.highlight.withValues(alpha: 0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODAY • 08 MAR 2026',
                            style: textTheme.labelMedium?.copyWith(color: AppTheme.amber),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            homeState.totalSales > 0
                                ? 'RM ${homeState.totalSales.toStringAsFixed(2)}'
                                : 'RM --.--',
                            style: AppTheme.mono(size: 38),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatPill(icon: Icons.phone_android_rounded, label: 'RM ${homeState.digitalTotal.toStringAsFixed(2)} Digital'),
                              _StatPill(icon: Icons.payments_outlined, label: 'RM ${homeState.cashTotal.toStringAsFixed(2)} Cash'),
                              _StatPill(icon: Icons.touch_app_rounded, label: '${sellingState.totalTaps} Taps'),
                              if (homeState.unresolvedMatches > 0)
                                _StatPill(
                                  icon: Icons.warning_amber_rounded,
                                  label: '${homeState.unresolvedMatches} Review',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text('QUICK TAPS', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => context.go('/menu'),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add item'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.amber,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to count a sale. Long press to undo or adjust.',
                      style: textTheme.bodySmall?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.72)),
                    ),
                    const SizedBox(height: 12),
                    if (visibleItems.isEmpty)
                      Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                            children: List.generate(
                              4,
                              (index) => const QuickTapButton(
                                title: 'Tap to add\nmenu items',
                                icon: Icon(Icons.restaurant_menu_rounded, color: AppTheme.softWhite, size: 24),
                                count: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => context.go('/menu-setup'),
                              child: const Text('⚙️ Set up menu'),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibleItems.length.clamp(0, 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          final count = sellingState.countFor(item);
                          return QuickTapButton(
                            title: item.name,
                            icon: Icon(_iconForItem(item.name), color: AppTheme.softWhite, size: 22),
                            count: count,
                            onTap: () => ref.read(sellingProvider.notifier).tap(item),
                            onLongPress: () => _showTapActions(context, ref, item, count),
                          );
                        },
                      ),
                      if (sellingState.menuItems.length > 8)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/selling'),
                            child: const Text('See all items'),
                          ),
                        ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go('/capture'),
                      child: Text(homeState.flowState == DayFlowState.initial ? 'Start End-of-Day Recap ->' : 'Continue Day Flow ->'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.go(homeState.flowState == DayFlowState.readyToReview ? '/review' : '/capture'),
                      child: Text(homeState.flowState == DayFlowState.readyToReview ? 'Go to Review' : 'View Today\'s Evidence'),
                    ),
                  ],
                ),
              ),
              const AppBottomNav(currentRoute: '/'),
            ],
          ),
        ),
      ),
    );
  }

  String _displayNameFor(SessionState session) {
    final cleaned = session.displayName.trim();
    if (cleaned.isNotEmpty && cleaned != 'Your Name') {
      return cleaned;
    }

    final businessName = session.businessName.trim();
    if (businessName.isNotEmpty && businessName != 'Your Stall') {
      return businessName;
    }

    return 'there';
  }

  GreetingTone _greetingFor(SessionState session, String displayName) {
    switch (session.timeOfDay) {
      case SessionTimeOfDay.morning:
        return GreetingTone(text: 'Good morning, $displayName', emoji: '☀️', highlight: AppTheme.amber.withValues(alpha: 0.38));
      case SessionTimeOfDay.afternoon:
        return GreetingTone(text: 'Good afternoon, $displayName', emoji: '🌤️', highlight: AppTheme.amber.withValues(alpha: 0.5));
      case SessionTimeOfDay.evening:
        return GreetingTone(text: 'Good evening, $displayName', emoji: '🌆', highlight: AppTheme.coral.withValues(alpha: 0.5));
      case SessionTimeOfDay.night:
        return GreetingTone(text: 'Good night, $displayName', emoji: '🌙', highlight: AppTheme.voicePurple.withValues(alpha: 0.32));
    }
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'PM';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  IconData _iconForItem(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mee') || lower.contains('bihun') || lower.contains('laksa')) return Icons.ramen_dining_rounded;
    if (lower.contains('nasi') || lower.contains('rice')) return Icons.rice_bowl_rounded;
    if (lower.contains('teh') || lower.contains('kopi') || lower.contains('milo')) return Icons.local_cafe_rounded;
    if (lower.contains('juice') || lower.contains('sirap')) return Icons.local_drink_rounded;
    if (lower.contains('ayam') || lower.contains('chicken')) return Icons.lunch_dining_rounded;
    return Icons.restaurant_rounded;
  }

  void _showTapActions(BuildContext context, WidgetRef ref, dynamic item, int count) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.warmSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(height: 14),
              Text('${item.name} — $count taps', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  ref.read(sellingProvider.notifier).tap(item);
                  Navigator.of(context).pop();
                },
                child: const Text('Add tap'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: count == 0
                    ? null
                    : () {
                        final controller = ref.read(sellingProvider.notifier);
                        controller.removeTap(item);
                        Navigator.of(context).pop();
                      },
                child: const Text('Remove last tap'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GreetingTone {
  const GreetingTone({required this.text, required this.emoji, required this.highlight});

  final String text;
  final String emoji;
  final Color highlight;
}


class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.softWhite),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.softWhite)),
        ],
      ),
    );
  }
}