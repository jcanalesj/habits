import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/2_presentation/presentation.dart';
import 'package:habits/features/auth/2_presentation/routes/routes.dart'
    as auth_routes;
import 'package:habits/features/habits/2_presentation/routes/routes.dart'
    as habits_routes;
import 'package:habits/features/splash/2_presentation/routes/routes.dart'
    as splash_routes;
import 'package:habits/localization/l10n.dart';
import 'package:habits/widgets/app_shell.dart';
import 'package:habits/widgets/placeholder_page.dart';

const _splashPath = '/';
const _verifyEmailPath = '/verify-email';
const _publicPaths = {'/login', '/register', '/forgot-password'};

/// Decide la redirección según el estado real de sesión.
///
/// - Splash siempre accesible: es quien espera a que la sesión se restaure.
/// - Sesión sin restaurar: cualquier otra ruta vuelve al splash.
/// - Sin usuario: solo rutas públicas.
/// - Usuario sin verificar: solo la pantalla de verificación.
/// - Usuario verificado: las rutas de auth llevan a la home.
@visibleForTesting
String? resolveAuthRedirect(AsyncValue<AppUser?> auth, String path) {
  if (path == _splashPath) return null;
  if (auth.isLoading && !auth.hasValue) return _splashPath;

  final user = auth.value;
  if (user == null) return _publicPaths.contains(path) ? null : '/login';
  if (!user.emailVerified) {
    return path == _verifyEmailPath ? null : _verifyEmailPath;
  }
  if (_publicPaths.contains(path) || path == _verifyEmailPath) return '/home';
  return null;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final habitsRoutes = ref.watch(habits_routes.habitsRoutesProvider);
  final splashRoutes = ref.watch(splash_routes.splashRoutesProvider);
  final authRoutes = ref.watch(auth_routes.authRoutesProvider);

  // Cada cambio de sesión re-evalúa el redirect de la ruta actual.
  final sessionTick = ValueNotifier<int>(0);
  ref.onDispose(sessionTick.dispose);
  ref.listen(authControllerProvider, (_, _) => sessionTick.value++);

  return GoRouter(
    initialLocation: _splashPath,
    refreshListenable: sessionTick,
    redirect: (context, state) =>
        resolveAuthRedirect(ref.read(authControllerProvider), state.uri.path),
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
                  action: const SignOutButton(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
