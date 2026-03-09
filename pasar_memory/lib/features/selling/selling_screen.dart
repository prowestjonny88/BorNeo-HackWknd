import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_bottom_nav.dart';
import 'selling_provider.dart';

class SellingScreen extends ConsumerWidget {
  const SellingScreen({super.key});

  int _crossAxisCountForWidth(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellingProvider);
    final controller = ref.read(sellingProvider.notifier);

    ref.listen<SellingState>(sellingProvider, (prev, next) {
      final prevError = prev?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != prevError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Selling (Optional)'),
        actions: [
          IconButton(
            tooltip: 'Add menu item',
            onPressed: () => context.go('/menu'),
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(
            tooltip: 'Refresh menu',
            onPressed: state.isLoading ? null : controller.refreshMenu,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Reset taps',
            onPressed: state.totalTaps == 0 ? null : controller.resetAll,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tap items during slow periods. This is supplemental evidence.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (state.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (state.menuItems.isEmpty) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.restaurant_menu, size: 40),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No active menu items yet.',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Add items in Menu Setup first.'),
                                  ],
                                ),
                              ),
                            );
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = _crossAxisCountForWidth(constraints.maxWidth);

                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.25,
                                ),
                                itemCount: state.menuItems.length,
                                itemBuilder: (context, index) {
                                  final item = state.menuItems[index];
                                  final count = state.countFor(item);

                                  return SizedBox.expand(
                                    child: FilledButton(
                                      onPressed: () => controller.tap(item),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              item.name,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'RM ${item.price.toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 10),
                                            if (count > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.surface,
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                                child: Text(
                                                  'x$count',
                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                                ),
                                              )
                                            else
                                              Text(
                                                'Tap',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.85),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Taps: ${state.totalTaps}  •  Est: RM ${state.estimatedTotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AppBottomNav(currentRoute: '/selling'),
          ],
        ),
      ),
    );
  }
}
