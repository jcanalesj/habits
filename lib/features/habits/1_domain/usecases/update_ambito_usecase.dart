import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/habit_validation.dart';

sealed class UpdateAmbitoResult {}

class UpdateAmbitoSuccess extends UpdateAmbitoResult {
  final Ambito ambito;
  UpdateAmbitoSuccess(this.ambito);
}

class UpdateAmbitoValidationFailed extends UpdateAmbitoResult {
  final Set<AmbitoValidationError> errors;
  UpdateAmbitoValidationFailed(this.errors);
}

class UpdateAmbitoFailed extends UpdateAmbitoResult {
  final HabitsFailure failure;
  UpdateAmbitoFailed(this.failure);
}

/// Edita nombre, emoji, color u orden de un ámbito (predefinido o
/// personalizado). `isPredefined` no es editable.
class UpdateAmbitoUsecase {
  final HabitsRepository _repository;

  UpdateAmbitoUsecase(this._repository);

  Future<UpdateAmbitoResult> execute(Ambito ambito) async {
    final errors = HabitValidation.validateAmbito(
      name: ambito.name,
      emoji: ambito.emoji,
    );
    if (errors.isNotEmpty) return UpdateAmbitoValidationFailed(errors);

    final toSave = ambito.copyWith(
      name: ambito.name.trim(),
      emoji: ambito.emoji.trim(),
    );
    try {
      await _repository.updateAmbito(toSave);
      return UpdateAmbitoSuccess(toSave);
    } on HabitsException catch (e) {
      return UpdateAmbitoFailed(e.failure);
    } catch (_) {
      return UpdateAmbitoFailed(HabitsFailure.unknown);
    }
  }
}
