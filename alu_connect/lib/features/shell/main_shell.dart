import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _tabIndex(String path) {
    if (path.startsWith(AppRoutes.launchpad)) return 1;
    if (path.startsWith(AppRoutes.create)) return 2;
    if (path.startsWith(AppRoutes.communities)) return 3;
    if (path.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final idx = _tabIndex(path);

    return Scaffold(
      backgroundColor: ALUColors.background,
      body: child,
      floatingActionButton: idx == 2
          ? FloatingActionButton(
              backgroundColor: ALUColors.red,
              onPressed: () => context.go(AppRoutes.create),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: ALUColors.surface,
          border: Border(top: BorderSide(color: ALUColors.border, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) {
            const paths = [
              AppRoutes.home,
              AppRoutes.launchpad,
              AppRoutes.create,
              AppRoutes.communities,
              AppRoutes.profile,
            ];
            context.go(paths[i]);
          },
          backgroundColor: ALUColors.surface,
          selectedItemColor: ALUColors.red,
          unselectedItemColor: ALUColors.textMuted,
          selectedLabelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), activeIcon: Icon(Icons.lightbulb), label: 'Launchpad'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Create'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Community'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
