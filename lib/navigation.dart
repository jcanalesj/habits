import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/2_presentation/presentation.dart';
import 'package:habits/features/auth/2_presentation/routes/routes.dart'
    as auth_routes;
import 'package:habits/features/habits/2_presentation/pages/habit_calendars_page.dart';
import 'package:habits/features/habits/2_presentation/pages/habits_list_page.dart';
import 'package:habits/features/habits/2_presentation/pages/statistics_page.dart';
import 'package:habits/features/profile/profile_page.dart';
import 'package:habits/features/profile/avatar/avatar_picker_page.dart';
import 'package:habits/features/profile/timezone/timezone_page.dart';
import 'package:habits/features/profile/notifications/notification_settings_page.dart';
import 'package:habits/features/profile/appearance/appearance_page.dart';
import 'package:habits/features/profile/weight/weight_page.dart';
import 'package:habits/features/habits/2_presentation/routes/routes.dart'
    as habits_routes;
import 'package:habits/features/splash/2_presentation/routes/routes.dart'
    as splash_routes;
import 'package:habits/widgets/app_shell.dart';

const _splashPath = '/';
const _verifyEmailPath = '/verify-email';
const _welcomePath = '/welcome';
const _publicPaths = {'/login', '/register', '/forgot-password'};

/// Decide la redirección según el estado real de sesión.
///
/// - Splash siempre accesible: es quien espera a que la sesión se restaure.
/// - Sesión sin restaurar: cualquier otra ruta vuelve al splash.
/// - Sin usuario: solo rutas públicas.
/// - Recién registrado: anclado en la bienvenida hasta pulsar "Empezar".
/// - Con [requireEmailVerification], un usuario sin verificar solo puede
///   estar en la pantalla de verificación.
/// - En cualquier otro caso, las rutas de auth llevan a la home.
@visibleForTesting
String? resolveAuthRedirect(
  AsyncValue<AppUser?> auth,
  String path, {
  required bool requireEmailVerification,
  bool justRegistered = false,
}) {
  if (path == _splashPath) return null;
  if (auth.isLoading && !auth.hasValue) return _splashPath;

  final user = auth.value;
  if (user == null) return _publicPaths.contains(path) ? null : '/login';
  if (requireEmailVerification && !user.emailVerified) {
    return path == _verifyEmailPath ? null : _verifyEmailPath;
  }
  if (justRegistered) return path == _welcomePath ? null : _welcomePath;
  if (path == _welcomePath) return '/home';
  if (_publicPaths.contains(path) || path == _verifyEmailPath) return '/home';
  return null;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final habitsRoutes = ref.watch(habits_routes.habitsRoutesProvider);
  final habitFormRoutes = ref.watch(habits_routes.habitFormRoutesProvider);
  final splashRoutes = ref.watch(splash_routes.splashRoutesProvider);
  final authRoutes = ref.watch(auth_routes.authRoutesProvider);

  // Cada cambio de sesión re-evalúa el redirect de la ruta actual.
  final sessionTick = ValueNotifier<int>(0);
  ref.onDispose(sessionTick.dispose);
  ref.listen(authControllerProvider, (_, _) => sessionTick.value++);
  ref.listen(justRegisteredProvider, (_, _) => sessionTick.value++);

  return GoRouter(
    initialLocation: _splashPath,
    refreshListenable: sessionTick,
    redirect: (context, state) => resolveAuthRedirect(
      ref.read(authControllerProvider),
      state.uri.path,
      requireEmailVerification: ref.read(requireEmailVerificationProvider),
      justRegistered: ref.read(justRegisteredProvider),
    ),
    routes: [
      ...splashRoutes,
      ...authRoutes,
      // Fuera del shell: el formulario ocupa la pantalla completa.
      ...habitFormRoutes,
      GoRoute(
        path: '/profile/avatar',
        builder: (context, state) => const AvatarPickerPage(),
      ),
      GoRoute(
        path: '/profile/timezone',
        builder: (context, state) => const TimezonePage(),
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/profile/appearance',
        builder: (context, state) => const AppearancePage(),
      ),
      GoRoute(
        path: '/profile/weight',
        builder: (context, state) => const WeightPage(),
      ),
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
                    const HabitCalendarsPage(isHabitsTab: true),
                routes: [
                  GoRoute(
                    path: 'manage',
                    builder: (context, state) => const HabitsListPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
