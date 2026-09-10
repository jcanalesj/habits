import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';

sealed class ToggleHabitCompletionResult {}

class ToggleHabitCompletionSuccess extends ToggleHabitCompletionResult {}

/// No se puede registrar en un día futuro.
class ToggleHabitCompletionFutureDate extends ToggleHabitCompletionResult {}

class ToggleHabitCompletionFailed extends ToggleHabitCompletionResult {
  final HabitsFailure failure;
  ToggleHabitCompletionFailed(this.failure);
}

/// Marca o desmarca el cumplimiento de un hábito activo en un día lógico.
class ToggleHabitCompletionUsecase {
  final HabitsRepository _repository;

  ToggleHabitCompletionUsecase(this._repository);

  Future<ToggleHabitCompletionResult> execute({
    required String habitId,
    required DateTime date,
    required bool completed,
    HabitLogType type = HabitLogType.completed,
    DateTime? today,
  }) async {
    final day = LogicalDay.of(date);
    if (day.isAfter(today ?? LogicalDay.today())) {
      return ToggleHabitCompletionFutureDate();
    }

    try {
      final habit = await _repository.getHabit(habitId);
      if (habit == null) {
        return ToggleHabitCompletionFailed(HabitsFailure.habitNotFound);
      }
      if (habit.isDeleted) {
        return ToggleHabitCompletionFailed(HabitsFailure.habitDeleted);
      }
      await _repository.setHabitCompletion(
        habitId: habitId,
        date: day,
        completed: completed,
        type: type,
      );
      return ToggleHabitCompletionSuccess();
    } on HabitsException catch (e) {
      return ToggleHabitCompletionFailed(e.failure);
    } catch (_) {
      return ToggleHabitCompletionFailed(HabitsFailure.unknown);
    }
  }
}
