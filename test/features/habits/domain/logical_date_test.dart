import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';

void main() {
  group('LogicalDate — clave y parseo', () {
    test('key usa el formato YYYY-MM-DD con relleno', () {
      expect(const LogicalDate(2026, 9, 4).key, '2026-09-04');
      expect(const LogicalDate(2026, 12, 31).key, '2026-12-31');
    });

    test('parse es la inversa de key', () {
      const date = LogicalDate(2026, 2, 28);
      expect(LogicalDate.parse(date.key), date);
    });

    test('rechaza formatos inválidos', () {
      expect(() => LogicalDate.parse('2026-9-4'), throwsFormatException);
      expect(() => LogicalDate.parse('hoy'), throwsFormatException);
    });

    test('rechaza fechas inexistentes del calendario', () {
      // 2026 no es bisiesto: el 30 de febrero no existe y no debe colarse
      // normalizado al 2 de marzo.
      expect(() => LogicalDate.parse('2026-02-30'), throwsFormatException);
      expect(() => LogicalDate.parse('2026-13-01'), throwsFormatException);
      expect(() => LogicalDate.parse('2026-02-29'), throwsFormatException);
    });

    test('tryParse devuelve null en lugar de lanzar', () {
      expect(LogicalDate.tryParse(null), isNull);
      expect(LogicalDate.tryParse('2026-02-30'), isNull);
      expect(LogicalDate.tryParse('2026-09-11'), const LogicalDate(2026, 9, 11));
    });
  });

  group('LogicalDate — aritmética de días', () {
    test('addDays cruza el cambio de mes', () {
      expect(const LogicalDate(2026, 8, 31).next, const LogicalDate(2026, 9, 1));
      expect(
        const LogicalDate(2026, 9, 1).previous,
        const LogicalDate(2026, 8, 31),
      );
    });

    test('addDays cruza el cambio de año', () {
      expect(
        const LogicalDate(2026, 12, 31).next,
        const LogicalDate(2027, 1, 1),
      );
    });

    test('addDays respeta los años bisiestos', () {
      expect(
        const LogicalDate(2028, 2, 28).next,
        const LogicalDate(2028, 2, 29),
      );
      expect(
        const LogicalDate(2026, 2, 28).next,
        const LogicalDate(2026, 3, 1),
      );
    });

    test('la aritmética no se descuadra en un cambio de horario', () {
      // 29 de marzo de 2026: en Europe/Madrid ese día dura 23 horas. Como la
      // aritmética es de calendario y no de duraciones, sumar un día sigue
      // avanzando exactamente un día.
      const dstDay = LogicalDate(2026, 3, 29);
      expect(dstDay.previous, const LogicalDate(2026, 3, 28));
      expect(dstDay.next, const LogicalDate(2026, 3, 30));
      expect(const LogicalDate(2026, 3, 28).differenceInDays(dstDay), 1);

      // 25 de octubre de 2026: ese día dura 25 horas.
      const dstBack = LogicalDate(2026, 10, 25);
      expect(dstBack.previous, const LogicalDate(2026, 10, 24));
      expect(dstBack.next, const LogicalDate(2026, 10, 26));
    });

    test('differenceInDays cuenta días naturales', () {
      expect(
        const LogicalDate(2026, 9, 1).differenceInDays(
          const LogicalDate(2026, 9, 11),
        ),
        10,
      );
    });
  });

  group('LogicalDate — comparación y yearMonth', () {
    test('ordena cronológicamente', () {
      final dates = [
        const LogicalDate(2026, 9, 11),
        const LogicalDate(2025, 12, 31),
        const LogicalDate(2026, 1, 1),
      ]..sort();

      expect(dates.map((d) => d.key).toList(), [
        '2025-12-31',
        '2026-01-01',
        '2026-09-11',
      ]);
    });

    test('igualdad por valor', () {
      expect(const LogicalDate(2026, 9, 11), const LogicalDate(2026, 9, 11));
      // Dos instancias con el mismo valor colapsan en un conjunto: es lo
      // que hace que el motor pueda tratar los días como Set.
      final repetidos = [
        const LogicalDate(2026, 9, 11),
        LogicalDate.parse('2026-09-11'),
      ];
      expect(repetidos.toSet().length, 1);
    });

    test('yearMonth es monótono y avanza de uno en uno', () {
      const dic = LogicalDate(2026, 12, 1);
      const ene = LogicalDate(2027, 1, 1);
      expect(ene.yearMonth - dic.yearMonth, 1);
    });
  });
}
