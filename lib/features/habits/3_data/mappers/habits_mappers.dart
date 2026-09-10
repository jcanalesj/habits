import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';
import 'package:habits/features/habits/3_data/dtos/ambito_dto.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';
import 'package:habits/features/habits/3_data/dtos/habit_dto.dart';
import 'package:habits/features/habits/3_data/dtos/habit_log_dto.dart';
import 'package:habits/features/habits/3_data/dtos/streaks_dto.dart';

/// Conversión DTO ⇄ entidad. Los DTOs nunca salen de `3_data`.
abstract final class HabitsMappers {
  static Periodicity periodicityFromString(String value) => Periodicity.values
      .firstWhere((p) => p.name == value, orElse: () => Periodicity.daily);

  static HabitLogType logTypeFromString(String value) => HabitLogType.values
      .firstWhere((t) => t.name == value, orElse: () => HabitLogType.completed);

  static Habit habitFromDto(HabitDto dto) => Habit(
    id: dto.id,
    name: dto.nombre,
    emoji: dto.emoji,
    colorValue: dto.colorValue,
    ambitoId: dto.ambitoId,
    periodicity: periodicityFromString(dto.periodicidad),
    periodicityHistory: dto.historialPeriodicidad
        .map(
          (e) => PeriodicityChange(
            periodicity: periodicityFromString(
              e[FirestoreFields.periodicidad] as String? ?? 'daily',
            ),
            since: _parseDayOr(e[FirestoreFields.desde] as String?),
          ),
        )
        .toList(),
    restDaysAllowed: dto.descansosPermitidos,
    recoveryTask: dto.tareaRecuperacion,
    recoveryCooldownDays: dto.recuperacionCooldownDias,
    reminderTime: dto.recordatorioHora,
    order: dto.orden,
    // Con una escritura local pendiente el serverTimestamp aún es null: el
    // hábito acaba de crearse en este dispositivo.
    createdAt: dto.createdAt ?? DateTime.now(),
    deletedAt: dto.deletedAt,
  );

  static HabitDto habitToDto(Habit habit) => HabitDto(
    id: habit.id,
    nombre: habit.name,
    emoji: habit.emoji,
    colorValue: habit.colorValue,
    ambitoId: habit.ambitoId,
    periodicidad: habit.periodicity.name,
    historialPeriodicidad: habit.periodicityHistory
        .map(
          (change) => <String, dynamic>{
            FirestoreFields.periodicidad: change.periodicity.name,
            FirestoreFields.desde: LogicalDay.format(change.since),
          },
        )
        .toList(),
    descansosPermitidos: habit.restDaysAllowed,
    tareaRecuperacion: habit.recoveryTask,
    recuperacionCooldownDias: habit.recoveryCooldownDays,
    recordatorioHora: habit.reminderTime,
    orden: habit.order,
    createdAt: habit.createdAt,
    deletedAt: habit.deletedAt,
  );

  static Ambito ambitoFromDto(AmbitoDto dto) => Ambito(
    id: dto.id,
    name: dto.nombre,
    emoji: dto.emoji,
    colorValue: dto.colorValue,
    isPredefined: dto.esPredefinido,
    order: dto.orden,
    createdAt: dto.createdAt,
  );

  static AmbitoDto ambitoToDto(Ambito ambito) => AmbitoDto(
    id: ambito.id,
    nombre: ambito.name,
    emoji: ambito.emoji,
    colorValue: ambito.colorValue,
    esPredefinido: ambito.isPredefined,
    orden: ambito.order,
    createdAt: ambito.createdAt,
  );

  static HabitLog logFromDto(HabitLogDto dto) => HabitLog(
    id: dto.id,
    habitId: dto.habitoId,
    date: _parseDayOr(dto.dia),
    type: logTypeFromString(dto.tipo),
  );

  static StreaksSnapshot streaksFromDto(StreaksDto dto) => StreaksSnapshot(
    general: GeneralStreak(
      count: dto.generalActual,
      comodinDisponible: dto.generalComodinDisponible,
      lastLogDate: dto.ultimoDiaRegistrado == null
          ? null
          : _parseDayOr(dto.ultimoDiaRegistrado),
    ),
    habits: {
      for (final entry in dto.habitos.entries)
        entry.key: HabitStreak(
          current: (entry.value[FirestoreFields.actual] as num?)?.toInt() ?? 0,
          best: (entry.value[FirestoreFields.mejor] as num?)?.toInt() ?? 0,
        ),
    },
    ambitos: {
      for (final entry in dto.ambitos.entries)
        entry.key: AmbitoStreak(
          current: (entry.value[FirestoreFields.actual] as num?)?.toInt() ?? 0,
          best: (entry.value[FirestoreFields.mejor] as num?)?.toInt() ?? 0,
          comodinDisponible:
              entry.value[FirestoreFields.comodinDisponible] as bool? ?? true,
        ),
    },
    calculatedThrough: dto.calculadoHasta == null
        ? null
        : _parseDayOr(dto.calculadoHasta),
  );

  static DateTime _parseDayOr(String? day) {
    if (day == null) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return LogicalDay.parse(day);
    } on FormatException {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
