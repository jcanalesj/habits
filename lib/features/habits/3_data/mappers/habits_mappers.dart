import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/3_data/dtos/ambito_dto.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';
import 'package:habits/features/habits/3_data/dtos/habit_dto.dart';
import 'package:habits/features/habits/3_data/dtos/habit_log_dto.dart';
import 'package:habits/features/habits/3_data/dtos/streaks_dto.dart';
import 'package:habits/features/habits/3_data/dtos/wildcard_balance_dto.dart';

/// Conversión DTO ⇄ entidad. Los DTOs nunca salen de `3_data`.
abstract final class HabitsMappers {
  static PeriodicityType periodicityTypeFromString(String value) =>
      PeriodicityType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => PeriodicityType.daily,
      );

  /// Solo `completed` es actividad real. Cualquier otro valor (los
  /// `recovery` y `plannedRest` heredados del modelo antiguo) se marca como
  /// legacy y NO cuenta para la racha.
  static HabitLogType logTypeFromString(String value) =>
      value == FirestoreFields.tipoCompleted
      ? HabitLogType.completed
      : HabitLogType.legacy;

  static Periodicity periodicityFromMap(Map<String, dynamic> map) =>
      Periodicity(
        type: periodicityTypeFromString(
          map[FirestoreFields.tipo] as String? ?? 'daily',
        ),
        timesPerPeriod: (map[FirestoreFields.veces] as num?)?.toInt() ?? 1,
      );

  static Map<String, dynamic> periodicityToMap(Periodicity periodicity) => {
    FirestoreFields.tipo: periodicity.type.name,
    FirestoreFields.veces: periodicity.timesPerPeriod,
  };

  static Habit habitFromDto(HabitDto dto) {
    // Con una escritura local pendiente el serverTimestamp aún es null: el
    // hábito acaba de crearse en este dispositivo.
    final createdAt = dto.createdAt ?? DateTime.now();
    final initial = periodicityFromMap(dto.periodicidad);

    // La línea temporal siempre arranca con la configuración inicial, cuyo
    // `since` es el día de creación del hábito. Así `configAt()` tiene
    // respuesta para cualquier fecha, sin casos especiales.
    final createdDay = LogicalDate(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );
    final timeline = <PeriodicityEntry>[
      PeriodicityEntry(periodicity: initial, since: createdDay),
    ];
    for (final change in dto.cambiosPeriodicidad) {
      final since = LogicalDate.tryParse(
        change[FirestoreFields.desde] as String?,
      );
      if (since == null) continue;
      timeline.add(
        PeriodicityEntry(periodicity: periodicityFromMap(change), since: since),
      );
    }
    timeline.sort((a, b) => a.since.compareTo(b.since));

    return Habit(
      id: dto.id,
      name: dto.nombre,
      emoji: dto.emoji,
      iconId: dto.iconId,
      colorValue: dto.colorValue,
      ambitoId: dto.ambitoId,
      periodicityTimeline: timeline,
      reminderTime: dto.recordatorioHora,
      order: dto.orden,
      createdAt: createdAt,
      deletedAt: dto.deletedAt,
      trackingType: HabitTrackingTypeX.fromStorage(dto.trackingType),
      targetCount: dto.targetCount,
      unit: dto.unit,
      displayGoal: dto.displayGoal,
      progressIconId: dto.progressIconId,
    );
  }

  static HabitDto habitToDto(Habit habit) {
    final timeline = habit.periodicityTimeline;
    return HabitDto(
      id: habit.id,
      nombre: habit.name,
      emoji: habit.emoji,
      iconId: habit.iconId,
      colorValue: habit.colorValue,
      ambitoId: habit.ambitoId,
      periodicidad: periodicityToMap(
        timeline.isEmpty ? Periodicity.daily : timeline.first.periodicity,
      ),
      // La primera entrada es la configuración inicial y ya viaja en
      // `periodicidad`: solo se persisten los cambios posteriores.
      cambiosPeriodicidad: [
        for (final entry in timeline.skip(1))
          <String, dynamic>{
            ...periodicityToMap(entry.periodicity),
            FirestoreFields.desde: entry.since.key,
          },
      ],
      recordatorioHora: habit.reminderTime,
      orden: habit.order,
      createdAt: habit.createdAt,
      deletedAt: habit.deletedAt,
      trackingType: habit.trackingType.storageValue,
      targetCount: habit.targetCount,
      unit: habit.unit,
      displayGoal: habit.displayGoal,
      progressIconId: habit.progressIconId,
    );
  }

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

  /// Devuelve null si el día no es parseable: un documento corrupto no debe
  /// tumbar la Home ni contarse como actividad.
  static HabitLog? logFromDto(HabitLogDto dto) {
    final date = LogicalDate.tryParse(dto.dia);
    if (date == null) return null;
    return HabitLog(
      id: dto.id,
      habitId: dto.habitoId,
      date: date,
      type: logTypeFromString(dto.tipo),
      completedCount: dto.completedCount,
      targetCount: dto.targetCount,
    );
  }

  static StreakCacheEntry? streakCacheFromDto(StreaksDto dto) {
    final calculatedThrough = LogicalDate.tryParse(dto.calculadoHasta);
    if (calculatedThrough == null) return null;
    return StreakCacheEntry(
      currentStreak: dto.rachaActual,
      bestStreak: dto.mejorRacha,
      lastActivityDay: LogicalDate.tryParse(dto.ultimoDiaActividad),
      calculatedThrough: calculatedThrough,
      algorithmVersion: dto.version,
    );
  }

  static WildcardBalance wildcardBalanceFromDto(WildcardBalanceDto dto) =>
      WildcardBalance(
        available: dto.saldo,
        lastGrantYearMonth: dto.ultimaConcesionYM,
        grantedTotal: dto.concedidosTotal,
        lastProtectedDay: LogicalDate.tryParse(dto.ultimoDiaProtegido),
      );
}
