import 'package:habits/features/auth/0_entity/entity.dart';

/// Traduce los códigos de `FirebaseAuthException` a fallos de dominio.
/// Función pura para poder probarla sin plataforma.
AuthFailure authFailureFromCode(String code) {
  return switch (code) {
    // Con la protección contra enumeración de emails activa, Firebase
    // devuelve `invalid-credential` tanto para contraseña incorrecta como
    // para cuenta inexistente.
    'invalid-credential' ||
    'INVALID_LOGIN_CREDENTIALS' ||
    'wrong-password' ||
    'user-not-found' => AuthFailure.invalidCredentials,
    'email-already-in-use' => AuthFailure.emailAlreadyInUse,
    'weak-password' => AuthFailure.weakPassword,
    'invalid-email' => AuthFailure.invalidEmail,
    'user-disabled' => AuthFailure.userDisabled,
    'too-many-requests' => AuthFailure.tooManyRequests,
    'network-request-failed' => AuthFailure.network,
    'requires-recent-login' => AuthFailure.requiresRecentLogin,
    'no-current-user' => AuthFailure.noSession,
    _ => AuthFailure.unknown,
  };
}
