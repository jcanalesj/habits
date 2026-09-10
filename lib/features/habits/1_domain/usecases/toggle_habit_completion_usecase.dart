import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';

sealed class ToggleHabitCompletionResult {}

class ToggleHabitCompletionSuccess extends ToggleHabitCompletionResult {}

class ToggleHabitCompletionFailed extends ToggleHabitCompletionResult {
  final String message;
  ToggleHabitCompletionFailed(this.message);
}

class ToggleHabitCompletionUsecase {
  final HabitsRepository _repository;

  ToggleHabitCompletionUsecase(this._repository);

  Future<ToggleHabitCompletionResult> execute({
    required String habitId,
    required DateTime date,
    required bool completed,
  }) async {
    try {
      await _repository.setHabitCompletion(
        habitId: habitId,
        date: LogicalDay.of(date),
        completed: completed,
      );
      return ToggleHabitCompletionSuccess();
    } catch (e) {
      return ToggleHabitCompletionFailed(e.toString());
    }
  }
}
