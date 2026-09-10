import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';

sealed class GetHomeSummaryResult {}

class GetHomeSummarySuccess extends GetHomeSummaryResult {
  final HomeSummary summary;
  GetHomeSummarySuccess(this.summary);
}

class GetHomeSummaryFailed extends GetHomeSummaryResult {
  final String message;
  GetHomeSummaryFailed(this.message);
}

class GetHomeSummaryUsecase {
  final HabitsRepository _repository;

  GetHomeSummaryUsecase(this._repository);

  Future<GetHomeSummaryResult> execute() async {
    try {
      final monday = LogicalDay.mondayOfWeek(LogicalDay.today());
      final sunday = monday.add(const Duration(days: 6));

      final generalStreak = await _repository.fetchGeneralStreak();
      final ambitos = await _repository.fetchAmbitos();
      final habits = await _repository.fetchHabits();
      final weekLogs = await _repository.fetchLogsBetween(monday, sunday);

      return GetHomeSummarySuccess(
        HomeSummary(
          generalStreak: generalStreak,
          ambitos: ambitos,
          habits: habits,
          weekLogs: weekLogs,
        ),
      );
    } catch (e) {
      return GetHomeSummaryFailed(e.toString());
    }
  }
}
