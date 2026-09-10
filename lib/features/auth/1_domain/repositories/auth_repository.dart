import 'package:habits/features/auth/0_entity/entity.dart';

/// Contrato de autenticación. La implementación de v1 será Firebase Auth
/// (email/contraseña); mientras tanto existe un mock en 3_data.
/// La arquitectura queda preparada para añadir login social en v2.
abstract class AuthRepository {
  /// Usuario con sesión activa, o null.
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();
}
