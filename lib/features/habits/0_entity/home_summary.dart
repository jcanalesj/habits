import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/ambito.dart';
import 'package:habits/features/habits/0_entity/goal_progress.dart';
import 'package:habits/features/habits/0_entity/habit.dart';
import 'package:habits/features/habits/0_entity/habit_log.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/0_entity/streak_state.dart';
import 'package:habits/features/habits/0_entity/wildcard_balance.dart';

part 'home_summary.freezed.dart';

/// Agregado de solo lectura con todo lo que muestra la Home.
///
/// Si un hábito está completado se decide SIEMPRE por [weekLogs] (los
/// registros), nunca por una caché.
@freezed
abstract class HomeSummary with _$HomeSummary {
  const factory HomeSummary({
    /// Día lógico de hoy en la zona horaria del perfil.
    required LogicalDate today,

    /// Racha general, calculada en vivo desde el histórico completo.
    required StreakState streak,
    required WildcardBalance wildcards,
    required List<Ambito> ambitos,

    /// Hábitos activos (sin soft delete).
    required List<Habit> habits,

    /// Progreso del objetivo de cada hábito activo en su periodo actual.
    required List<GoalProgress> progress,

    /// Registros de la semana en curso (lunes a domingo), para pintar los
    /// puntos de la semana y decidir qué está marcado hoy.
    required List<HabitLog> weekLogs,
  }) = _HomeSummary;

  const HomeSummary._();

  GoalProgress? progressOf(String habitId) {
    for (final item in progress) {
      if (item.habitId == habitId) return item;
    }
    return null;
  }

  bool isCompletedOn(String habitId, LogicalDate day) => weekLogs.any(
    (log) => log.habitId == habitId && log.isActivity && log.date == day,
  );

  int completedCountOn(String habitId, LogicalDate day) {
    for (final log in weekLogs) {
      if (log.habitId == habitId &&
          log.date == day &&
          log.type == HabitLogType.completed) {
        return log.completedCount;
      }
    }
    return 0;
  }
}
