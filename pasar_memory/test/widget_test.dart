import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pasar_memory/app.dart';
import 'package:pasar_memory/data/local/database_factory_setup.dart';
import 'package:pasar_memory/features/auth/session_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await configureDatabaseFactory();
  });

  testWidgets('app renders the splash and login entry flow', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: PasarMemoryApp(),
      ),
    );

    expect(find.text('Pasar Memory'), findsOneWidget);
    expect(find.text('Your business. Your memory.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in to your Pasar Memory'), findsOneWidget);
  });

  test('session register stores a logged-in account', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).register(
          displayName: 'Kak Lina',
          phoneOrEmail: 'kaklina@example.com',
          password: 'password123',
          businessName: 'Gerai Kak Lina',
          businessType: 'Hawker / Noodles',
          preferredLanguage: 'English',
          email: 'kaklina@example.com',
        );

    final session = container.read(sessionProvider);
    expect(session.isLoggedIn, isTrue);
    expect(session.accountKey, 'kaklina@example.com');
    expect(session.businessName, 'Gerai Kak Lina');
    expect(session.errorMessage, isNull);
  });
}
