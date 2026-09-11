import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/3_data/data.dart';

void main() {
  group('SignUpUsecase', () {
    late InMemoryAuthRepository repository;
    late SignUpUsecase usecase;

    setUp(() {
      repository = InMemoryAuthRepository();
      usecase = SignUpUsecase(repository);
    });

    test(
      'devuelve todos los errores de validación de un formulario vacío',
      () async {
        final result = await usecase.execute(
          nickname: '',
          email: '',
          password: '',
          confirmPassword: '',
          acceptedTerms: false,
        );

        expect(result, isA<SignUpValidationFailed>());
        expect((result as SignUpValidationFailed).errors, {
          SignUpValidationError.nicknameRequired,
          SignUpValidationError.invalidEmail,
          SignUpValidationError.passwordTooShort,
          SignUpValidationError.termsNotAccepted,
        });
      },
    );

    test('detecta contraseñas distintas y nickname demasiado largo', () async {
      final result = await usecase.execute(
        nickname: 'a' * 41,
        email: 'alex@example.com',
        password: 'secreta12',
        confirmPassword: 'secreta13',
        acceptedTerms: true,
      );

      expect((result as SignUpValidationFailed).errors, {
        SignUpValidationError.nicknameTooLong,
        SignUpValidationError.passwordsDoNotMatch,
      });
    });

    test(
      'crea la cuenta sin verificar y envía el correo de verificación',
      () async {
        final result = await usecase.execute(
          nickname: '  Alex ',
          email: ' alex@example.com ',
          password: 'secreta12',
          confirmPassword: 'secreta12',
          acceptedTerms: true,
        );

        expect(result, isA<SignUpSuccess>());
        final user = (result as SignUpSuccess).user;
        expect(user.email, 'alex@example.com');
        expect(user.displayName, 'Alex');
        expect(user.emailVerified, isFalse);
        expect(repository.currentUser, user);
        expect(repository.verificationEmailsSent, ['alex@example.com']);
      },
    );

    test('un correo ya registrado falla y NO inicia sesión', () async {
      repository.registerAccount(
        const AppUser(id: 'u1', email: 'alex@example.com'),
        password: 'secreta12',
      );

      // Incluso acertando la contraseña de la cuenta existente, el alta
      // no debe iniciar sesión: registro y login están separados.
      final result = await usecase.execute(
        nickname: 'Alex',
        email: 'alex@example.com',
        password: 'secreta12',
        confirmPassword: 'secreta12',
        acceptedTerms: true,
      );

      expect(result, isA<SignUpFailed>());
      expect((result as SignUpFailed).failure, AuthFailure.emailAlreadyInUse);
      expect(repository.currentUser, isNull);
      expect(repository.verificationEmailsSent, isEmpty);
    });
  });
}
