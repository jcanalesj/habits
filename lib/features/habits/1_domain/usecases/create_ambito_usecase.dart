import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/habit_validation.dart';

sealed class CreateAmbitoResult {}

class CreateAmbitoSuccess extends CreateAmbitoResult {
  final Ambito ambito;
  CreateAmbitoSuccess(this.ambito);
}

class CreateAmbitoValidationFailed extends CreateAmbitoResult {
  final Set<AmbitoValidationError> errors;
  CreateAmbitoValidationFailed(this.errors);
}

class CreateAmbitoFailed extends CreateAmbitoResult {
  final HabitsFailure failure;
  CreateAmbitoFailed(this.failure);
}

class CreateAmbitoUsecase {
  final HabitsRepository _repository;

  CreateAmbitoUsecase(this._repository);

  Future<CreateAmbitoResult> execute(AmbitoDraft draft) async {
    final errors = HabitValidation.validateAmbito(
      name: draft.name,
      emoji: draft.emoji,
    );
    if (errors.isNotEmpty) return CreateAmbitoValidationFailed(errors);

    try {
      final ambito = await _repository.createAmbito(
        draft.copyWith(name: draft.name.trim(), emoji: draft.emoji.trim()),
      );
      return CreateAmbitoSuccess(ambito);
    } on HabitsException catch (e) {
      return CreateAmbitoFailed(e.failure);
    } catch (_) {
      return CreateAmbitoFailed(HabitsFailure.unknown);
    }
  }
}
