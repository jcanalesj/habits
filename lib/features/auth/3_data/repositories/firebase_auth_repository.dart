import 'package:firebase_auth/firebase_auth.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';
import 'package:habits/features/auth/3_data/mappers/app_user_mapper.dart';
import 'package:habits/features/auth/3_data/mappers/auth_failure_mapper.dart';

/// Implementación de [AuthRepository] sobre Firebase Auth (email/contraseña).
///
/// Usa `userChanges()` como stream de sesión porque, a diferencia de
/// `authStateChanges()`, también emite cuando el usuario se recarga (por
/// ejemplo al confirmar la verificación del email).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<AppUser?> watchUser() => _auth.userChanges().map(appUserFromFirebase);

  @override
  AppUser? get currentUser => appUserFromFirebase(_auth.currentUser);

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return _guard(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    });
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException(AuthFailure.unknown);
      await user.updateDisplayName(displayName);
      // Sin recargar, `currentUser` y el stream de sesión pueden seguir
      // emitiendo el usuario sin nombre, y el perfil se crearía con
      // displayName vacío.
      await user.reload();
      return _requireUser(
        _auth.currentUser ?? user,
      ).copyWith(displayName: displayName);
    });
  }

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  @override
  Future<AppUser> updateDisplayName(String displayName) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthFailure.noSession);
    await user.updateDisplayName(displayName);
    await user.reload();
    return _requireUser(
      _auth.currentUser ?? user,
    ).copyWith(displayName: displayName);
  });

  @override
  Future<void> sendEmailVerification() {
    return _guard(() async {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException(AuthFailure.noSession);
      await user.sendEmailVerification();
    });
  }

  @override
  Future<AppUser?> reloadUser() {
    return _guard(() async {
      final before = _auth.currentUser;
      if (before == null) return null;
      await before.reload();
      final after = _auth.currentUser;
      // El token de ID que viaja a Firestore conserva los claims antiguos
      // (email_verified=false) hasta que caduca: al confirmarse la
      // verificación hay que forzar su refresco o las Security Rules
      // seguirían denegando el acceso a los datos del usuario.
      if (after != null && after.emailVerified && !before.emailVerified) {
        await after.getIdToken(true);
      }
      return appUserFromFirebase(after);
    });
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email));
  }

  AppUser _requireUser(User? user) {
    final appUser = appUserFromFirebase(user);
    if (appUser == null) throw const AuthException(AuthFailure.unknown);
    return appUser;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(authFailureFromCode(e.code), message: e.message);
    }
  }
}
