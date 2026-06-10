import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';

/// Shows a splash loader while auth initialises, then routes to
/// [authenticatedChild] or [unauthenticatedChild] based on session state.
class AuthGate extends ConsumerWidget {
  final Widget authenticatedChild;
  final Widget unauthenticatedChild;

  const AuthGate({
    super.key,
    required this.authenticatedChild,
    required this.unauthenticatedChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    switch (authState.status) {
      case AuthStatus.initial:
        return const _SplashLoader();

      case AuthStatus.loading:
        return const _SplashLoader();

      case AuthStatus.authenticated:
        return authenticatedChild;

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return unauthenticatedChild;
    }
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF00112E),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AluLogo(),
            SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFD00D2D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AluLogo extends StatelessWidget {
  const _AluLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF002E6D),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002E6D).withValues(alpha: 0.6),
                blurRadius: 32,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: const Color(0xFFD00D2D).withValues(alpha: 0.2),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
              color: Color(0xFFF0F4FF),
              letterSpacing: -0.3,
            ),
            children: [
              TextSpan(text: 'ALU '),
              TextSpan(
                text: 'Connect',
                style: TextStyle(color: Color(0xFFD00D2D)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
