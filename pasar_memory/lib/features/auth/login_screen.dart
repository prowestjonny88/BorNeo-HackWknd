import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/remote/supabase_client.dart';
import '../../shared/theme/app_theme.dart';
import 'session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  void _showAltLoginMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Use the phone or email form for now. Social login is not wired yet.')));
  }

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final target = await ref.read(sessionProvider.notifier).login(
          phoneOrEmail: _identifierController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    switch (target) {
      case LoginTarget.register:
        // Stay on login and show session error instead of forcing registration.
        break;
      case LoginTarget.menuSetup:
        context.go('/menu-setup');
        break;
      case LoginTarget.home:
        context.go('/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final textTheme = Theme.of(context).textTheme;
    final usesCloudSync = SupabaseClientProvider.isConfigured;

    return Scaffold(
      body: Container(
        color: AppTheme.deepForest,
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Icon(Icons.menu_book_rounded, size: 64, color: AppTheme.amber),
                    const SizedBox(height: 16),
                    Text('Welcome back', style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite, fontSize: 26)),
                    const SizedBox(height: 6),
                    Text(
                      'Log in to your Pasar Memory',
                      style: textTheme.bodyLarge?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
                  decoration: const BoxDecoration(
                    color: AppTheme.warmSurface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('LOGIN', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber, letterSpacing: 2)),
                        const SizedBox(height: 18),
                        _FieldLabel(label: 'Phone number or email'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _identifierController,
                          decoration: InputDecoration(
                            hintText: '+60 or email address',
                            prefixIcon: const Icon(Icons.phone_iphone_rounded),
                          ),
                        ),
                        if (usesCloudSync) ...[
                          const SizedBox(height: 8),
                          Text(
                            'You can login with email, or with phone after your first successful synced login.',
                            style: textTheme.bodySmall?.copyWith(color: AppTheme.charcoal.withValues(alpha: 0.7)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _FieldLabel(label: 'Password'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot password?',
                            style: textTheme.bodyMedium?.copyWith(color: AppTheme.amber, decoration: TextDecoration.underline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: session.isBusy ? null : _submit,
                          child: session.isBusy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Log In ->'),
                        ),
                        if (session.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(session.errorMessage!, style: textTheme.bodySmall?.copyWith(color: AppTheme.coral)),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('or', style: textTheme.bodySmall),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _showAltLoginMessage,
                                child: const Text('Continue with Google'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _showAltLoginMessage,
                                child: const Text('Continue with Phone OTP'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Wrap(
                            children: [
                              Text('Don\'t have an account? ', style: textTheme.bodyMedium),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: Text(
                                  'Register here',
                                  style: textTheme.bodyMedium?.copyWith(color: AppTheme.amber, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.charcoal,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}