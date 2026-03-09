import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cash_entry_provider.dart';

class CashEntryScreen extends ConsumerStatefulWidget {
  const CashEntryScreen({super.key});

  @override
  ConsumerState<CashEntryScreen> createState() => _CashEntryScreenState();
}

class _CashEntryScreenState extends ConsumerState<CashEntryScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ProviderSubscription<CashEntryState> _cashEntrySubscription;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _cashEntrySubscription = ref.listenManual<CashEntryState>(cashEntryProvider, (prev, next) {
      if (next.amountText != _controller.text) {
        _controller.value = _controller.value.copyWith(
          text: next.amountText,
          selection: TextSelection.collapsed(offset: next.amountText.length),
        );
      }

      final prevBanner = prev?.bannerMessage;
      final nextBanner = next.bannerMessage;
      if (nextBanner != null && nextBanner != prevBanner) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextBanner)));
      }

      if (prev?.isConfirmed == false && next.isConfirmed == true) {
        FocusScope.of(context).unfocus();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _cashEntrySubscription.close();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashEntryProvider);
    final controller = ref.read(cashEntryProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Counted Cash'),
          leading: IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter the counted cash now.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'This is merchant-confirmed and should not be skipped.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Cash (RM)',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          enabled: !state.isConfirmed,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                            _SingleDecimalPointFormatter(),
                          ],
                          onChanged: controller.setAmountText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: const OutlineInputBorder(),
                            helperText: state.wasPrefilled ? 'Prefilled from voice recap' : 'Count notes + coins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 64,
                          child: FilledButton.icon(
                            onPressed: state.canConfirm
                                ? () {
                                    controller.confirm();
                                  }
                                : null,
                            icon: const Icon(Icons.verified_outlined),
                            label: Text(
                              state.isConfirmed ? 'Confirmed' : 'Confirm cash',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Label: merchant-confirmed',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: state.isConfirmed ? () => context.go('/review') : null,
                    child: const Text('Continue to Review ->'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tip: If you recorded a voice recap, we may prefill this value for you.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
    );
  }
}


class _SingleDecimalPointFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final first = text.indexOf('.');
    if (first == -1) return newValue;

    final second = text.indexOf('.', first + 1);
    if (second == -1) return newValue;

    // Remove extra decimal points.
    final cleaned = text.replaceFirst('.', '').replaceFirst('.', '.');
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
