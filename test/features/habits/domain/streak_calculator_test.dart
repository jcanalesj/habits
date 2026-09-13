import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/streak_calculator.dart';

/// Atajo: '2026-09-10' -> LogicalDate.
LogicalDate d(String key) => LogicalDate.parse(key);

Set<LogicalDate> days(List<String> keys) => {for (final k in keys) d(k)};

StreakState calc({
  List<String> activity = const [],
  List<String> protected = const [],
  required String today,
}) => StreakCalculator.calculate(
  activityDays: days(activity),
  protectedDays: days(protected),
  today: d(today),
);

void main() {
  group('racha general — reglas básicas', () {
    test('usuario sin registros: racha 0 y sin estado', () {
      final state = calc(today: '2026-09-11');

      expect(state.currentStreak, 0);
      expect(state.bestStreak, 0);
      expect(state.status, StreakStatus.none);
      expect(state.lastActivityDay, isNull);
      expect(state.rescue, isNull);
    });

    test('la racha empieza con el primer hábito, no al crear la cuenta', () {
      // Cuenta creada el 1, sin actividad hasta el 4: los días vacíos
      // anteriores no suman, no rompen y no necesitan comodín.
      final state = calc(activity: ['2026-09-04'], today: '2026-09-04');

      expect(state.currentStreak, 1);
      expect(state.status, StreakStatus.completedToday);
      expect(state.rescue, isNull);
    });

    test('varios hábitos el mismo día suman un único día', () {
      // El conjunto de días de actividad es justo lo que hace que 1 hábito y
      // 20 hábitos den el mismo resultado: el día está o no está.
      final state = calc(activity: ['2026-09-11'], today: '2026-09-11');

      expect(state.currentStreak, 1);
    });

    test('días consecutivos: cuenta días, no hábitos', () {
      // 4 + 1 + 8 hábitos en tres días = racha 3, no 13.
      final state = calc(
        activity: ['2026-09-09', '2026-09-10', '2026-09-11'],
        today: '2026-09-11',
      );

      expect(state.currentStreak, 3);
      expect(state.bestStreak, 3);
    });

    test('hoy sin actividad pero ayer sí: racha intacta, pendiente', () {
      final state = calc(
        activity: ['2026-09-09', '2026-09-10'],
        today: '2026-09-11',
      );

      expect(state.currentStreak, 2);
      expect(state.status, StreakStatus.pendingToday);
      expect(state.rescue, isNull);
    });
  });

  group('comodines y días protegidos', () {
    test('un día protegido mantiene la cadena', () {
      final state = calc(
        activity: ['2026-09-09', '2026-09-11'],
        protected: ['2026-09-10'],
        today: '2026-09-11',
      );

      expect(state.currentStreak, 2, reason: 'protege pero no suma');
      expect(state.status, StreakStatus.completedToday);
    });

    test('el comodín protege pero NO suma un día', () {
      // Racha 24 hasta el miércoles-1; miércoles vacío y protegido; al
      // completar el jueves la racha es 25, no 26.
      final activity = [
        for (var i = 0; i < 24; i++)
          LogicalDate.parse('2026-09-09').addDays(-i).key,
      ];

      final protegido = calc(
        activity: activity,
        protected: ['2026-09-10'],
        today: '2026-09-10',
      );
      expect(protegido.currentStreak, 24, reason: 'protegido: sigue en 24');

      final conActividad = calc(
        activity: [...activity, '2026-09-11'],
        protected: ['2026-09-10'],
        today: '2026-09-11',
      );
      expect(conActividad.currentStreak, 25, reason: 'el jueves sí suma');
    });

    test('día vacío sin proteger rompe la cadena', () {
      final state = calc(
        activity: ['2026-09-08', '2026-09-09', '2026-09-11'],
        today: '2026-09-11',
      );

      // El 10 quedó vacío: la cadena de 2 se rompió y hoy empieza otra.
      expect(state.currentStreak, 1);
      expect(state.bestStreak, 2);
    });
  });

  group('ventana de rescate y estado "en peligro"', () {
    test('ayer vacío: se ofrece rescate con la racha en peligro', () {
      final activity = [
        for (var i = 0; i < 24; i++)
          LogicalDate.parse('2026-09-09').addDays(-i).key,
      ];
      final state = calc(activity: activity, today: '2026-09-11');

      expect(state.status, StreakStatus.atRisk);
      expect(state.currentStreak, 0, reason: 'valor determinista: ya rota');
      expect(state.rescue!.day, d('2026-09-10'));
      expect(state.rescue!.streakAtRisk, 24);
      expect(
        state.rescue!.streakIfRescued,
        24,
        reason: 'hoy aún sin actividad',
      );
      expect(state.displayStreak, 24, reason: 'la UI enseña la que peligra');
    });

    test('ayer vacío y hoy con actividad: conviven los dos valores', () {
      final activity = [
        for (var i = 0; i < 24; i++)
          LogicalDate.parse('2026-09-09').addDays(-i).key,
        '2026-09-11',
      ];
      final state = calc(activity: activity, today: '2026-09-11');

      expect(state.status, StreakStatus.atRisk);
      expect(state.currentStreak, 1, reason: 'la nueva racha iniciada hoy');
      expect(state.rescue!.streakAtRisk, 24, reason: 'la racha protegible');
      expect(state.rescue!.streakIfRescued, 25, reason: '24 + el día de hoy');
      expect(state.displayStreak, 24);
    });

    test('anteayer vacío: la ventana ya expiró, no hay rescate', () {
      // El 9 quedó vacío. El 10 ya pasó sin rescatarlo, así que el 11 no
      // puede salvarlo aunque tenga comodines.
      final state = calc(
        activity: ['2026-09-07', '2026-09-08'],
        today: '2026-09-11',
      );

      expect(state.rescue, isNull);
      expect(state.status, StreakStatus.none);
      expect(state.currentStreak, 0);
      expect(state.bestStreak, 2, reason: 'el histórico se conserva');
    });

    test('ayer ya protegido: no se vuelve a ofrecer rescate', () {
      final state = calc(
        activity: ['2026-09-09'],
        protected: ['2026-09-10'],
        today: '2026-09-11',
      );

      expect(state.rescue, isNull);
      expect(state.status, StreakStatus.pendingToday);
      expect(state.currentStreak, 1);
    });

    test('sin historial previo no hay nada que rescatar', () {
      final state = calc(activity: ['2026-09-11'], today: '2026-09-11');

      expect(state.rescue, isNull);
      expect(state.status, StreakStatus.completedToday);
    });
  });

  group('nueva racha y mejor racha', () {
    test('tras una ruptura empieza una racha nueva', () {
      final state = calc(
        activity: [
          '2026-09-01', '2026-09-02', '2026-09-03', '2026-09-04',
          // hueco del 5 al 8
          '2026-09-09', '2026-09-10', '2026-09-11',
        ],
        today: '2026-09-11',
      );

      expect(state.currentStreak, 3);
      expect(state.bestStreak, 4);
    });

    test('bestStreak cuenta días de actividad, los protegidos no suman', () {
      // actividad, actividad, comodín, actividad -> cadena de 3 días reales.
      final state = calc(
        activity: ['2026-09-08', '2026-09-09', '2026-09-11'],
        protected: ['2026-09-10'],
        today: '2026-09-11',
      );

      expect(state.bestStreak, 3);
      expect(state.currentStreak, 3);
    });

    test('bestStreak conserva una racha antigua mayor que la actual', () {
      final state = calc(
        activity: [
          for (var i = 0; i < 10; i++)
            LogicalDate.parse('2026-01-10').addDays(-i).key,
          '2026-09-11',
        ],
        today: '2026-09-11',
      );

      expect(state.currentStreak, 1);
      expect(state.bestStreak, 10);
    });

    test('los registros de hábitos eliminados siguen contando', () {
      // El motor recibe días de actividad, sin saber de qué hábito vienen:
      // borrar un hábito hoy no puede reescribir la racha histórica.
      final state = calc(
        activity: ['2026-09-09', '2026-09-10', '2026-09-11'],
        today: '2026-09-11',
      );

      expect(state.currentStreak, 3);
    });
  });

  group('determinismo e idempotencia', () {
    test('dos ejecuciones con los mismos datos dan el mismo resultado', () {
      final input = {
        'activity': ['2026-09-08', '2026-09-09', '2026-09-11'],
        'protected': ['2026-09-10'],
      };

      final first = calc(
        activity: input['activity']!,
        protected: input['protected']!,
        today: '2026-09-11',
      );
      final second = calc(
        activity: input['activity']!,
        protected: input['protected']!,
        today: '2026-09-11',
      );

      expect(first, second);
    });

    test('el orden de los días no altera el resultado', () {
      final ordenado = calc(
        activity: ['2026-09-09', '2026-09-10', '2026-09-11'],
        today: '2026-09-11',
      );
      final desordenado = calc(
        activity: ['2026-09-11', '2026-09-09', '2026-09-10'],
        today: '2026-09-11',
      );

      expect(ordenado, desordenado);
    });

    test('un día protegido que además tuvo actividad no cuenta doble', () {
      final state = calc(
        activity: ['2026-09-10', '2026-09-11'],
        protected: ['2026-09-10'],
        today: '2026-09-11',
      );

      expect(state.currentStreak, 2);
    });
  });

  group('límites de calendario', () {
    test('la cadena cruza el cambio de mes', () {
      final state = calc(
        activity: ['2026-08-30', '2026-08-31', '2026-09-01'],
        today: '2026-09-01',
      );

      expect(state.currentStreak, 3);
    });

    test('la cadena cruza el cambio de año', () {
      final state = calc(
        activity: ['2026-12-30', '2026-12-31', '2027-01-01'],
        today: '2027-01-01',
      );

      expect(state.currentStreak, 3);
    });

    test('la cadena cruza el 29 de febrero de un año bisiesto', () {
      final state = calc(
        activity: ['2028-02-28', '2028-02-29', '2028-03-01'],
        today: '2028-03-01',
      );

      expect(state.currentStreak, 3);
    });
  });
}
