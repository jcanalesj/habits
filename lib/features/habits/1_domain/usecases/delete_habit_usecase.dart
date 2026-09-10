import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';

sealed class DeleteHabitResult {}

class DeleteHabitSuccess extends DeleteHabitResult {}

class DeleteHabitFailed extends DeleteHabitResult {
  final HabitsFailure failure;
  DeleteHabitFailed(this.failure);
}

/// Soft delete de un hábito: deja de aparecer en las consultas normales y
/// conserva su histórico de registros para estadísticas.
class DeleteHabitUsecase {
  final HabitsRepository _repository;

  DeleteHabitUsecase(this._repository);

  Future<DeleteHabitResult> execute(String habitId) async {
    try {
      await _repository.softDeleteHabit(habitId);
      return DeleteHabitSuccess();
    } on HabitsException catch (e) {
      return DeleteHabitFailed(e.failure);
    } catch (_) {
      return DeleteHabitFailed(HabitsFailure.unknown);
    }
  }
}
