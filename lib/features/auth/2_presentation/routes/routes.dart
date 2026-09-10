import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/auth/2_presentation/pages/login_page.dart';
import 'package:habits/features/auth/2_presentation/pages/register_page.dart';
import 'package:habits/features/auth/2_presentation/pages/verify_email_page.dart';

/// Rutas de la feature de autenticación.
final authRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => VerifyEmailPage(
        email: state.uri.queryParameters['email'] ?? 'ejemplo@correo.com',
        displayName: state.uri.queryParameters['nickname'],
      ),
    ),
  ];
});
