import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';
import 'package:habits/features/auth/1_domain/services/email_validator.dart';

sealed class SendPasswordResetResult {}

class SendPasswordResetSuccess extends SendPasswordResetResult {}

class SendPasswordResetValidationFailed extends SendPasswordResetResult {}

class SendPasswordResetFailed extends SendPasswordResetResult {
  final AuthFailure failure;
  SendPasswordResetFailed(this.failure);
}

/// Envía el enlace de restablecimiento. Con la protección contra
/// enumeración de emails de Firebase, un correo desconocido también
/// devuelve éxito: la UI debe mostrar un mensaje neutro.
class SendPasswordResetUsecase {
  final AuthRepository _repository;

  SendPasswordResetUsecase(this._repository);

  Future<SendPasswordResetResult> execute({required String email}) async {
    if (!EmailValidator.isValid(email)) {
      return SendPasswordResetValidationFailed();
    }
    try {
      await _repository.sendPasswordResetEmail(email: email.trim());
      return SendPasswordResetSuccess();
    } on AuthException catch (e) {
      return SendPasswordResetFailed(e.failure);
    } catch (_) {
      return SendPasswordResetFailed(AuthFailure.unknown);
    }
  }
}
