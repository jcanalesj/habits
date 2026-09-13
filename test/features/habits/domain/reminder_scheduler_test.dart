import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/reminder_scheduler.dart';

LogicalDate d(String key) => LogicalDate.parse(key);

const hoy = LogicalDate(2026, 9, 13);

Habit habit({
  String id = 'h1',
  String name = 'Leer',
  String? reminderTime = '21:00',
  DateTime? deletedAt,
  Periodicity periodicity = Periodicity.daily,
}) => Habit(
  id: id,
  name: name,
  ambitoId: 'general',
  periodicityTimeline: [
    PeriodicityEntry(periodicity: periodicity, since: d('2026-01-01')),
  ],
  colorValue: 0xFF000000,
  emoji: '📖',
  reminderTime: reminderTime,
  createdAt: DateTime.utc(2026, 1, 1),
  deletedAt: deletedAt,
);

List<HabitReminder> schedule({
  required List<Habit> habits,
  Map<String, Set<LogicalDate>> completed = const {},
  int nowMinutes = 8 * 60,
  bool Function(Habit, LogicalDate)? isGoalMetOn,
  int horizonDays = ReminderScheduler.horizonDays,
  int maxScheduled = ReminderScheduler.maxScheduled,
}) => ReminderScheduler.schedule(
  habits: habits,
  today: hoy,
  completedDays: completed,
  nowMinutes: nowMinutes,
  isGoalMetOn: isGoalMetOn,
  horizonDays: horizonDays,
  maxScheduled: maxScheduled,
);

void main() {
  group('qué se programa', () {
    test('un hábito sin hora no genera avisos', () {
      expect(schedule(habits: [habit(reminderTime: null)]), isEmpty);
    });

    test('una hora inválida no genera avisos', () {
      expect(schedule(habits: [habit(reminderTime: '25:99')]), isEmpty);
      expect(schedule(habits: [habit(reminderTime: '9:00')]), isEmpty);
    });

    test('un hábito con hora cubre el horizonte completo', () {
      final result = schedule(habits: [habit()]);

      expect(result, hasLength(ReminderScheduler.horizonDays));
      expect(result.first.date, hoy);
      expect(result.last.date, hoy.addDays(6));
      expect(result.first.time, '21:00');
      expect(result.first.habitName, 'Leer');
    });

    test('los hábitos eliminados no avisan', () {
      expect(
        schedule(habits: [habit(deletedAt: DateTime.utc(2026, 9, 1))]),
        isEmpty,
      );
      // Control: el mismo hábito sin borrar sí avisa.
      expect(schedule(habits: [habit()]), isNotEmpty);
    });

    test('se ordenan por fecha y hora', () {
      final result = schedule(
        habits: [
          habit(id: 'tarde', reminderTime: '22:00'),
          habit(id: 'manana', reminderTime: '09:00'),
        ],
      );

      expect(result.first.habitId, 'manana');
      expect(result.first.date, hoy);
      expect(result[1].habitId, 'tarde');
      expect(result[1].date, hoy);
    });
  });

  group('no dar la lata', () {
    test('si hoy ya está registrado, hoy no suena', () {
      final result = schedule(
        habits: [habit()],
        completed: {
          'h1': {hoy},
        },
      );

      expect(result.map((r) => r.date), isNot(contains(hoy)));
      expect(result.first.date, hoy.addDays(1));
      expect(result, hasLength(ReminderScheduler.horizonDays - 1));
    });

    test('si la hora de hoy ya pasó, hoy no suena', () {
      // Son las 22:00 y el recordatorio era a las 21:00.
      final result = schedule(habits: [habit()], nowMinutes: 22 * 60);

      expect(result.first.date, hoy.addDays(1));
    });

    test('justo a la hora tampoco suena (ya es tarde)', () {
      final result = schedule(habits: [habit()], nowMinutes: 21 * 60);

      expect(result.first.date, hoy.addDays(1));
    });

    test('un minuto antes sí suena hoy', () {
      final result = schedule(habits: [habit()], nowMinutes: 21 * 60 - 1);

      expect(result.first.date, hoy);
    });

    test('con el objetivo del periodo cumplido no se avisa', () {
      // "3 veces por semana" ya cumplido: callar el resto de la semana.
      final finDeSemana = hoy.addDays(4);
      final result = schedule(
        habits: [habit()],
        isGoalMetOn: (habit, day) => day.isAtOrBefore(finDeSemana),
      );

      expect(result.every((r) => r.date.isAfter(finDeSemana)), isTrue);
    });
  });

  group('límites del sistema', () {
    test('nunca se pasa del tope de avisos pendientes', () {
      // iOS descarta en silencio lo que pase de 64 por app.
      final habits = [
        for (var i = 0; i < 20; i++) habit(id: 'h$i', name: 'Hábito $i'),
      ];

      final result = schedule(habits: habits);

      expect(result.length, ReminderScheduler.maxScheduled);
      expect(ReminderScheduler.maxScheduled, lessThan(64));
    });

    test('al recortar se conservan los avisos más próximos', () {
      final habits = [
        for (var i = 0; i < 20; i++) habit(id: 'h$i'),
      ];

      final result = schedule(habits: habits);

      // 20 hábitos x 7 días = 140 candidatos; con tope 56 solo caben los
      // de los primeros días.
      expect(result.first.date, hoy);
      expect(result.last.date.isBefore(hoy.addDays(6)), isTrue);
    });
  });

  group('identidad de cada aviso', () {
    test('el id es estable: reprogramar no duplica', () {
      final primero = schedule(habits: [habit()]).first;
      final segundo = schedule(habits: [habit()]).first;

      expect(primero.notificationId, segundo.notificationId);
    });

    test('días distintos del mismo hábito tienen ids distintos', () {
      final result = schedule(habits: [habit()]);
      final ids = result.map((r) => r.notificationId).toSet();

      expect(ids, hasLength(result.length));
    });

    test('hábitos distintos el mismo día tienen ids distintos', () {
      final result = schedule(
        habits: [habit(id: 'a'), habit(id: 'b')],
      );
      final delDia = result.where((r) => r.date == hoy).toList();

      expect(delDia, hasLength(2));
      expect(delDia[0].notificationId, isNot(delDia[1].notificationId));
    });

    test('el id cabe en un int de 32 bits con signo (lo exige Android)', () {
      for (final reminder in schedule(habits: [habit()])) {
        expect(reminder.notificationId, greaterThanOrEqualTo(0));
        expect(reminder.notificationId, lessThanOrEqualTo(0x7fffffff));
      }
    });
  });

  test('sin hábitos no hay nada que programar', () {
    expect(schedule(habits: []), isEmpty);
  });
}
