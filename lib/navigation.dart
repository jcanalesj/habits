import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/routes/routes.dart'
    as auth_routes;
import 'package:habits/features/habits/2_presentation/routes/routes.dart'
    as habits_routes;
import 'package:habits/features/splash/2_presentation/routes/routes.dart'
    as splash_routes;
import 'package:habits/localization/l10n.dart';
import 'package:habits/widgets/app_shell.dart';
import 'package:habits/widgets/placeholder_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final habitsRoutes = ref.watch(habits_routes.habitsRoutesProvider);
  final splashRoutes = ref.watch(splash_routes.splashRoutesProvider);
  final authRoutes = ref.watch(auth_routes.authRoutesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = ref.read(authControllerProvider) != null;
      final path = state.uri.path;
      final isSplash = path == '/';
      final isLogin = path == '/login';
      final isRegister = path == '/register';
      final isVerifyEmail = path == '/verify-email';

      if (!loggedIn && !isSplash && !isLogin && !isRegister && !isVerifyEmail) {
        return '/login';
      }
      if (loggedIn && (isLogin || isRegister || isVerifyEmail)) return '/home';
      return null;
    },
    routes: [
      ...splashRoutes,
      ...authRoutes,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: habitsRoutes),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) =>
                    PlaceholderPage(title: context.l10n.navHabits, emoji: '✅'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) =>
                    PlaceholderPage(title: context.l10n.navStats, emoji: '📊'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => PlaceholderPage(
                  title: context.l10n.navProfile,
                  emoji: '👤',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
