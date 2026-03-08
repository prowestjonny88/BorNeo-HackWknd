import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import the screen you just created
import 'features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 1.1.13 Home Screen (Dev 1)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Phase 1 - Dev 2: Onboarding & Evidence Capture
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Onboarding Screen Placeholder')),
        ),
      ),
      GoRoute(
        path: '/capture',
        name: 'capture',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Evidence Capture Screen Placeholder')),
        ),
      ),

      // Phase 1 - Dev 3: OCR & Matching
      GoRoute(
        path: '/matching',
        name: 'matching',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('OCR Matching Screen Placeholder')),
        ),
      ),

      // Phase 1 - Dev 4: Summary & Review
      GoRoute(
        path: '/review',
        name: 'review',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Daily Ledger Review Placeholder')),
        ),
      ),

      // Shared/Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings Screen Placeholder')),
        ),
      ),
    ],
    // Error handling for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});