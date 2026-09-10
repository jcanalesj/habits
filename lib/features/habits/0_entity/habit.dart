import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';
import 'package:habits/features/habits/0_entity/periodicity_change.dart';

part 'habit.freezed.dart';

/// Configuración de un hábito. No contiene rachas: son derivadas de los
/// registros (fuente de verdad) y viven en [StreaksSnapshot].
@freezed
abstract class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String name,

    /// Un hábito pertenece a un único ámbito (decisión cerrada, sección 4.4).
    required String ambitoId,
    required Periodicity periodicity,

    /// Cambios de periodicidad anteriores, en orden cronológico.
    @Default([]) List<PeriodicityChange> periodicityHistory,

    /// Cupo de descansos planificados dentro del periodo (ej. 2 de cada 7).
    @Default(0) int restDaysAllowed,

    /// Tarea alternativa más ligera que salva la racha del ámbito.
    String? recoveryTask,

    /// Límite de uso de la tarea de recuperación: 1 vez cada X días.
    @Default(7) int recoveryCooldownDays,

    /// Color asignado de la paleta al crear el hábito, editable.
    required int colorValue,
    required String emoji,

    /// Hora fija de recordatorio en formato "HH:mm" (v1), opcional.
    String? reminderTime,

    /// Posición en las listas.
    @Default(0) int order,
    required DateTime createdAt,

    /// Soft delete: los hábitos borrados conservan su histórico de registros
    /// y no aparecen en las consultas normales.
    DateTime? deletedAt,
  }) = _Habit;

  const Habit._();

  bool get isDeleted => deletedAt != null;
}
