import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';

sealed class AccountActionResult {
  const AccountActionResult();
}

class AccountActionSuccess extends AccountActionResult {
  const AccountActionSuccess();
}

class AccountActionFailed extends AccountActionResult {
  const AccountActionFailed(this.failure);
  final AuthFailure failure;
}

/// Cambia la contraseña confirmando antes la actual.
class ChangePasswordUsecase {
  const ChangePasswordUsecase(this._repository);

  final AuthRepository _repository;

  Future<AccountActionResult> execute({
    required String currentPassword,
    required String newPassword,
  }) => _run(_repository, () async {
    await _repository.reauthenticate(password: currentPassword);
    await _repository.updatePassword(newPassword: newPassword);
  });
}

/// Borra la cuenta y todos sus datos confirmando antes la contraseña
/// (App Store 5.1.1(v), Google Play y RGPD).
class DeleteAccountUsecase {
  const DeleteAccountUsecase(this._repository);

  final AuthRepository _repository;

  Future<AccountActionResult> execute({required String password}) =>
      _run(_repository, () async {
        await _repository.reauthenticate(password: password);
        await _repository.deleteAccount();
      });
}

Future<AccountActionResult> _run(
  AuthRepository repository,
  Future<void> Function() action,
) async {
  try {
    await action();
    return const AccountActionSuccess();
  } on AuthException catch (e) {
    return AccountActionFailed(e.failure);
  } catch (_) {
    return const AccountActionFailed(AuthFailure.unknown);
  }
}
