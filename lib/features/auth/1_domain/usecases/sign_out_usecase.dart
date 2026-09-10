import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';

sealed class SignOutResult {}

class SignOutSuccess extends SignOutResult {}

class SignOutFailed extends SignOutResult {
  final AuthFailure failure;
  SignOutFailed(this.failure);
}

class SignOutUsecase {
  final AuthRepository _repository;

  SignOutUsecase(this._repository);

  Future<SignOutResult> execute() async {
    try {
      await _repository.signOut();
      return SignOutSuccess();
    } on AuthException catch (e) {
      return SignOutFailed(e.failure);
    } catch (_) {
      return SignOutFailed(AuthFailure.unknown);
    }
  }
}
