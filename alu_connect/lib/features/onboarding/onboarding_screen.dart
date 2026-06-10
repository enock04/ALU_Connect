import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/app_router.dart';
import '../../shared/widgets/alu_button.dart';

class _Slide {
  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  const _Slide({required this.title, required this.body, required this.icon, required this.accent});
}

const _slides = [
  _Slide(
    title: 'Your Campus, Connected',
    body: 'Discover events, job opportunities, and community channels all in one place – built for ALU students.',
    icon: Icons.hub_rounded,
    accent: ALUColors.navyLight,
  ),
  _Slide(
    title: 'Launch Your Idea',
    body: 'Post your startup idea, find co-founders with the skills you need. 3 backers unlocks your team chat.',
    icon: Icons.rocket_launch_rounded,
    accent: ALUColors.red,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _done();
    }
  }

  Future<void> _done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ALUColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _done,
                child: const Text('Skip', style: TextStyle(color: ALUColors.textMuted)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? ALUColors.red : ALUColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ALUButton(
                label: _page == _slides.length - 1 ? 'Get Started' : 'Next',
                onPressed: _next,
                icon: _page == _slides.length - 1 ? Icons.arrow_forward : null,
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: slide.accent.withValues(alpha: 0.4), width: 2),
            ),
            child: Icon(slide.icon, size: 54, color: slide.accent),
          ),
          const SizedBox(height: 36),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: ALUColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: ALUColors.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}
