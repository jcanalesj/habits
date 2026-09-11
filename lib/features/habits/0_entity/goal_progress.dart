import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';

part 'goal_progress.freezed.dart';

/// Periodo natural completo sobre el que se mide un objetivo: un día, una
/// semana lunes–domingo, un mes natural o un año natural, siempre en la
/// zona horaria del perfil (§9).
///
/// Nunca hay periodos parciales ni objetivos prorrateados: un cambio de
/// periodicidad entra en vigor justo al empezar el siguiente periodo
/// natural completo del nuevo tipo (§10/§11).
@freezed
abstract class GoalPeriod with _$GoalPeriod {
  const factory GoalPeriod({
    required PeriodicityType type,
    required LogicalDate start,
    required LogicalDate end,
  }) = _GoalPeriod;

  const GoalPeriod._();

  bool contains(LogicalDate date) =>
      date.isAtOrAfter(start) && date.isAtOrBefore(end);
}

/// Progreso de un hábito dentro de su periodo actual: "2 / 3 esta semana".
///
/// Esto NO es una racha (§37). Mide cumplimiento del objetivo dentro de un
/// periodo, no continuidad entre días. `Streak` y `GoalProgress` son
/// conceptos separados y no comparten entidades ni nombres.
@freezed
abstract class GoalProgress with _$GoalProgress {
  const factory GoalProgress({
    required String habitId,

    /// Objetivo vigente para este periodo. Si el usuario cambió la
    /// frecuencia, sigue siendo el objetivo con el que empezó el periodo.
    required Periodicity target,
    required GoalPeriod period,

    /// Registros de actividad real del hábito dentro del periodo. Puede
    /// superar el objetivo: se permite seguir registrando (§44).
    @Default(0) int completed,
  }) = _GoalProgress;

  const GoalProgress._();

  int get goal => target.target;

  bool get isMet => completed >= goal;

  /// Progreso normalizado 0..1 para barras e indicadores.
  double get fraction => goal <= 0 ? 0 : (completed / goal).clamp(0.0, 1.0);
}
