import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';

sealed class DeleteAmbitoResult {}

class DeleteAmbitoSuccess extends DeleteAmbitoResult {}

/// General es el destino de reasignación y no puede eliminarse.
class DeleteAmbitoProtected extends DeleteAmbitoResult {}

class DeleteAmbitoFailed extends DeleteAmbitoResult {
  final HabitsFailure failure;
  DeleteAmbitoFailed(this.failure);
}

/// Elimina un ámbito personalizado; sus hábitos pasan a General en la misma
/// operación y los históricos se conservan.
class DeleteAmbitoUsecase {
  final HabitsRepository _repository;

  DeleteAmbitoUsecase(this._repository);

  Future<DeleteAmbitoResult> execute(String ambitoId) async {
    if (ambitoId == Ambito.generalId) return DeleteAmbitoProtected();
    try {
      await _repository.deleteAmbito(ambitoId);
      return DeleteAmbitoSuccess();
    } on HabitsException catch (e) {
      return e.failure == HabitsFailure.generalAmbitoProtected
          ? DeleteAmbitoProtected()
          : DeleteAmbitoFailed(e.failure);
    } catch (_) {
      return DeleteAmbitoFailed(HabitsFailure.unknown);
    }
  }
}
