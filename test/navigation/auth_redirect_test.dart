import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/navigation.dart';

void main() {
  const loading = AsyncValue<AppUser?>.loading();
  const anonymous = AsyncValue<AppUser?>.data(null);
  const unverified = AsyncValue<AppUser?>.data(
    AppUser(id: 'u', email: 'a@b.com'),
  );
  const verified = AsyncValue<AppUser?>.data(
    AppUser(id: 'u', email: 'a@b.com', emailVerified: true),
  );

  // Atajos para no repetir el parámetro en cada aserción.
  String? go(AsyncValue<AppUser?> auth, String path) =>
      resolveAuthRedirect(auth, path, requireEmailVerification: false);
  String? goStrict(AsyncValue<AppUser?> auth, String path) =>
      resolveAuthRedirect(auth, path, requireEmailVerification: true);

  group('resolveAuthRedirect', () {
    test('el splash siempre es accesible', () {
      for (final auth in [loading, anonymous, unverified, verified]) {
        expect(go(auth, '/'), isNull);
        expect(goStrict(auth, '/'), isNull);
      }
    });

    test('con la sesión sin restaurar todo vuelve al splash', () {
      expect(go(loading, '/home'), '/');
      expect(go(loading, '/login'), '/');
    });

    test('sin usuario solo se permiten las rutas públicas', () {
      expect(go(anonymous, '/login'), isNull);
      expect(go(anonymous, '/register'), isNull);
      expect(go(anonymous, '/forgot-password'), isNull);
      expect(go(anonymous, '/welcome'), '/login');
      expect(go(anonymous, '/verify-email'), '/login');
      expect(go(anonymous, '/home'), '/login');
      expect(go(anonymous, '/profile'), '/login');
    });

    test('un error en el stream de sesión se trata como sin usuario', () {
      final failed = AsyncValue<AppUser?>.error('boom', StackTrace.empty);
      expect(go(failed, '/home'), '/login');
      expect(go(failed, '/login'), isNull);
    });

    group('con la verificación desactivada (configuración actual)', () {
      test('un usuario sin verificar entra igual que uno verificado', () {
        expect(go(unverified, '/home'), isNull);
        expect(go(unverified, '/profile'), isNull);
        expect(go(verified, '/home'), isNull);
      });

      test('las pantallas de auth y la de verificación llevan a la home', () {
        for (final path in [
          '/login',
          '/register',
          '/forgot-password',
          '/verify-email',
        ]) {
          expect(go(unverified, path), '/home', reason: path);
        }
      });
    });

    group('con la verificación activada', () {
      test('un usuario sin verificar queda anclado en la verificación', () {
        expect(goStrict(unverified, '/verify-email'), isNull);
        expect(goStrict(unverified, '/home'), '/verify-email');
        expect(goStrict(unverified, '/login'), '/verify-email');
        expect(goStrict(unverified, '/welcome'), '/verify-email');
      });

      test('un usuario verificado no vuelve a las pantallas de auth', () {
        expect(goStrict(verified, '/home'), isNull);
        expect(goStrict(verified, '/login'), '/home');
        expect(goStrict(verified, '/verify-email'), '/home');
      });
    });

    group('recién registrado', () {
      String? afterSignUp(String path) => resolveAuthRedirect(
        unverified,
        path,
        requireEmailVerification: false,
        justRegistered: true,
      );

      test('queda anclado en la bienvenida', () {
        expect(afterSignUp('/welcome'), isNull);
        expect(afterSignUp('/home'), '/welcome');
        expect(afterSignUp('/register'), '/welcome');
        expect(afterSignUp('/profile'), '/welcome');
      });

      test('el splash sigue siendo accesible', () {
        expect(afterSignUp('/'), isNull);
      });

      test('al limpiar la marca, la bienvenida lleva a la home', () {
        expect(go(unverified, '/welcome'), '/home');
      });

      test('la verificación pendiente tiene prioridad sobre la bienvenida', () {
        expect(
          resolveAuthRedirect(
            unverified,
            '/welcome',
            requireEmailVerification: true,
            justRegistered: true,
          ),
          '/verify-email',
        );
      });
    });
  });
}
