import 'package:habits/features/habits/0_entity/goal_progress.dart';
import 'package:habits/features/habits/0_entity/habit.dart';
import 'package:habits/features/habits/0_entity/habit_log.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/1_domain/services/periodicity_resolver.dart';

/// Calcula el progreso de los objetivos. Dart puro y separado por completo
/// del motor de rachas: son dos conceptos distintos y no deben mezclarse
/// (§37).
class GoalProgressCalculator {
  const GoalProgressCalculator(this._resolver);

  final PeriodicityResolver _resolver;

  /// Progreso de [habit] en el periodo que contiene a [today].
  ///
  /// [logs] puede traer registros de más días y de otros hábitos: se filtra
  /// aquí. Solo cuenta la actividad real ([HabitLog.isActivity]), nunca los
  /// tipos legacy del modelo antiguo.
  GoalProgress forHabit({
    required Habit habit,
    required List<HabitLog> logs,
    required LogicalDate today,
  }) {
    final period = _resolver.currentPeriod(habit.periodicityTimeline, today);
    // El objetivo de un periodo es el que estaba vigente cuando empezó: un
    // cambio de frecuencia nunca altera un periodo ya en curso (§10).
    final target = _resolver.configAt(habit.periodicityTimeline, period.start);

    var completed = 0;
    for (final log in logs) {
      if (log.habitId != habit.id) continue;
      if (!log.isActivity) continue;
      if (!period.contains(log.date)) continue;
      completed++;
    }

    return GoalProgress(
      habitId: habit.id,
      target: target,
      period: period,
      completed: completed,
    );
  }

  List<GoalProgress> forHabits({
    required List<Habit> habits,
    required List<HabitLog> logs,
    required LogicalDate today,
  }) => [
    for (final habit in habits)
      forHabit(habit: habit, logs: logs, today: today),
  ];
}
