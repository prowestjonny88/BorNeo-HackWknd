import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session_provider.dart';
import '../../data/local/menu_file_cache.dart';
import 'menu_item_tile.dart';
import 'menu_setup_provider.dart';

class MenuSetupScreen extends ConsumerStatefulWidget {
  const MenuSetupScreen({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  ConsumerState<MenuSetupScreen> createState() => _MenuSetupScreenState();
}

class _MenuSetupScreenState extends ConsumerState<MenuSetupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _aliasesController;
  late final TextEditingController _priceController;
  late final ProviderSubscription<MenuSetupState> _menuSetupSubscription;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _aliasesController = TextEditingController();
    _priceController = TextEditingController();

    _menuSetupSubscription = ref.listenManual<MenuSetupState>(menuSetupProvider, (prev, next) {
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
    _menuSetupSubscription.close();
    _nameController.dispose();
    _aliasesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<String> _parseAliases(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  double? _parsePrice(String raw) {
    final normalized = raw
      .replaceAll(RegExp(r'rm', caseSensitive: false), '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(normalized);
  }

  Future<void> _add(MenuSetupController controller) async {
    final name = _nameController.text;
    final price = _parsePrice(_priceController.text);
    final aliases = _parseAliases(_aliasesController.text);

    if (price == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Invalid price.')));
      return;
    }

    final saved = await controller.addMenuItem(name: name, price: price, aliases: aliases);

    if (mounted && saved) {
      _nameController.clear();
      _aliasesController.clear();
      _priceController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuSetupProvider);
    final controller = ref.read(menuSetupProvider.notifier);
    final isOnboarding = widget.isOnboarding;

    return Scaffold(
      backgroundColor: widget.isOnboarding ? const Color(0xFFF8F3EC) : null,
      appBar: isOnboarding
          ? null
          : AppBar(
              title: const Text('Menu Setup'),
              actions: [
                IconButton(
                  tooltip: 'Check cache',
                  icon: const Icon(Icons.storage_rounded),
                  onPressed: () async {
                    final accountId = ref.read(sessionProvider).accountKey;
                    final summary = await MenuFileCache().debugSummary(accountId);
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Local Cache'),
                        content: SelectableText(summary),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: state.isLoading ? null : controller.refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
      body: Column(
        children: [
          if (isOnboarding)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              color: const Color(0xFF1A2E22),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    Text(
                      'Step 1 of 1 - Setup',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set Up Your Menu',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add the items you sell. You can always edit later.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, isOnboarding ? 20 : 20, 20, 20),
                children: [
                  Text(
                    isOnboarding
                        ? 'Add the real items you sell. Keep this clean and simple.'
                        : 'Add your best sellers first. You can edit everything later.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'ADD A MENU ITEM',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No presets. Just enter the items and prices your stall actually uses.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            enabled: !state.isSaving,
                            decoration: const InputDecoration(
                              labelText: 'Item name',
                              hintText: 'e.g. Nasi Lemak Ayam',
                            ),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _aliasesController,
                            enabled: !state.isSaving,
                            decoration: const InputDecoration(
                              labelText: 'Aliases (optional)',
                              hintText: 'e.g. lemak, ayam set',
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _priceController,
                            enabled: !state.isSaving,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Price (RM)',
                              hintText: 'e.g. 6.50',
                            ),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: state.isSaving ? null : () => _add(controller),
                              icon: const Icon(Icons.add_rounded),
                              label: state.isSaving
                                  ? const Text('Saving…', style: TextStyle(fontSize: 18))
                                  : const Text('Add item', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/'),
                              icon: const Icon(Icons.home_rounded),
                              label: const Text('Back to Home', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          if (isOnboarding) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: state.isSaving
                                  ? null
                                  : () async {
                                await ref.read(sessionProvider.notifier).completeMenuSetup();
                                if (!context.mounted) return;
                                context.go('/');
                              },
                              child: const Text('Skip for now. I\'ll set up later'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.items.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.ramen_dining_rounded, size: 42),
                            const SizedBox(height: 12),
                            Text(
                              'Your menu is empty. Add your first item above.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...state.items.map(
                      (item) => MenuItemTile(
                        item: item,
                        aliases: state.aliasesById[item.id] ?? const <String>[],
                        busy: state.isSaving,
                        onToggleActive: controller.toggleActive,
                        onDelete: controller.deleteMenuItem,
                        onSave: ({
                          required item,
                          required name,
                          required price,
                          required isActive,
                          required aliases,
                        }) async {
                          await controller.updateMenuItem(
                            item: item,
                            name: name,
                            price: price,
                            isActive: isActive,
                            aliases: aliases,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (isOnboarding)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0x1400C2A8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Aliases help match messy receipt names or voice recap phrasing later, but they are optional.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  Text(
                    'Aliases help match messy receipts or shorthand names later.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


