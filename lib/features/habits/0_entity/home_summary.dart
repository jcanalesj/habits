import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/ambito.dart';
import 'package:habits/features/habits/0_entity/general_streak.dart';
import 'package:habits/features/habits/0_entity/habit.dart';
import 'package:habits/features/habits/0_entity/habit_log.dart';
import 'package:habits/features/habits/0_entity/streaks_snapshot.dart';

part 'home_summary.freezed.dart';

/// Agregado de solo lectura con todo lo que necesita el dashboard de inicio.
/// Si un hábito está completado se decide SIEMPRE por [weekLogs], nunca por
/// la caché de rachas.
@freezed
abstract class HomeSummary with _$HomeSummary {
  const factory HomeSummary({
    /// Caché de rachas; vacía si aún no se ha calculado.
    required StreaksSnapshot streaks,
    required List<Ambito> ambitos,

    /// Hábitos activos (sin soft delete).
    required List<Habit> habits,

    /// Registros de la semana en curso (lunes a domingo).
    required List<HabitLog> weekLogs,
  }) = _HomeSummary;

  const HomeSummary._();

  GeneralStreak get generalStreak => streaks.general;

  int habitStreak(String habitId) => streaks.habitStreak(habitId).current;

  AmbitoStreak ambitoStreak(String ambitoId) => streaks.ambitoStreak(ambitoId);

  bool isCompletedOn(String habitId, DateTime day) => weekLogs.any(
    (log) =>
        log.habitId == habitId &&
        log.date.year == day.year &&
        log.date.month == day.month &&
        log.date.day == day.day,
  );
}
