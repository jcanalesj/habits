import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/habit_validation.dart';

sealed class UpdateHabitResult {}

class UpdateHabitSuccess extends UpdateHabitResult {
  UpdateHabitSuccess(this.habit);

  final Habit habit;
}

class UpdateHabitValidationFailed extends UpdateHabitResult {
  UpdateHabitValidationFailed(this.errors);

  final Set<HabitValidationError> errors;
}

class UpdateHabitFailed extends UpdateHabitResult {
  UpdateHabitFailed(this.failure);

  final HabitsFailure failure;
}

/// Edita los campos simples de un hábito (nombre, emoji, color, ámbito,
/// recordatorio, orden).
///
/// La periodicidad NO se cambia aquí: tiene su propio usecase
/// ([ChangeHabitPeriodicityUsecase]) porque implica calcular una fecha
/// efectiva y respetar el periodo en curso. Aquí la línea temporal se
/// preserva tal cual.
class UpdateHabitUsecase {
  const UpdateHabitUsecase(this._repository);

  final HabitsRepository _repository;

  Future<UpdateHabitResult> execute({
    required Habit original,
    required Habit updated,
  }) async {
    if (original.isDeleted) {
      return UpdateHabitFailed(HabitsFailure.habitDeleted);
    }
    final errors = HabitValidation.validateHabit(
      name: updated.name,
      emoji: updated.emoji,
      periodicity: original.periodicityTimeline.isEmpty
          ? Periodicity.daily
          : original.periodicityTimeline.last.periodicity,
      reminderTime: updated.reminderTime,
      reminderMessage: updated.reminderMessage,
    );
    if (updated.trackingType == HabitTrackingType.repetitions &&
        updated.targetCount < 2) {
      errors.add(HabitValidationError.invalidTimesPerPeriod);
    }
    if (errors.isNotEmpty) return UpdateHabitValidationFailed(errors);

    final toSave = updated.copyWith(
      id: original.id,
      createdAt: original.createdAt,
      deletedAt: original.deletedAt,
      name: updated.name.trim(),
      emoji: updated.emoji.trim(),
      periodicityTimeline: original.periodicityTimeline,
      reminderMessage: updated.reminderMessage?.trim().isEmpty ?? true
          ? null
          : updated.reminderMessage!.trim(),
    );

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
