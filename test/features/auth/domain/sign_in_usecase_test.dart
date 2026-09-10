import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/repositories/mock_auth_repository.dart';

void main() {
  group('SignInUsecase', () {
    late SignInUsecase usecase;

    setUp(() => usecase = SignInUsecase(MockAuthRepository()));

    test('rechaza email inválido y contraseña corta', () async {
      final result = await usecase.execute(email: 'no-es-email', password: '123');

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
    });

    test('recorta espacios del email antes de validar', () async {
      final result = await usecase.execute(
        email: '  alex@example.com  ',
        password: 'secreta1',
      );

      expect(result, isA<SignInSuccess>());
      expect((result as SignInSuccess).user.email, 'alex@example.com');
    });
  });
}
