import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/repositories/in_memory_auth_repository.dart';

const user = AppUser(
  id: 'u1',
  email: 'alex@example.com',
  displayName: 'Alex',
  emailVerified: true,
);

void main() {
  late InMemoryAuthRepository repository;

  setUp(() => repository = InMemoryAuthRepository(initialUser: user));

  group('ChangePasswordUsecase', () {
    test('con la contraseña actual correcta la cambia', () async {
      final result = await ChangePasswordUsecase(
        repository,
      ).execute(currentPassword: 'password', newPassword: 'nueva-clave');

      expect(result, isA<AccountActionSuccess>());
      await repository.signOut();
      await repository.signIn(email: user.email, password: 'nueva-clave');
      expect(repository.currentUser?.id, user.id);
    });

    test('con la contraseña actual incorrecta no cambia nada', () async {
      final result = await ChangePasswordUsecase(
        repository,
      ).execute(currentPassword: 'mal', newPassword: 'nueva-clave');

      expect(
        result,
        isA<AccountActionFailed>().having(
          (r) => r.failure,
          'failure',
          AuthFailure.invalidCredentials,
        ),
      );
    });
  });

  group('DeleteAccountUsecase', () {
    test('borra la cuenta y cierra la sesión', () async {
      final result = await DeleteAccountUsecase(
        repository,
      ).execute(password: 'password');

      expect(result, isA<AccountActionSuccess>());
      expect(repository.currentUser, isNull);
      expect(repository.deletedAccounts, [user.email]);
      expect(
        () => repository.signIn(email: user.email, password: 'password'),
        throwsA(isA<AuthException>()),
      );
    });

    test('sin la contraseña correcta no borra nada', () async {
      final result = await DeleteAccountUsecase(
        repository,
      ).execute(password: 'mal');

      expect(result, isA<AccountActionFailed>());
      expect(repository.currentUser, isNotNull);
      expect(repository.deletedAccounts, isEmpty);
    });
  });
}
