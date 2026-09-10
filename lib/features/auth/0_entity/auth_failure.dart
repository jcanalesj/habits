/// Motivos de fallo de autenticación que entiende el dominio. La capa de
/// datos traduce los códigos del proveedor (Firebase Auth) a estos valores
/// y la presentación los localiza.
enum AuthFailure {
  /// Correo o contraseña incorrectos, o cuenta inexistente. Firebase no
  /// distingue entre ambos (protección contra enumeración de emails).
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  network,
  requiresRecentLogin,

  /// No hay sesión activa para la operación solicitada.
  noSession,
  unknown,
}
