import 'dart:async';

import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';

/// Implementación en memoria de [AuthRepository] con el mismo comportamiento
/// observable que Firebase Auth: cuentas por email, alta sin verificar,
/// `reloadUser` para reflejar la verificación, errores como [AuthException].
/// Se usa en tests y en arranques con datos simulados.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({AppUser? initialUser, this.latency = Duration.zero})
    : _current = initialUser {
    if (initialUser != null) {
      _accounts[initialUser.email] = _Account(initialUser, 'password');
    }
  }

  final Duration latency;
  final Map<String, _Account> _accounts = {};
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;
  int _nextId = 1;

  /// Correos a los que se ha "enviado" un enlace de verificación.
  final List<String> verificationEmailsSent = [];

  /// Correos a los que se ha "enviado" un enlace de restablecimiento.
  final List<String> passwordResetEmailsSent = [];

  /// Registra una cuenta ya existente sin iniciar sesión.
  void registerAccount(AppUser user, {String password = 'password'}) {
    _accounts[user.email] = _Account(user, password);
  }

  /// Simula que el usuario ha pulsado el enlace: la verificación solo se
  /// refleja en la sesión tras [reloadUser], igual que en Firebase.
  void markEmailVerified(String email) {
    final account = _accounts[email];
    if (account == null) return;
    _accounts[email] = _Account(
      account.user.copyWith(emailVerified: true),
      account.password,
    );
  }

  /// Fuerza un estado de sesión (útil para tests de presentación).
  void emit(AppUser? user) {
    _current = user;
    _controller.add(user);
  }

  @override
  Stream<AppUser?> watchUser() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await _delay();
    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    emit(account.user);
    return account.user;
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _delay();
    if (_accounts.containsKey(email)) {
      throw const AuthException(AuthFailure.emailAlreadyInUse);
    }
    final user = AppUser(
      id: 'user-${_nextId++}',
      email: email,
      displayName: displayName,
    );
    _accounts[email] = _Account(user, password);
    emit(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _delay();
    emit(null);
  }

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    await _delay();
    final user = _current;
    if (user == null) throw const AuthException(AuthFailure.noSession);
    final updated = user.copyWith(displayName: displayName);
    final account = _accounts[user.email];
    if (account != null) {
      _accounts[user.email] = _Account(updated, account.password);
    }
    emit(updated);
    return updated;
  }

  @override
  Future<void> sendEmailVerification() async {
    await _delay();
    final user = _current;
    if (user == null) throw const AuthException(AuthFailure.noSession);
    verificationEmailsSent.add(user.email);
  }

  @override
  Future<AppUser?> reloadUser() async {
    await _delay();
    final user = _current;
    if (user == null) return null;
    final refreshed = _accounts[user.email]?.user ?? user;
    emit(refreshed);
    return refreshed;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _delay();
    passwordResetEmailsSent.add(email);
  }

  Future<void> _delay() =>
      latency == Duration.zero ? Future.value() : Future.delayed(latency);
}

class _Account {
  const _Account(this.user, this.password);

  final AppUser user;
  final String password;
}
