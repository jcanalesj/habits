import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/auth/2_presentation/pages/forgot_password_page.dart';
import 'package:habits/features/auth/2_presentation/pages/login_page.dart';
import 'package:habits/features/auth/2_presentation/pages/register_page.dart';
import 'package:habits/features/auth/2_presentation/pages/verify_email_page.dart';
import 'package:habits/features/auth/2_presentation/pages/welcome_page.dart';

/// Rutas de la feature de autenticación. El acceso a cada una según el
/// estado de sesión lo decide el `redirect` global de navigation.dart.
///
/// `/login` y `/forgot-password` aceptan `?email=` para llegar con el campo
/// precargado desde el registro.
final authRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          LoginPage(initialEmail: state.uri.queryParameters['email']),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) =>
          ForgotPasswordPage(initialEmail: state.uri.queryParameters['email']),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const VerifyEmailPage(),
    ),
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomePage()),
  ];
});
