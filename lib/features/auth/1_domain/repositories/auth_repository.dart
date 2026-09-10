import 'package:habits/features/auth/0_entity/entity.dart';

/// Contrato de autenticación. La implementación de v1 es Firebase Auth con
/// email/contraseña; la arquitectura queda preparada para login social.
///
/// Todos los métodos lanzan [AuthException] ante un fallo del proveedor.
abstract class AuthRepository {
  /// Fuente de verdad de la sesión: emite el usuario actual al suscribirse y
  /// cada vez que cambia (login, logout, recarga tras verificar el email…).
  Stream<AppUser?> watchUser();

  /// Usuario con sesión activa, o null. Instantáneo, sin red.
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  /// Crea la cuenta y fija el nombre visible. El usuario queda con sesión
  /// iniciada pero sin verificar.
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();

  /// Envía (o reenvía) el enlace de verificación al usuario con sesión.
  Future<void> sendEmailVerification();

  /// Recarga el usuario desde el proveedor y devuelve su estado actualizado
  /// (p. ej. `emailVerified` tras pulsar el enlace). Null si no hay sesión.
  Future<AppUser?> reloadUser();

  Future<void> sendPasswordResetEmail({required String email});
}
