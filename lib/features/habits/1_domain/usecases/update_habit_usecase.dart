import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/habit_validation.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';

sealed class UpdateHabitResult {}

class UpdateHabitSuccess extends UpdateHabitResult {
  final Habit habit;
  UpdateHabitSuccess(this.habit);
}

class UpdateHabitValidationFailed extends UpdateHabitResult {
  final Set<HabitValidationError> errors;
  UpdateHabitValidationFailed(this.errors);
}

class UpdateHabitFailed extends UpdateHabitResult {
  final HabitsFailure failure;
  UpdateHabitFailed(this.failure);
}

/// Edita un hábito. Si cambia la periodicidad, el cambio se anota en el
/// historial con el día lógico de hoy (doc funcional §4.3): el historial de
/// registros no se toca y la fase 5 recalculará la racha desde esa fecha.
class UpdateHabitUsecase {
  final HabitsRepository _repository;

  UpdateHabitUsecase(this._repository);

  Future<UpdateHabitResult> execute({
    required Habit original,
    required Habit updated,
    DateTime? today,
  }) async {
    if (original.isDeleted) {
      return UpdateHabitFailed(HabitsFailure.habitDeleted);
    }
    final errors = HabitValidation.validateHabit(
      name: updated.name,
      emoji: updated.emoji,
      restDaysAllowed: updated.restDaysAllowed,
      recoveryTask: updated.recoveryTask,
      recoveryCooldownDays: updated.recoveryCooldownDays,
      reminderTime: updated.reminderTime,
    );
    if (errors.isNotEmpty) return UpdateHabitValidationFailed(errors);

    var toSave = updated.copyWith(
      id: original.id,
      createdAt: original.createdAt,
      deletedAt: original.deletedAt,
      name: updated.name.trim(),
      emoji: updated.emoji.trim(),
      recoveryTask: updated.recoveryTask?.trim(),
      periodicityHistory: original.periodicityHistory,
    );
    if (updated.periodicity != original.periodicity) {
      toSave = toSave.copyWith(
        periodicityHistory: [
          ...original.periodicityHistory,
          PeriodicityChange(
            periodicity: original.periodicity,
            since: today ?? LogicalDay.today(),
          ),
        ],
      );
    }

    try {
      await _repository.updateHabit(toSave);
      return UpdateHabitSuccess(toSave);
    } on HabitsException catch (e) {
      return UpdateHabitFailed(e.failure);
    } catch (_) {
      return UpdateHabitFailed(HabitsFailure.unknown);
    }
  }
}
