import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';
import 'package:habits/features/auth/1_domain/services/email_validator.dart';

enum SignInValidationError { invalidEmail, passwordTooShort }

sealed class SignInResult {}

class SignInSuccess extends SignInResult {
  final AppUser user;
  SignInSuccess(this.user);
}

class SignInValidationFailed extends SignInResult {
  final Set<SignInValidationError> errors;
  SignInValidationFailed(this.errors);
}

class SignInFailed extends SignInResult {
  final AuthFailure failure;
  SignInFailed(this.failure);
}

class SignInUsecase {
  final AuthRepository _repository;

  SignInUsecase(this._repository);

  static const _minPasswordLength = 6;

  Future<SignInResult> execute({
    required String email,
    required String password,
  }) async {
    final errors = <SignInValidationError>{
      if (!EmailValidator.isValid(email)) SignInValidationError.invalidEmail,
      if (password.length < _minPasswordLength)
        SignInValidationError.passwordTooShort,
    };
    if (errors.isNotEmpty) return SignInValidationFailed(errors);

    try {
      final user = await _repository.signIn(
        email: email.trim(),
        password: password,
      );
      return SignInSuccess(user);
    } on AuthException catch (e) {
      return SignInFailed(e.failure);
    } catch (_) {
      return SignInFailed(AuthFailure.unknown);
    }
  }
}
