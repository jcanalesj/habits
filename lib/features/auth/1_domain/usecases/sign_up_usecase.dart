import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';
import 'package:habits/features/auth/1_domain/services/email_validator.dart';

enum SignUpValidationError {
  nicknameRequired,
  nicknameTooLong,
  invalidEmail,
  passwordTooShort,
  passwordsDoNotMatch,
  termsNotAccepted,
}

sealed class SignUpResult {}

class SignUpSuccess extends SignUpResult {
  final AppUser user;
  SignUpSuccess(this.user);
}

class SignUpValidationFailed extends SignUpResult {
  final Set<SignUpValidationError> errors;
  SignUpValidationFailed(this.errors);
}

class SignUpFailed extends SignUpResult {
  final AuthFailure failure;
  SignUpFailed(this.failure);
}

/// Alta con email/contraseña. Tras crear la cuenta envía el enlace de
/// verificación; el perfil en Firestore NO se crea aquí sino después de
/// verificar el email (ver EnsureUserProfileUsecase y Security Rules).
class SignUpUsecase {
  final AuthRepository _repository;

  SignUpUsecase(this._repository);

  static const minPasswordLength = 8;

  /// Límite que imponen las Security Rules al `displayName` del perfil.
  static const maxNicknameLength = 40;

  Future<SignUpResult> execute({
    required String nickname,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    final trimmedNickname = nickname.trim();
    final errors = <SignUpValidationError>{
      if (trimmedNickname.isEmpty) SignUpValidationError.nicknameRequired,
      if (trimmedNickname.length > maxNicknameLength)
        SignUpValidationError.nicknameTooLong,
      if (!EmailValidator.isValid(email)) SignUpValidationError.invalidEmail,
      if (password.length < minPasswordLength)
        SignUpValidationError.passwordTooShort,
      if (password != confirmPassword)
        SignUpValidationError.passwordsDoNotMatch,
      if (!acceptedTerms) SignUpValidationError.termsNotAccepted,
    };
    if (errors.isNotEmpty) return SignUpValidationFailed(errors);

    try {
      final user = await _repository.signUp(
        email: email.trim(),
        password: password,
        displayName: trimmedNickname,
      );
      try {
        await _repository.sendEmailVerification();
      } on AuthException {
        // La cuenta ya existe: el usuario puede reenviar el correo desde la
        // pantalla de verificación, así que no convertimos esto en fallo.
      }
      return SignUpSuccess(user);
    } on AuthException catch (e) {
      return SignUpFailed(e.failure);
    } catch (_) {
      return SignUpFailed(AuthFailure.unknown);
    }
  }
}
