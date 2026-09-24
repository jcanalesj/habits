import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/3_data/dtos/habit_dto.dart';
import 'package:habits/features/habits/3_data/mappers/habits_mappers.dart';

import '../../../helpers/habits_test_helpers.dart';

void main() {
  group('HabitsMappers — serialización', () {
    test('escribe los nombres de campo de Firestore de la fase 5', () {
      final habit = Habit(
        id: 'h1',
        name: 'Leer',
        ambitoId: 'desarrollo',
        periodicityTimeline: [
          PeriodicityEntry(
            periodicity: const Periodicity(
              type: PeriodicityType.weekly,
              timesPerPeriod: 3,
            ),
            since: day(2026, 8, 1),
          ),
          PeriodicityEntry(
            periodicity: const Periodicity(
              type: PeriodicityType.monthly,
              timesPerPeriod: 12,
            ),
            since: day(2026, 10, 1),
          ),
        ],
        colorValue: 0xFFF59E0B,
        emoji: '📖',
        iconId: 'book',
        reminderTime: '21:00',
        order: 3,
        createdAt: DateTime.utc(2026, 8, 1),
      );

      final map = HabitsMappers.habitToDto(habit).toEditableMap();

      expect(map, {
        'nombre': 'Leer',
        'emoji': '📖',
        'iconId': 'book',
        'colorValue': 0xFFF59E0B,
        'ambitoId': 'desarrollo',
        // La configuración inicial va en `periodicidad`...
        'periodicidad': {'tipo': 'weekly', 'veces': 3},
        // ...y solo los cambios posteriores en la línea temporal, con su
        // fecha efectiva (que aquí es futura: un cambio diferido).
        'cambiosPeriodicidad': [
          {'tipo': 'monthly', 'veces': 12, 'desde': '2026-10-01'},
        ],
        'recordatorioHora': '21:00',
        'recordatorioMensaje': null,
        'orden': 3,
        'trackingType': 'single',
        'targetCount': 1,
        'unit': null,
        'displayGoal': null,
        'progressIconId': 'check',
      });
    });

    test('ida y vuelta conserva la línea temporal', () {
      final original = Habit(
        id: 'h1',
        name: 'Leer',
        ambitoId: 'desarrollo',
        periodicityTimeline: [
          PeriodicityEntry(
            periodicity: const Periodicity(
              type: PeriodicityType.weekly,
              timesPerPeriod: 3,
            ),
            since: day(2026, 8, 1),
          ),
          PeriodicityEntry(
            periodicity: const Periodicity(
              type: PeriodicityType.weekly,
              timesPerPeriod: 5,
            ),
            since: day(2026, 9, 14),
          ),
        ],
        colorValue: 0xFFF59E0B,
        emoji: '📖',
        iconId: 'book',
        order: 3,
        createdAt: DateTime.utc(2026, 8, 1),
      );

      final dto = HabitsMappers.habitToDto(original);
      final roundTripped = HabitsMappers.habitFromDto(dto);

      expect(roundTripped.periodicityTimeline, original.periodicityTimeline);
      expect(roundTripped.iconId, 'book');
      expect(roundTripped.periodicityOn(day(2026, 9, 13)).timesPerPeriod, 3);
      expect(roundTripped.periodicityOn(day(2026, 9, 14)).timesPerPeriod, 5);
    });
  });

  group('HabitsMappers — compatibilidad con el esquema anterior', () {
    test('periodicidad como string suelto se lee como 1 vez por periodo', () {
      // Migración autorizada: en el modelo antiguo la periodicidad no
      // llevaba cantidad, así que 'weekly' solo puede significar 1/semana.
      expect(HabitDto.normalizePeriodicidad('weekly'), {
        'tipo': 'weekly',
        'veces': 1,
      });
      expect(HabitDto.normalizePeriodicidad('daily'), {
        'tipo': 'daily',
        'veces': 1,
      });
    });

    test('un valor de periodicidad corrupto cae a diario', () {
      expect(
        HabitsMappers.periodicityTypeFromString('???'),
        PeriodicityType.daily,
      );
      expect(HabitDto.normalizePeriodicidad(null), {
        'tipo': 'daily',
        'veces': 1,
      });
    });

    test('los tipos de registro antiguos NO cuentan como actividad', () {
      // Se conservan tal cual en Firestore, pero solo 'completed' es
      // actividad real para la racha general.
      expect(
        HabitsMappers.logTypeFromString('completed'),
        HabitLogType.completed,
      );
      expect(HabitsMappers.logTypeFromString('recovery'), HabitLogType.legacy);
      expect(
        HabitsMappers.logTypeFromString('plannedRest'),
        HabitLogType.legacy,
      );
      expect(HabitsMappers.logTypeFromString('???'), HabitLogType.legacy);
    });
  });
}
