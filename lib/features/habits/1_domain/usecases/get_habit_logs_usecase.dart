import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';

sealed class GetHabitLogsResult {}

class GetHabitLogsSuccess extends GetHabitLogsResult {
  final List<HabitLog> logs;
  GetHabitLogsSuccess(this.logs);
}

class GetHabitLogsFailed extends GetHabitLogsResult {
  final HabitsFailure failure;
  GetHabitLogsFailed(this.failure);
}

/// Registros de un hábito (también si está eliminado), para estadísticas.
class GetHabitLogsUsecase {
  final HabitsRepository _repository;

  GetHabitLogsUsecase(this._repository);

  Future<GetHabitLogsResult> execute(
    String habitId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final logs = await _repository.fetchHabitLogs(
        habitId,
        from: from == null ? null : LogicalDay.of(from),
        to: to == null ? null : LogicalDay.of(to),
      );
      return GetHabitLogsSuccess(logs);
    } on HabitsException catch (e) {
      return GetHabitLogsFailed(e.failure);
    } catch (_) {
      return GetHabitLogsFailed(HabitsFailure.unknown);
    }
  }
}
