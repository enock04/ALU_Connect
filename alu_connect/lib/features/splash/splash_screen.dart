import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.85, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    // Router's auth guard handles logged-in redirect automatically.
    // Here we only decide: first launch → onboarding, returning → login.
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    if (!mounted) return;
    context.go(seenOnboarding ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ALUColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO: swap with Image.asset('assets/images/alu_logo.png') once assets are added
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: ALUColors.navy,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: ALUColors.border, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'ALU',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ALU Connect',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    color: ALUColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Where ideas become ventures',
                  style: TextStyle(fontSize: 14, color: ALUColors.textSecondary),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(ALUColors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
