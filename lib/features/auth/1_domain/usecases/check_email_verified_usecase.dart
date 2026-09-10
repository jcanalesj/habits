import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/exceptions/auth_exception.dart';
import 'package:habits/features/auth/1_domain/repositories/auth_repository.dart';

sealed class CheckEmailVerifiedResult {}

/// El email consta como verificado; [user] es el estado recargado.
class CheckEmailVerifiedConfirmed extends CheckEmailVerifiedResult {
  final AppUser user;
  CheckEmailVerifiedConfirmed(this.user);
}

/// Sigue sin verificar (el usuario aún no ha abierto el enlace).
class CheckEmailVerifiedPending extends CheckEmailVerifiedResult {}

class CheckEmailVerifiedFailed extends CheckEmailVerifiedResult {
  final AuthFailure failure;
  CheckEmailVerifiedFailed(this.failure);
}

/// Comprobación real contra el proveedor: recarga el usuario y consulta
/// `emailVerified`. El valor en caché no cambia solo al pulsar el enlace.
class CheckEmailVerifiedUsecase {
  final AuthRepository _repository;

  CheckEmailVerifiedUsecase(this._repository);

  Future<CheckEmailVerifiedResult> execute() async {
    try {
      final user = await _repository.reloadUser();
      if (user == null) return CheckEmailVerifiedFailed(AuthFailure.noSession);
      return user.emailVerified
          ? CheckEmailVerifiedConfirmed(user)
          : CheckEmailVerifiedPending();
    } on AuthException catch (e) {
      return CheckEmailVerifiedFailed(e.failure);
    } catch (_) {
      return CheckEmailVerifiedFailed(AuthFailure.unknown);
    }
  }
}
