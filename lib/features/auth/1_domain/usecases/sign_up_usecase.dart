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

/// Cuenta creada; queda con sesión iniciada y sin verificar.
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
///
/// Registro y login están separados: si el correo ya está registrado, este
/// usecase NO intenta iniciar sesión. Devuelve
/// [AuthFailure.emailAlreadyInUse] y es la UI quien ofrece ir al login o a
/// recuperar la contraseña.
class SignUpUsecase {
  final AuthRepository _repository;

  /// Con la verificación desactivada no se envía ningún correo al alta.
  final bool sendVerificationEmail;

  SignUpUsecase(this._repository, {this.sendVerificationEmail = true});

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
      if (!sendVerificationEmail) return SignUpSuccess(user);
      try {
        await _repository.sendEmailVerification();
      } on AuthException {
        // El envío puede fallar (p. ej. límite de correos): la cuenta ya
        // existe y el usuario puede reenviarlo desde la verificación.
      }
      return SignUpSuccess(user);
    } on AuthException catch (e) {
      return SignUpFailed(e.failure);
    } catch (_) {
      return SignUpFailed(AuthFailure.unknown);
    }
  }
}
