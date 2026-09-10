import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/data.dart';

void main() {
  group('SignInUsecase', () {
    late InMemoryAuthRepository repository;
    late SignInUsecase usecase;

    setUp(() {
      repository = InMemoryAuthRepository()
        ..registerAccount(
          const AppUser(
            id: 'u1',
            email: 'alex@example.com',
            displayName: 'Alex',
            emailVerified: true,
          ),
          password: 'secreta1',
        );
      usecase = SignInUsecase(repository);
    });

    test('rechaza email inválido y contraseña corta', () async {
      final result = await usecase.execute(
        email: 'no-es-email',
        password: '123',
      );

      expect(result, isA<SignInValidationFailed>());
      final errors = (result as SignInValidationFailed).errors;
      expect(errors, contains(SignInValidationError.invalidEmail));
      expect(errors, contains(SignInValidationError.passwordTooShort));
    });

    test('acepta credenciales válidas y devuelve el usuario', () async {
      final result = await usecase.execute(
        email: 'alex@example.com',
        password: 'secreta1',
      );

      expect(result, isA<SignInSuccess>());
      expect((result as SignInSuccess).user.email, 'alex@example.com');
      expect(repository.currentUser?.id, 'u1');
    });

    test('recorta espacios del email antes de validar', () async {
      final result = await usecase.execute(
        email: '  alex@example.com  ',
        password: 'secreta1',
      );

      expect(result, isA<SignInSuccess>());
    });

    test('traduce el fallo del proveedor a AuthFailure', () async {
      final result = await usecase.execute(
        email: 'alex@example.com',
        password: 'incorrecta',
      );

      expect(result, isA<SignInFailed>());
      expect((result as SignInFailed).failure, AuthFailure.invalidCredentials);
      expect(repository.currentUser, isNull);
    });
  });
}
