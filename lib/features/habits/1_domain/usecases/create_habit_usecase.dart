import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/habit_validation.dart';

sealed class CreateHabitResult {}

class CreateHabitSuccess extends CreateHabitResult {
  final Habit habit;
  CreateHabitSuccess(this.habit);
}

class CreateHabitValidationFailed extends CreateHabitResult {
  final Set<HabitValidationError> errors;
  CreateHabitValidationFailed(this.errors);
}

class CreateHabitFailed extends CreateHabitResult {
  final HabitsFailure failure;
  CreateHabitFailed(this.failure);
}

class CreateHabitUsecase {
  final HabitsRepository _repository;

  CreateHabitUsecase(this._repository);

  Future<CreateHabitResult> execute(HabitDraft draft) async {
    final errors = HabitValidation.validateHabit(
      name: draft.name,
      emoji: draft.emoji,
      restDaysAllowed: draft.restDaysAllowed,
      recoveryTask: draft.recoveryTask,
      recoveryCooldownDays: draft.recoveryCooldownDays,
      reminderTime: draft.reminderTime,
    );
    if (errors.isNotEmpty) return CreateHabitValidationFailed(errors);

    try {
      final habit = await _repository.createHabit(
        draft.copyWith(
          name: draft.name.trim(),
          emoji: draft.emoji.trim(),
          recoveryTask: draft.recoveryTask?.trim(),
        ),
      );
      return CreateHabitSuccess(habit);
    } on HabitsException catch (e) {
      return CreateHabitFailed(e.failure);
    } catch (_) {
      return CreateHabitFailed(HabitsFailure.unknown);
    }
  }
}
