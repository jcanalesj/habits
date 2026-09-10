import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/data.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('FirebaseAuthRepository', () {
    test('sin sesión currentUser es null y watchUser emite null', () async {
      final auth = MockFirebaseAuth();
      final repository = FirebaseAuthRepository(auth: auth);

      expect(repository.currentUser, isNull);
      expect(await repository.watchUser().first, isNull);
    });

    test(
      'signUp crea el usuario sin verificar con el nombre visible',
      () async {
        final auth = MockFirebaseAuth(verifyEmailAutomatically: false);
        final repository = FirebaseAuthRepository(auth: auth);

        final user = await repository.signUp(
          email: 'alex@example.com',
          password: 'secreta12',
          displayName: 'Alex',
        );

        expect(user.email, 'alex@example.com');
        expect(user.displayName, 'Alex');
        expect(user.emailVerified, isFalse);
        expect(repository.currentUser?.id, user.id);
        expect(auth.currentUser?.displayName, 'Alex');
      },
    );

    test('signIn mapea el usuario de Firebase a AppUser', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'uid-1',
          email: 'alex@example.com',
          displayName: 'Alex',
          isEmailVerified: true,
        ),
      );
      final repository = FirebaseAuthRepository(auth: auth);

      final user = await repository.signIn(
        email: 'alex@example.com',
        password: 'secreta12',
      );

      expect(
        user,
        const AppUser(
          id: 'uid-1',
          email: 'alex@example.com',
          displayName: 'Alex',
          emailVerified: true,
        ),
      );
    });

    test('signOut deja la sesión vacía y lo refleja en watchUser', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', email: 'alex@example.com'),
      );
      final repository = FirebaseAuthRepository(auth: auth);
      final emissions = <AppUser?>[];
      final subscription = repository.watchUser().listen(emissions.add);

      await repository.signOut();
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(repository.currentUser, isNull);
      expect(emissions.last, isNull);
    });

    test(
      'sendEmailVerification sin sesión lanza AuthFailure.noSession',
      () async {
        final repository = FirebaseAuthRepository(auth: MockFirebaseAuth());

        await expectLater(
          repository.sendEmailVerification(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.failure,
              'failure',
              AuthFailure.noSession,
            ),
          ),
        );
      },
    );

    test('traduce FirebaseAuthException a AuthException de dominio', () async {
      final auth = MockFirebaseAuth();
      whenCalling(
        Invocation.method(#signInWithEmailAndPassword, null),
      ).on(auth).thenThrow(FirebaseAuthException(code: 'invalid-credential'));
      final repository = FirebaseAuthRepository(auth: auth);

      await expectLater(
        repository.signIn(email: 'alex@example.com', password: 'mal'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.failure,
            'failure',
            AuthFailure.invalidCredentials,
          ),
        ),
      );
    });

    test('reloadUser devuelve el usuario actual', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-1', email: 'alex@example.com'),
      );
      final repository = FirebaseAuthRepository(auth: auth);

      final user = await repository.reloadUser();

      expect(user?.id, 'uid-1');
    });
  });
}
