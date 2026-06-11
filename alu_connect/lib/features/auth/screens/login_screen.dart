import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).signIn(
          email: _emailCtrl.text,
          password: _passCtrl.text,
        );
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: ALUColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset password',
              style: TextStyle(
                color: ALUColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Enter your ALU email and we'll send a reset link.",
              style: TextStyle(color: ALUColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            AuthTextField(
              label: 'Email address',
              hint: 'you@alueducation.com',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.email_outlined,
                  color: ALUColors.textMuted, size: 16),
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Send reset link',
              onPressed: () {
                if (emailCtrl.text.trim().isNotEmpty) {
                  ref
                      .read(authNotifierProvider.notifier)
                      .resetPassword(emailCtrl.text);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reset link sent — check your inbox.'),
                      backgroundColor: ALUColors.navy,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: ALUColors.redDim,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: ALUColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const AluBrandMark(),
                const SizedBox(height: 32),

                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: ALUColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to your ALU Connect account',
                  style: TextStyle(color: ALUColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 26),

                if (authState.status == AuthStatus.error &&
                    authState.errorMessage != null) ...[
                  AuthErrorBanner(
                    message: authState.errorMessage!,
                    onDismiss: () =>
                        ref.read(authNotifierProvider.notifier).clearError(),
                  ),
                  const SizedBox(height: 16),
                ],

                AuthTextField(
                  label: 'Email address',
                  hint: 'you@alueducation.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _passFocus.requestFocus(),
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                AuthTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: ALUColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                AuthPrimaryButton(
                  label: 'Sign In',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),

                const OrDivider(),

                AuthOutlineButton(
                  label: 'Create Account',
                  onPressed: () => context.go(AppRoutes.register),
                ),

                AuthSwitchRow(
                  text: 'New to ALU Connect?',
                  linkText: 'Register here',
                  onTap: () => context.go(AppRoutes.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
