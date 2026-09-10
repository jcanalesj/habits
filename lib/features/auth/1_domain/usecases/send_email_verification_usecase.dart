import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';

sealed class SendEmailVerificationResult {}

class SendEmailVerificationSuccess extends SendEmailVerificationResult {}

class SendEmailVerificationFailed extends SendEmailVerificationResult {
  final AuthFailure failure;
  SendEmailVerificationFailed(this.failure);
}

class SendEmailVerificationUsecase {
  final AuthRepository _repository;

  SendEmailVerificationUsecase(this._repository);

  Future<SendEmailVerificationResult> execute() async {
    try {
      await _repository.sendEmailVerification();
      return SendEmailVerificationSuccess();
    } on AuthException catch (e) {
      return SendEmailVerificationFailed(e.failure);
    } catch (_) {
      return SendEmailVerificationFailed(AuthFailure.unknown);
    }
  }
}
