import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';

sealed class GetHabitLogsResult {}

class GetHabitLogsSuccess extends GetHabitLogsResult {
  final List<HabitLog> logs;
  GetHabitLogsSuccess(this.logs);
}

class GetHabitLogsFailed extends GetHabitLogsResult {
  final HabitsFailure failure;
  GetHabitLogsFailed(this.failure);
}

/// Registros de un hábito (también si está eliminado), para estadísticas y
/// para la futura vista calendario del hábito (§6): los días cumplidos se
/// muestran marcados y los no cumplidos permanecen vacíos.
class GetHabitLogsUsecase {
  final HabitsRepository _repository;

  GetHabitLogsUsecase(this._repository);

  Future<GetHabitLogsResult> execute(
    String habitId, {
    LogicalDate? from,
    LogicalDate? to,
  }) async {
    try {
      final logs = await _repository.fetchHabitLogs(
        habitId,
        from: from,
        to: to,
      );
      return GetHabitLogsSuccess(logs);
    } on HabitsException catch (e) {
      return GetHabitLogsFailed(e.failure);
    } catch (_) {
      return GetHabitLogsFailed(HabitsFailure.unknown);
    }
  }
}
