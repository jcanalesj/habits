import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/navigation.dart';

void main() {
  group('resolveAuthRedirect', () {
    const loading = AsyncValue<AppUser?>.loading();
    const anonymous = AsyncValue<AppUser?>.data(null);
    const unverified = AsyncValue<AppUser?>.data(
      AppUser(id: 'u', email: 'a@b.com'),
    );
    const verified = AsyncValue<AppUser?>.data(
      AppUser(id: 'u', email: 'a@b.com', emailVerified: true),
    );

    test('el splash siempre es accesible', () {
      for (final auth in [loading, anonymous, unverified, verified]) {
        expect(resolveAuthRedirect(auth, '/'), isNull);
      }
    });

    test('con la sesión sin restaurar todo vuelve al splash', () {
      expect(resolveAuthRedirect(loading, '/home'), '/');
      expect(resolveAuthRedirect(loading, '/login'), '/');
    });

    test('sin usuario solo se permiten las rutas públicas', () {
      expect(resolveAuthRedirect(anonymous, '/login'), isNull);
      expect(resolveAuthRedirect(anonymous, '/register'), isNull);
      expect(resolveAuthRedirect(anonymous, '/forgot-password'), isNull);
      expect(resolveAuthRedirect(anonymous, '/verify-email'), '/login');
      expect(resolveAuthRedirect(anonymous, '/home'), '/login');
      expect(resolveAuthRedirect(anonymous, '/profile'), '/login');
    });

    test('usuario sin verificar queda en la verificación', () {
      expect(resolveAuthRedirect(unverified, '/verify-email'), isNull);
      expect(resolveAuthRedirect(unverified, '/home'), '/verify-email');
      expect(resolveAuthRedirect(unverified, '/login'), '/verify-email');
      expect(resolveAuthRedirect(unverified, '/register'), '/verify-email');
    });

    test('usuario verificado no vuelve a las pantallas de auth', () {
      expect(resolveAuthRedirect(verified, '/home'), isNull);
      expect(resolveAuthRedirect(verified, '/profile'), isNull);
      expect(resolveAuthRedirect(verified, '/login'), '/home');
      expect(resolveAuthRedirect(verified, '/register'), '/home');
      expect(resolveAuthRedirect(verified, '/forgot-password'), '/home');
      expect(resolveAuthRedirect(verified, '/verify-email'), '/home');
    });

    test('un error en el stream de sesión se trata como sin usuario', () {
      final failed = AsyncValue<AppUser?>.error('boom', StackTrace.empty);
      expect(resolveAuthRedirect(failed, '/home'), '/login');
      expect(resolveAuthRedirect(failed, '/login'), isNull);
    });
  });
}
