import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/habit_validation.dart';

sealed class CreateHabitResult {}

class CreateHabitSuccess extends CreateHabitResult {
  CreateHabitSuccess(this.habit);

  final Habit habit;
}

class CreateHabitValidationFailed extends CreateHabitResult {
  CreateHabitValidationFailed(this.errors);

  final Set<HabitValidationError> errors;
}

class CreateHabitFailed extends CreateHabitResult {
  CreateHabitFailed(this.failure);

  final HabitsFailure failure;
}

class CreateHabitUsecase {
  const CreateHabitUsecase(this._repository);

  final HabitsRepository _repository;

  Future<CreateHabitResult> execute(
    HabitDraft draft, {
    required LogicalDate today,
  }) async {
    final errors = HabitValidation.validateHabit(
      name: draft.name,
      emoji: draft.emoji,
      periodicity: draft.periodicity,
      reminderTime: draft.reminderTime,
      reminderMessage: draft.reminderMessage,
    );
    if (draft.trackingType == HabitTrackingType.repetitions &&
        draft.targetCount < 2) {
      errors.add(HabitValidationError.invalidTimesPerPeriod);
    }
    if (errors.isNotEmpty) return CreateHabitValidationFailed(errors);

    try {
      final habit = await _repository.createHabit(
        draft.copyWith(name: draft.name.trim(), emoji: draft.emoji.trim()),
        today: today,
      );
      return CreateHabitSuccess(habit);
    } on HabitsException catch (e) {
      return CreateHabitFailed(e.failure);
    } catch (_) {
      return CreateHabitFailed(HabitsFailure.unknown);
    }
  }
}
