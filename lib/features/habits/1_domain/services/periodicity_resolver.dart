import 'package:habits/features/habits/0_entity/goal_progress.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';
import 'package:habits/features/habits/1_domain/services/logical_calendar.dart';

/// Resuelve qué objetivo tenía (o tendrá) un hábito en cada momento y qué
/// periodo natural le corresponde a un día.
///
/// El historial de periodicidad es una LÍNEA TEMPORAL: una lista ordenada de
/// [PeriodicityEntry] cuyo `since` puede ser futuro. No hay ningún campo
/// derivado que pueda quedarse obsoleto y no hace falta ninguna escritura de
/// "promoción" cuando llega la fecha efectiva: el objetivo vigente se deduce
/// siempre de la línea temporal (§10/§11).
///
/// Esto es también lo que permitirá calcular los rangos por hábito en el
/// futuro (§7): se conserva qué objetivo había en cada fecha.
class PeriodicityResolver {
  const PeriodicityResolver(this._calendar);

  final LogicalCalendar _calendar;

  /// Objetivo vigente el día [date].
  ///
  /// [timeline] debe estar ordenada por `since` ascendente y empezar por la
  /// configuración inicial del hábito.
  Periodicity configAt(List<PeriodicityEntry> timeline, LogicalDate date) {
    var result = timeline.isEmpty
        ? Periodicity.daily
        : timeline.first.periodicity;
    for (final entry in timeline) {
      if (entry.since.isAfter(date)) break;
      result = entry.periodicity;
    }
    return result;
  }

  /// Próxima entrada de la línea temporal que todavía no está vigente, o
  /// null si no hay ningún cambio pendiente. La UI la usa para avisar de
  /// cuándo entrará en vigor el cambio (§10).
  PeriodicityEntry? pendingChange(
    List<PeriodicityEntry> timeline,
    LogicalDate today,
  ) {
    for (final entry in timeline) {
      if (entry.since.isAfter(today)) return entry;
    }
    return null;
  }

  /// Fecha en la que debe entrar en vigor un cambio de objetivo decidido
  /// hoy: el primer día del **siguiente periodo natural completo del tipo
  /// nuevo**, estrictamente posterior a [today].
  ///
  /// Nunca se modifica un periodo ya empezado y nunca se crean periodos
  /// parciales ni objetivos prorrateados (decisión de producto de la fase
  /// 5). La misma regla vale tanto si cambia el tipo como si solo cambia la
  /// cantidad dentro del mismo tipo:
  ///
  ///   3/semana → 12/mes   (un jueves)  → el día 1 del mes siguiente
  ///   12/mes   → 3/semana              → el lunes siguiente
  ///   3/semana → 5/semana              → el lunes siguiente
  ///   cualquiera → X/año               → el próximo 1 de enero
  ///   cualquiera → diario              → mañana
  LogicalDate effectiveDateFor(PeriodicityType newType, LogicalDate today) =>
      switch (newType) {
        PeriodicityType.daily => today.next,
        PeriodicityType.weekly => _calendar.startOfWeek(today).addDays(7),
        PeriodicityType.monthly =>
          LogicalDate.normalized(today.year, today.month + 1, 1),
        PeriodicityType.yearly => LogicalDate(today.year + 1, 1, 1),
      };

  /// Periodo natural completo del tipo [type] que contiene a [date].
  GoalPeriod periodFor(PeriodicityType type, LogicalDate date) =>
      switch (type) {
        PeriodicityType.daily => GoalPeriod(
          type: type,
          start: date,
          end: date,
        ),
        PeriodicityType.weekly => GoalPeriod(
          type: type,
          start: _calendar.startOfWeek(date),
          end: _calendar.endOfWeek(date),
        ),
        PeriodicityType.monthly => GoalPeriod(
          type: type,
          start: _calendar.startOfMonth(date),
          end: _calendar.endOfMonth(date),
        ),
        PeriodicityType.yearly => GoalPeriod(
          type: type,
          start: _calendar.startOfYear(date),
          end: _calendar.endOfYear(date),
        ),
      };

  /// Periodo vigente de un hábito el día [date], según su línea temporal.
  GoalPeriod currentPeriod(
    List<PeriodicityEntry> timeline,
    LogicalDate date,
  ) => periodFor(configAt(timeline, date).type, date);
}
