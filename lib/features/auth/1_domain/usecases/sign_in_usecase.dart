import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';

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
  final String message;
  SignInFailed(this.message);
}

class SignInUsecase {
  final AuthRepository _repository;

  SignInUsecase(this._repository);

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _minPasswordLength = 6;

  Future<SignInResult> execute({
    required String email,
    required String password,
  }) async {
    final errors = <SignInValidationError>{
      if (!_emailRegex.hasMatch(email.trim()))
        SignInValidationError.invalidEmail,
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
    } catch (e) {
      return SignInFailed(e.toString());
    }
  }
}
