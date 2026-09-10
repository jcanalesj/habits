import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/data.dart';

void main() {
  group('CheckEmailVerifiedUsecase', () {
    const user = AppUser(id: 'u1', email: 'alex@example.com');

    test('sin sesión devuelve fallo noSession', () async {
      final usecase = CheckEmailVerifiedUsecase(InMemoryAuthRepository());

      final result = await usecase.execute();

      expect(result, isA<CheckEmailVerifiedFailed>());
      expect(
        (result as CheckEmailVerifiedFailed).failure,
        AuthFailure.noSession,
      );
    });

    test(
      'pendiente mientras el proveedor no refleje la verificación',
      () async {
        final repository = InMemoryAuthRepository(initialUser: user);
        final usecase = CheckEmailVerifiedUsecase(repository);

        expect(await usecase.execute(), isA<CheckEmailVerifiedPending>());
      },
    );

    test('confirma tras recargar cuando el enlace se ha usado', () async {
      final repository = InMemoryAuthRepository(initialUser: user);
      final usecase = CheckEmailVerifiedUsecase(repository);

      repository.markEmailVerified(user.email);
      final result = await usecase.execute();

      expect(result, isA<CheckEmailVerifiedConfirmed>());
      expect((result as CheckEmailVerifiedConfirmed).user.emailVerified, true);
      expect(repository.currentUser?.emailVerified, isTrue);
    });
  });
}
