import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'shared/theme/app_theme.dart';

class PasarMemoryApp extends ConsumerWidget {
  const PasarMemoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pasar Memory',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}