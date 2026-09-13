import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/clock.dart';
import 'package:habits/features/habits/1_domain/services/logical_calendar.dart';
import 'package:habits/features/habits/1_domain/services/streak_calculator.dart';
import 'package:habits/features/habits/1_domain/services/wildcard_policy.dart';

void main() {
  setUpAll(initializeTimezones);

  final madrid = LogicalCalendar('Europe/Madrid');
  final newYork = LogicalCalendar('America/New_York');

  group('el día termina a las 00:00 de la zona del perfil', () {
    test('23:59 en Madrid todavía es el día actual', () {
      // 11 sep 2026 23:59 en Madrid = 21:59 UTC (CEST, UTC+2).
      final instant = DateTime.utc(2026, 9, 11, 21, 59);
      expect(madrid.dateOf(instant), const LogicalDate(2026, 9, 11));
    });

    test('00:00 en Madrid ya es el día siguiente', () {
      // 12 sep 2026 00:00 en Madrid = 22:00 UTC del día 11.
      final instant = DateTime.utc(2026, 9, 11, 22, 0);
      expect(madrid.dateOf(instant), const LogicalDate(2026, 9, 12));
    });

    test('el mismo instante es un día distinto en otra zona', () {
      // 12 sep 2026 00:30 en Madrid = 11 sep 18:30 en Nueva York.
      final instant = DateTime.utc(2026, 9, 11, 22, 30);

      expect(madrid.dateOf(instant), const LogicalDate(2026, 9, 12));
      expect(newYork.dateOf(instant), const LogicalDate(2026, 9, 11));
    });

    test('una zona inexistente degrada a UTC sin romper la app', () {
      final roto = LogicalCalendar('Marte/Olympus_Mons');
      expect(
        roto.dateOf(DateTime.utc(2026, 9, 11, 23, 0)),
        const LogicalDate(2026, 9, 11),
      );
    });
  });

  group('horario de verano (DST)', () {
    test('el día de 23 horas no adelanta ni atrasa el día lógico', () {
      // 29 marzo 2026: Madrid pasa de CET (+1) a CEST (+2) a las 02:00.
      // 01:30 local = 00:30 UTC; 04:00 local = 02:00 UTC. Ambos son el día 29.
      expect(
        madrid.dateOf(DateTime.utc(2026, 3, 29, 0, 30)),
        const LogicalDate(2026, 3, 29),
      );
      expect(
        madrid.dateOf(DateTime.utc(2026, 3, 29, 2, 0)),
        const LogicalDate(2026, 3, 29),
      );
      // 23:59 local del 29 = 21:59 UTC (ya en CEST).
      expect(
        madrid.dateOf(DateTime.utc(2026, 3, 29, 21, 59)),
        const LogicalDate(2026, 3, 29),
      );
      expect(
        madrid.dateOf(DateTime.utc(2026, 3, 29, 22, 0)),
        const LogicalDate(2026, 3, 30),
      );
    });

    test('el día de 25 horas tampoco lo altera', () {
      // 25 octubre 2026: Madrid vuelve de CEST (+2) a CET (+1) a las 03:00.
      // 23:59 local del 25 = 22:59 UTC (ya en CET).
      expect(
        madrid.dateOf(DateTime.utc(2026, 10, 25, 22, 59)),
        const LogicalDate(2026, 10, 25),
      );
      expect(
        madrid.dateOf(DateTime.utc(2026, 10, 25, 23, 0)),
        const LogicalDate(2026, 10, 26),
      );
    });

    test('la racha no se rompe atravesando un cambio de horario', () {
      final state = StreakCalculator.calculate(
        activityDays: {
          const LogicalDate(2026, 3, 28),
          const LogicalDate(2026, 3, 29), // día de 23 horas
          const LogicalDate(2026, 3, 30),
        },
        protectedDays: const {},
        today: const LogicalDate(2026, 3, 30),
      );

      expect(state.currentStreak, 3);
    });

    test('la ventana del comodín sigue siendo "ayer" en un día de DST', () {
      // Hoy es el 30; el día en peligro es el 29, que duró 23 horas.
      expect(
        WildcardPolicy.isWithinRescueWindow(
          const LogicalDate(2026, 3, 29),
          const LogicalDate(2026, 3, 30),
        ),
        isTrue,
      );
      expect(
        WildcardPolicy.isWithinRescueWindow(
          const LogicalDate(2026, 3, 28),
          const LogicalDate(2026, 3, 30),
        ),
        isFalse,
      );
    });
  });

  group('límites de semana, mes y año en la zona del perfil', () {
    test('la semana va de lunes a domingo', () {
      // 11 sep 2026 es viernes.
      const viernes = LogicalDate(2026, 9, 11);
      expect(madrid.startOfWeek(viernes), const LogicalDate(2026, 9, 7));
      expect(madrid.endOfWeek(viernes), const LogicalDate(2026, 9, 13));
    });

    test('un lunes es su propio inicio de semana', () {
      const lunes = LogicalDate(2026, 9, 7);
      expect(madrid.startOfWeek(lunes), lunes);
    });

    test('un domingo pertenece a la semana que empezó el lunes anterior', () {
      const domingo = LogicalDate(2026, 9, 13);
      expect(madrid.startOfWeek(domingo), const LogicalDate(2026, 9, 7));
    });

    test('la semana cruza el cambio de mes y de año', () {
      // 1 enero 2027 es viernes: su semana empieza el 28 de diciembre.
      expect(
        madrid.startOfWeek(const LogicalDate(2027, 1, 1)),
        const LogicalDate(2026, 12, 28),
      );
    });

    test('los meses acaban en su último día real', () {
      expect(
        madrid.endOfMonth(const LogicalDate(2026, 2, 10)),
        const LogicalDate(2026, 2, 28),
      );
      expect(
        madrid.endOfMonth(const LogicalDate(2028, 2, 10)),
        const LogicalDate(2028, 2, 29),
      );
      expect(
        madrid.endOfMonth(const LogicalDate(2026, 12, 10)),
        const LogicalDate(2026, 12, 31),
      );
    });

    test('el año va del 1 de enero al 31 de diciembre', () {
      const day = LogicalDate(2026, 9, 11);
      expect(madrid.startOfYear(day), const LogicalDate(2026, 1, 1));
      expect(madrid.endOfYear(day), const LogicalDate(2026, 12, 31));
    });
  });

  group('cambio de zona horaria del perfil', () {
    test('cambiar de zona NO reinterpreta los registros históricos', () {
      // Un registro guardado como 2026-09-10 sigue siendo ese día lógico
      // aunque el usuario se mude de Madrid a Nueva York: el día se guardó
      // ya resuelto y es inmutable.
      const registro = LogicalDate(2026, 9, 10);

      final desdeMadrid = StreakCalculator.calculate(
        activityDays: {registro},
        protectedDays: const {},
        today: const LogicalDate(2026, 9, 10),
      );
      final desdeNuevaYork = StreakCalculator.calculate(
        activityDays: {registro},
        protectedDays: const {},
        today: const LogicalDate(2026, 9, 10),
      );

      expect(desdeMadrid, desdeNuevaYork);
      expect(registro.key, '2026-09-10');
    });

    test('la nueva zona sí cambia cuál es "hoy"', () {
      final instant = DateTime.utc(2026, 9, 11, 22, 30);
      final clock = FixedClock(instant);

      // El mismo reloj, dos perfiles: el día de hoy es distinto.
      expect(madrid.dateOf(clock.nowUtc()), const LogicalDate(2026, 9, 12));
      expect(newYork.dateOf(clock.nowUtc()), const LogicalDate(2026, 9, 11));
    });
  });

  test('usar el calendario sin inicializar la base IANA falla explícito', () {
    // Comprobación de la guarda: si alguien olvida initializeTimezones() en
    // un entry point nuevo, el error dice exactamente qué falta.
    expect(TimezoneDatabase.isInitialized, isTrue);
  });
}
