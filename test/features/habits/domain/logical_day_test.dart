import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';

void main() {
  group('LogicalDay', () {
    test('normaliza cualquier hora a la medianoche local', () {
      final date = DateTime(2026, 8, 26, 23, 59, 58);
      expect(LogicalDay.of(date), DateTime(2026, 8, 26));
    });

    test('calcula el lunes de la semana de una fecha', () {
      // 26/08/2026 es miércoles; su lunes es el 24/08.
      expect(
        LogicalDay.mondayOfWeek(DateTime(2026, 8, 26)),
        DateTime(2026, 8, 24),
      );
      // Un lunes es su propio inicio de semana.
      expect(
        LogicalDay.mondayOfWeek(DateTime(2026, 8, 24)),
        DateTime(2026, 8, 24),
      );
      // Un domingo pertenece a la semana que empezó 6 días antes.
      expect(
        LogicalDay.mondayOfWeek(DateTime(2026, 8, 30)),
        DateTime(2026, 8, 24),
      );
    });
    test('format y parse son inversos y usan YYYY-MM-DD', () {
      final date = DateTime(2026, 1, 5, 23, 59);
      expect(LogicalDay.format(date), '2026-01-05');
      expect(LogicalDay.parse('2026-01-05'), DateTime(2026, 1, 5));
      expect(() => LogicalDay.parse('05/01/2026'), throwsFormatException);
    });

    test('sundayOfWeek es seis días después del lunes', () {
      final wednesday = DateTime(2026, 9, 9);
      expect(LogicalDay.mondayOfWeek(wednesday), DateTime(2026, 9, 7));
      expect(LogicalDay.sundayOfWeek(wednesday), DateTime(2026, 9, 13));
    });
  });
}
