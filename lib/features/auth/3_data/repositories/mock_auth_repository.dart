import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';

/// Implementación mock para desarrollo de UI: acepta cualquier credencial
/// tras una pequeña latencia. Se sustituirá por FirebaseAuthRepository
/// (ver documentation/FIREBASE_SETUP.md, fase 4).
class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _currentUser = AppUser(
      id: 'mock-user',
      email: email,
      displayName: email.split('@').first,
      emailVerified: true,
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}
