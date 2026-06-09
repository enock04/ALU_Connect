import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_state.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/main_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelect = '/role';

  static const String home = '/home';
  static const String launchpad = '/launchpad';
  static const String create = '/create';
  static const String communities = '/communities';
  static const String profile = '/profile';

  static const String eventDetail = '/home/event/:id';
  static String eventDetailPath(String id) => '/home/event/$id';

  static const String chatRoom = '/communities/chat/:id';
  static String chatRoomPath(String id) => '/communities/chat/$id';

  static const String ideaDetail = '/launchpad/idea/:id';
  static String ideaDetailPath(String id) => '/launchpad/idea/$id';

  static const String postIdea = '/launchpad/post-idea';
}

// placeholder until each member builds their screen
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen(this.label);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: Center(child: Text('$label – coming soon')),
      );
}

final routerProvider = Provider<GoRouter>((ref) {
  // create notifier once — holds current isLoggedIn and fires GoRouter
  // redirect re-evaluation via refreshListenable. We intentionally do NOT
  // ref.watch here; watching would rebuild the entire router on every auth
  // change and reset the nav stack mid-splash.
  final authNotifier = _AuthNotifier(ref);
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final loc = state.uri.path;
      const publicRoutes = ['/', '/onboarding', '/login', '/register', '/role'];
      final isPublic = publicRoutes.contains(loc);
      final isLoggedIn = authNotifier.isLoggedIn;

      if (!isLoggedIn && !isPublic) return AppRoutes.login;
      if (isLoggedIn && isPublic && loc != '/') return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const _PlaceholderScreen('Login'),
        // TODO: Member 2 → LoginScreen()
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const _PlaceholderScreen('Register'),
        // TODO: Member 2 → RegisterScreen()
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        name: 'roleSelect',
        builder: (_, __) => const _PlaceholderScreen('Role Select'),
        // TODO: Member 2 → RoleSelectScreen()
      ),

      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (_, __) => const _PlaceholderScreen('Home Feed'),
            // TODO: Member 3 → HomeFeedScreen()
            routes: [
              GoRoute(
                path: 'event/:id',
                name: 'eventDetail',
                builder: (_, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return _PlaceholderScreen('Event Detail ($id)');
                  // TODO: Member 3 → EventDetailScreen(id: id)
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.launchpad,
            name: 'launchpad',
            builder: (_, __) => const _PlaceholderScreen('Launchpad'),
            // TODO: Member 5 → LaunchpadScreen()
            routes: [
              GoRoute(
                path: 'idea/:id',
                name: 'ideaDetail',
                builder: (_, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return _PlaceholderScreen('Idea Detail ($id)');
                  // TODO: Member 5 → IdeaDetailScreen(id: id)
                },
              ),
              GoRoute(
                path: 'post-idea',
                name: 'postIdea',
                builder: (_, __) => const _PlaceholderScreen('Post Idea'),
                // TODO: Member 5 → PostIdeaScreen()
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.create,
            name: 'create',
            builder: (_, __) => const _PlaceholderScreen('Create Post'),
            // TODO: Member 4 → CreatePostScreen()
          ),
          GoRoute(
            path: AppRoutes.communities,
            name: 'communities',
            builder: (_, __) => const _PlaceholderScreen('Communities'),
            // TODO: Member 4 → CommunitiesScreen()
            routes: [
              GoRoute(
                path: 'chat/:id',
                name: 'chatRoom',
                builder: (_, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return _PlaceholderScreen('Chat Room ($id)');
                  // TODO: Member 4 → ChatRoomScreen(roomId: id)
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (_, __) => const _PlaceholderScreen('Profile'),
            // TODO: Member 2 → ProfileScreen()
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// bridges Riverpod auth state → GoRouter redirect re-evaluation.
// stores isLoggedIn so the redirect callback can read it synchronously.
class _AuthNotifier extends ChangeNotifier {
  bool isLoggedIn;

  _AuthNotifier(Ref ref) : isLoggedIn = ref.read(isLoggedInProvider) {
    ref.listen(isLoggedInProvider, (_, next) {
      isLoggedIn = next;
      notifyListeners();
    });
  }
}
