import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/ambito.dart';
import 'package:habits/features/habits/0_entity/general_streak.dart';
import 'package:habits/features/habits/0_entity/habit.dart';
import 'package:habits/features/habits/0_entity/habit_log.dart';

part 'home_summary.freezed.dart';

/// Agregado de solo lectura con todo lo que necesita el dashboard de inicio.
@freezed
abstract class HomeSummary with _$HomeSummary {
  const factory HomeSummary({
    required GeneralStreak generalStreak,
    required List<Ambito> ambitos,
    required List<Habit> habits,
    /// Registros de la semana en curso (lunes a domingo).
    required List<HabitLog> weekLogs,
  }) = _HomeSummary;
}
