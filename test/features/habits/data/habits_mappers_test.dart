import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/3_data/mappers/habits_mappers.dart';

import '../../../helpers/habits_test_helpers.dart';

void main() {
  group('HabitsMappers', () {
    test('serializa el hábito con los nombres de campo de Firestore', () {
      final habit = Habit(
        id: 'h1',
        name: 'Leer',
        ambitoId: 'desarrollo',
        periodicity: Periodicity.weekly,
        periodicityHistory: [
          PeriodicityChange(
            periodicity: Periodicity.daily,
            since: day(2026, 9, 1),
          ),
        ],
        restDaysAllowed: 2,
        recoveryTask: '5 páginas',
        recoveryCooldownDays: 10,
        colorValue: 0xFFF59E0B,
        emoji: '📖',
        reminderTime: '21:00',
        order: 3,
        createdAt: day(2026, 8, 1),
      );

      final map = HabitsMappers.habitToDto(habit).toEditableMap();

      expect(map, {
        'nombre': 'Leer',
        'emoji': '📖',
        'colorValue': 0xFFF59E0B,
        'ambitoId': 'desarrollo',
        'periodicidad': 'weekly',
        'historialPeriodicidad': [
          {'periodicidad': 'daily', 'desde': '2026-09-01'},
        ],
        'descansosPermitidos': 2,
        'tareaRecuperacion': '5 páginas',
        'recuperacionCooldownDias': 10,
        'recordatorioHora': '21:00',
        'orden': 3,
      });
    });

    test('enums desconocidos caen a valores seguros', () {
      expect(HabitsMappers.periodicityFromString('yearly'), Periodicity.yearly);
      expect(HabitsMappers.periodicityFromString('???'), Periodicity.daily);
      expect(
        HabitsMappers.logTypeFromString('plannedRest'),
        HabitLogType.plannedRest,
      );
      expect(HabitsMappers.logTypeFromString('???'), HabitLogType.completed);
    });
  });
}
