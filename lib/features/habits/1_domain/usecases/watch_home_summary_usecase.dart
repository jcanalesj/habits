import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';
import 'package:habits/features/habits/1_domain/services/stream_combiner.dart';

/// Stream con todo lo que muestra la Home. Combina rachas (caché, puede
/// estar vacía), ámbitos, hábitos activos y registros de la semana en curso.
class WatchHomeSummaryUsecase {
  final HabitsRepository _repository;

  WatchHomeSummaryUsecase(this._repository);

  Stream<HomeSummary> execute({DateTime? today}) {
    final day = today ?? LogicalDay.today();
    final monday = LogicalDay.mondayOfWeek(day);
    final sunday = LogicalDay.sundayOfWeek(day);

    return combineLatest4(
      _repository.watchStreaks(),
      _repository.watchAmbitos(),
      _repository.watchActiveHabits(),
      _repository.watchLogsBetween(monday, sunday),
      (streaks, ambitos, habits, weekLogs) => HomeSummary(
        streaks: streaks,
        ambitos: ambitos,
        habits: habits,
        weekLogs: weekLogs,
      ),
    );
  }
}
