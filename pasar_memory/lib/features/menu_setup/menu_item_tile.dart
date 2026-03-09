import 'package:flutter/material.dart';

import '../../models/menu_item.dart';

typedef MenuItemSaveCallback = Future<void> Function({
  required MenuItem item,
  required String name,
  required double price,
  required bool isActive,
  required List<String> aliases,
});

typedef MenuItemToggleActiveCallback = Future<void> Function(MenuItem item, bool isActive);

typedef MenuItemDeleteCallback = Future<void> Function(String id);

class MenuItemTile extends StatefulWidget {
  const MenuItemTile({
    super.key,
    required this.item,
    required this.aliases,
    required this.onSave,
    required this.onToggleActive,
    required this.onDelete,
    required this.busy,
  });

  final MenuItem item;
  final List<String> aliases;
  final MenuItemSaveCallback onSave;
  final MenuItemToggleActiveCallback onToggleActive;
  final MenuItemDeleteCallback onDelete;
  final bool busy;

  @override
  State<MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<MenuItemTile> {
  bool _editing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _aliasesController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.price.toStringAsFixed(2));
    _aliasesController = TextEditingController(text: widget.aliases.join(', '));
    _isActive = widget.item.isActive;
  }

  @override
  void didUpdateWidget(covariant MenuItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _nameController.text = widget.item.name;
      _priceController.text = widget.item.price.toStringAsFixed(2);
      _aliasesController.text = widget.aliases.join(', ');
      _isActive = widget.item.isActive;
      _editing = false;
      return;
    }

    if (oldWidget.item.name != widget.item.name && !_editing) {
      _nameController.text = widget.item.name;
    }

    if (oldWidget.item.price != widget.item.price && !_editing) {
      _priceController.text = widget.item.price.toStringAsFixed(2);
    }

    if (oldWidget.item.isActive != widget.item.isActive && !_editing) {
      _isActive = widget.item.isActive;
    }

    if (oldWidget.aliases != widget.aliases && !_editing) {
      _aliasesController.text = widget.aliases.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _aliasesController.dispose();
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

  Future<void> _save() async {
    final name = _nameController.text;
    final price = _parsePrice(_priceController.text);
    final aliases = _parseAliases(_aliasesController.text);

    if (price == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Invalid price.')));
      return;
    }

    await widget.onSave(
      item: widget.item,
      name: name,
      price: price,
      isActive: _isActive,
      aliases: aliases,
    );

    if (mounted) {
      setState(() {
        _editing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[
      'RM ${widget.item.price.toStringAsFixed(2)}',
      if (widget.aliases.isNotEmpty) widget.aliases.join(' · '),
    ].join('  •  ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            ListTile(
              title: Text(
                widget.item.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(subtitle),
              leading: Icon(widget.item.isActive ? Icons.check_circle : Icons.pause_circle),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: _editing ? 'Close' : 'Edit',
                    onPressed: widget.busy
                        ? null
                        : () {
                            setState(() {
                              _editing = !_editing;
                              _isActive = widget.item.isActive;
                            });
                          },
                    icon: Icon(_editing ? Icons.close : Icons.edit),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: widget.busy
                        ? null
                        : () async {
                            await widget.onDelete(widget.item.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(const SnackBar(content: Text('Deleted.')));
                            }
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 150),
              crossFadeState: _editing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isActive,
                      onChanged: widget.busy
                          ? null
                          : (v) async {
                              setState(() => _isActive = v);
                              await widget.onToggleActive(widget.item, v);
                            },
                      title: const Text('Active (shows in selling screen)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      enabled: !widget.busy,
                      decoration: const InputDecoration(labelText: 'Item name'),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _aliasesController,
                      enabled: !widget.busy,
                      decoration: const InputDecoration(
                        labelText: 'Aliases (comma separated)',
                        hintText: 'e.g. goreng, bihun goreng',
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      enabled: !widget.busy,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Price (RM)'),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: widget.busy ? null : _save,
                              child: const Text('Save', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: widget.busy
                                  ? null
                                  : () {
                                      setState(() {
                                        _editing = false;
                                        _nameController.text = widget.item.name;
                                        _priceController.text = widget.item.price.toStringAsFixed(2);
                                        _aliasesController.text = widget.aliases.join(', ');
                                        _isActive = widget.item.isActive;
                                      });
                                    },
                              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
