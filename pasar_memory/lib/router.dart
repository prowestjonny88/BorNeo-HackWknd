import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Home Placeholder'))),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Onboarding Placeholder'))),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Menu Setup Placeholder'))),
      ),
      GoRoute(
        path: '/selling',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Selling Placeholder'))),
      ),
      GoRoute(
        path: '/import',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Import Placeholder'))),
      ),
      GoRoute(
        path: '/summary',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Summary Placeholder'))),
      ),
    ],
  );
});