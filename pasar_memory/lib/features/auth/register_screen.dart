import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/remote/supabase_client.dart';
import '../../shared/theme/app_theme.dart';
import 'session_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  late final TextEditingController _businessNameController;
  String? _businessType;
  String _language = 'English';
  bool _agreeTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static const _businessTypes = [
    'Hawker / Noodles',
    'Rice Dishes',
    'Drinks & Beverages',
    'Lauk Pauk / Sides',
    'Bakery / Kuih',
    'Wet Market / Fresh',
    'Dry Goods / Grocery',
    'Snacks & Street Food',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _businessNameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _pickBusinessType() async {
    final customController = TextEditingController(text: _businessType ?? '');
    String? draft = _businessType;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.warmSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('What type of business?', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Select one or type your own below.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _businessTypes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 48,
                    ),
                    itemBuilder: (context, index) {
                      final type = _businessTypes[index];
                      final selected = draft == type;
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setSheetState(() {
                          draft = type;
                          customController.text = type;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.amber : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: selected ? AppTheme.amber : Colors.grey.shade300),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(type, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('or type your own', style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: customController,
                    onChanged: (value) => draft = value.trim(),
                    decoration: InputDecoration(
                      hintText: 'e.g. Char Kuey Teow, Nasi Kandar, Fruits...',
                      suffixIcon: IconButton(
                        onPressed: () => Navigator.of(context).pop(customController.text.trim()),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop((draft ?? customController.text).trim()),
                    child: const Text('Confirm Business Type ->'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    customController.dispose();
    if (!mounted || result == null || result.trim().isEmpty) return;
    setState(() => _businessType = result.trim());
  }

  Future<void> _submit() async {
    final usesCloudSync = SupabaseClientProvider.isConfigured;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final businessName = _businessNameController.text.trim();
    final businessType = (_businessType ?? '').trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty ||
        businessName.isEmpty ||
        businessType.isEmpty ||
        !_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form first.')),
      );
      return;
    }
    if (usesCloudSync && (email.isEmpty || !_emailPattern.hasMatch(email))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email for cloud sync.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    await ref.read(sessionProvider.notifier).register(
          displayName: name,
          phoneOrEmail: phone,
          password: password,
          businessName: businessName,
          businessType: businessType,
          preferredLanguage: _language,
          email: email,
        );
    if (!mounted) return;
    final session = ref.read(sessionProvider);
    if (session.isLoggedIn && session.accountKey.isNotEmpty && session.errorMessage == null) {
      context.go('/menu-setup');
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.softWhite),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Create Account', style: textTheme.headlineMedium?.copyWith(color: AppTheme.softWhite, fontSize: 26)),
                          const SizedBox(height: 4),
                          Text(
                            'Start building your business memory',
                            style: textTheme.bodyLarge?.copyWith(color: AppTheme.softWhite.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.warmSurface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text('YOUR DETAILS', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'Your name'),
                      const SizedBox(height: 6),
                      TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'e.g. Kak Lina', prefixIcon: Icon(Icons.person_outline_rounded))),
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'Phone number'),
                      const SizedBox(height: 6),
                      TextField(controller: _phoneController, decoration: const InputDecoration(hintText: '+60 1X-XXXXXXX', prefixIcon: Icon(Icons.phone_iphone_rounded))),
                      const SizedBox(height: 16),
                      _FieldLabel(label: usesCloudSync ? 'Email' : 'Email (optional)', muted: !usesCloudSync),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: usesCloudSync ? 'Used for Supabase sign in on any device' : 'For account recovery',
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                        ),
                      ),
                      if (usesCloudSync) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Supabase sign in uses your email and password. Your phone still stays on the profile.',
                          style: textTheme.bodySmall?.copyWith(color: AppTheme.charcoal.withValues(alpha: 0.7)),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'Password'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Create a password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'Confirm password'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 18),
                      Text('YOUR BUSINESS', style: textTheme.labelMedium?.copyWith(color: AppTheme.amber, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'Stall / business name'),
                      const SizedBox(height: 6),
                      TextField(controller: _businessNameController, decoration: const InputDecoration(hintText: 'e.g. Gerai Kak Lina', prefixIcon: Icon(Icons.storefront_outlined))),
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'What do you sell?'),
                      const SizedBox(height: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _pickBusinessType,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.restaurant_menu_rounded),
                            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                          child: Text(
                            _businessType ?? 'Select or type your business type',
                            style: textTheme.bodyMedium?.copyWith(
                              color: _businessType == null ? Theme.of(context).colorScheme.onSurfaceVariant : AppTheme.charcoal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(label: 'Preferred language'),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Bahasa Melayu', 'English', '中文'].map((language) {
                          final active = _language == language;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => setState(() => _language = language),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: active ? AppTheme.amber : Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: active ? AppTheme.amber : Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    language,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: active ? AppTheme.charcoal : AppTheme.charcoal,
                                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreeTerms,
                            activeColor: AppTheme.amber,
                            onChanged: (value) => setState(() => _agreeTerms = value ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                children: [
                                  Text('I agree to the ', style: textTheme.bodySmall),
                                  Text('Terms of Service', style: textTheme.bodySmall?.copyWith(color: AppTheme.amber, decoration: TextDecoration.underline)),
                                  Text(' and ', style: textTheme.bodySmall),
                                  Text('Privacy Policy', style: textTheme.bodySmall?.copyWith(color: AppTheme.amber, decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: session.isBusy ? null : _submit,
                        child: session.isBusy
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Create My Account ->'),
                      ),
                      if (session.errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          session.errorMessage!,
                          style: textTheme.bodySmall?.copyWith(color: AppTheme.coral, fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Center(
                        child: Wrap(
                          children: [
                            Text('Already have an account? ', style: textTheme.bodyMedium),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text('Log in', style: textTheme.bodyMedium?.copyWith(color: AppTheme.amber, fontWeight: FontWeight.w700)),
                            ),
                          ],
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
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: muted ? Theme.of(context).colorScheme.onSurfaceVariant : AppTheme.charcoal,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}