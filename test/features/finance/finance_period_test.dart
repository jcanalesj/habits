import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/finance/1_domain/domain.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

void main() {
  test('con día 1 el periodo es el mes natural', () {
    final period = FinancePeriod.containing(
      const LogicalDate(2026, 9, 11),
      startDay: 1,
    );
    expect(period.start, const LogicalDate(2026, 9, 1));
    expect(period.end, const LogicalDate(2026, 9, 30));
    expect(period.key, '2026-09');
  });

  test('con día 25 el periodo cruza el cambio de mes', () {
    final before = FinancePeriod.containing(
      const LogicalDate(2026, 9, 11),
      startDay: 25,
    );
    expect(before.start, const LogicalDate(2026, 8, 25));
    expect(before.end, const LogicalDate(2026, 9, 24));
    expect(before.key, '2026-08');

    final after = FinancePeriod.containing(
      const LogicalDate(2026, 9, 26),
      startDay: 25,
    );
    expect(after.start, const LogicalDate(2026, 9, 25));
    expect(after.end, const LogicalDate(2026, 10, 24));
  });

  test('desplazar meses y día de un fijo dentro del periodo', () {
    final period = FinancePeriod.containing(
      const LogicalDate(2026, 1, 15),
      startDay: 10,
    );
    final previous = period.shift(-1);
    expect(previous.start, const LogicalDate(2025, 12, 10));
    expect(previous.end, const LogicalDate(2026, 1, 9));
    // Un fijo del día 5 cae en el segundo mes del periodo.
    expect(period.dayFor(5), const LogicalDate(2026, 2, 5));
    expect(period.dayFor(20), const LogicalDate(2026, 1, 20));
    expect(period.contains(const LogicalDate(2026, 2, 9)), isTrue);
    expect(period.contains(const LogicalDate(2026, 2, 10)), isFalse);
  });
}
