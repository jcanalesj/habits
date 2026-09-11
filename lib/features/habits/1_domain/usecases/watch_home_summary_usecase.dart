import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/repositories/wildcards_repository.dart';
import 'package:habits/features/habits/1_domain/services/goal_progress_calculator.dart';
import 'package:habits/features/habits/1_domain/services/logical_calendar.dart';
import 'package:habits/features/habits/1_domain/services/stream_combiner.dart';
import 'package:habits/features/habits/1_domain/services/streak_calculator.dart';
import 'package:habits/features/habits/1_domain/services/clock.dart';

/// Stream con todo lo que muestra la Home.
///
/// La racha se calcula EN VIVO desde los días de actividad y los días
/// protegidos, no se lee de la caché: los registros son la fuente de verdad
/// y la caché es solo una proyección (§2). Así cualquier escritura (local o
/// de otro dispositivo) se refleja sola y no hay forma de que un valor
/// almacenado y la realidad se separen.
class WatchHomeSummaryUsecase {
  const WatchHomeSummaryUsecase({
    required HabitsRepository habits,
    required WildcardsRepository wildcards,
    required LogicalCalendar calendar,
    required GoalProgressCalculator goalProgress,
    required Clock clock,
  }) : _habits = habits,
       _wildcards = wildcards,
       _calendar = calendar,
       _goalProgress = goalProgress,
       _clock = clock;

  final HabitsRepository _habits;
  final WildcardsRepository _wildcards;
  final LogicalCalendar _calendar;
  final GoalProgressCalculator _goalProgress;
  final Clock _clock;

  /// [today] permite fijar el día en los tests; en producción se resuelve
  /// con el reloj y la zona horaria del perfil.
  Stream<HomeSummary> execute({LogicalDate? today}) {
    final day = today ?? _calendar.dateOf(_clock.nowUtc());
    final monday = _calendar.startOfWeek(day);
    final sunday = _calendar.endOfWeek(day);
    // Los objetivos mensuales y anuales necesitan los registros de todo su
    // periodo, no solo los de la semana.
    final periodStart = _calendar.startOfYear(day);
    final periodEnd = _calendar.endOfYear(day);

    return combineLatestN([
      _habits.watchAmbitos(),
      _habits.watchActiveHabits(),
      _habits.watchLogsBetween(periodStart, periodEnd),
      _habits.watchActivityDays(),
      _wildcards.watchProtectedDays(),
      _wildcards.watchBalance(),
    ], (values) {
      final ambitos = values[0] as List<Ambito>;
      final habits = values[1] as List<Habit>;
      final yearLogs = values[2] as List<HabitLog>;
      final activityDays = values[3] as Set<LogicalDate>;
      final protectedDays = values[4] as Set<LogicalDate>;
      final balance = values[5] as WildcardBalance?;

      return HomeSummary(
        today: day,
        streak: StreakCalculator.calculate(
          activityDays: activityDays,
          protectedDays: protectedDays,
          today: day,
        ),
        wildcards: balance ?? WildcardBalance.empty,
        ambitos: ambitos,
        habits: habits,
        progress: _goalProgress.forHabits(
          habits: habits,
          logs: yearLogs,
          today: day,
        ),
        weekLogs: [
          for (final log in yearLogs)
            if (log.date.isAtOrAfter(monday) && log.date.isAtOrBefore(sunday))
              log,
        ],
      );
    });
  }
}
