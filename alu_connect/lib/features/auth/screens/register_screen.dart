import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cohortCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passFocus = FocusNode();
  final _cohortFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passCtrl.dispose();
    _cohortCtrl.dispose();
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _passFocus.dispose();
    _cohortFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cohort = int.tryParse(_cohortCtrl.text.trim()) ?? 2024;
    ref.read(authNotifierProvider.notifier).signUp(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          fullName: _nameCtrl.text,
          username: _usernameCtrl.text,
          cohortYear: cohort,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.roleSelect);
      }
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
                  'Create Account',
                  style: TextStyle(
                    color: ALUColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join the ALU student community',
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
                  label: 'Full name',
                  hint: 'Amara Diallo',
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    if (v.trim().split(' ').length < 2) {
                      return 'Enter your first and last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                AuthTextField(
                  label: 'ALU Email',
                  hint: 'a.diallo@alueducation.com',
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _usernameFocus.requestFocus(),
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
                  label: 'Username',
                  hint: 'amara_diallo',
                  controller: _usernameCtrl,
                  focusNode: _usernameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _passFocus.requestFocus(),
                  prefixIcon: const Icon(Icons.alternate_email_rounded,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (v.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (v.contains(' ')) return 'No spaces in username';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                AuthTextField(
                  label: 'Password',
                  hint: 'Min. 8 characters',
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _cohortFocus.requestFocus(),
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                AuthTextField(
                  label: 'Cohort Year',
                  hint: 'e.g. 2024',
                  controller: _cohortCtrl,
                  focusNode: _cohortFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  prefixIcon: const Icon(Icons.school_outlined,
                      color: ALUColors.textMuted, size: 16),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null; // optional
                    final year = int.tryParse(v.trim());
                    if (year == null || year < 2019 || year > 2030) {
                      return 'Enter a valid cohort year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                AuthPrimaryButton(
                  label: 'Continue',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),

                AuthSwitchRow(
                  text: 'Already have an account?',
                  linkText: 'Sign in',
                  onTap: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
