import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';

part 'habit.freezed.dart';

/// Configuración de un hábito.
///
/// No contiene rachas: en esta versión solo existe la racha general del
/// usuario (§1), y aun esa es un dato derivado de los registros.
///
/// Tampoco contiene descansos ni tareas de recuperación: ambos conceptos se
/// retiran del motor en la fase 5 (§27/§28). El único mecanismo para
/// proteger la racha es el comodín.
@freezed
abstract class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String name,

    /// Un hábito pertenece a un único ámbito. Los ámbitos organizan, pero
    /// no tienen racha propia (§29).
    required String ambitoId,

    /// Línea temporal de objetivos, ordenada por `since` ascendente. La
    /// primera entrada es la configuración inicial; las entradas con
    /// `since` futura son cambios ya decididos pero todavía no vigentes.
    ///
    /// Es la fuente de verdad de la periodicidad: no hay campo "actual"
    /// denormalizado que pueda quedarse obsoleto (§10/§11), y conserva qué
    /// objetivo había en cada fecha para las estadísticas y el futuro
    /// sistema de rangos (§7).
    required List<PeriodicityEntry> periodicityTimeline,

    /// Color asignado de la paleta al crear el hábito, editable.
    required int colorValue,
    required String emoji,

    /// Hora fija de recordatorio en formato "HH:mm" (v1), opcional.
    String? reminderTime,

    /// Posición en las listas.
    @Default(0) int order,
    required DateTime createdAt,

    /// Soft delete: los hábitos borrados conservan su histórico de registros
    /// y no aparecen en las consultas normales (§30).
    DateTime? deletedAt,
  }) = _Habit;

  const Habit._();

  bool get isDeleted => deletedAt != null;

  /// Objetivo vigente el día [date] según la línea temporal.
  Periodicity periodicityOn(LogicalDate date) {
    var result = periodicityTimeline.isEmpty
        ? Periodicity.daily
        : periodicityTimeline.first.periodicity;
    for (final entry in periodicityTimeline) {
      if (entry.since.isAfter(date)) break;
      result = entry.periodicity;
    }
    return result;
  }
}
