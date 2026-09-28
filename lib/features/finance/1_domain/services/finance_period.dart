import 'package:habits/features/habits/0_entity/logical_date.dart';

/// El "mes" del usuario: empieza el día [startDay] y termina el día
/// anterior del mes siguiente. Con [startDay] = 1 coincide con el mes
/// natural. La clave `YYYY-MM` es la del mes en que EMPIEZA el periodo.
class FinancePeriod {
  const FinancePeriod({required this.start, required this.end});

  final LogicalDate start;
  final LogicalDate end;

  /// Periodo que contiene [date].
  factory FinancePeriod.containing(LogicalDate date, {required int startDay}) {
    final day = startDay.clamp(1, 28);
    final start = date.day >= day
        ? LogicalDate(date.year, date.month, day)
        : LogicalDate.normalized(date.year, date.month - 1, day);
    return FinancePeriod(
      start: start,
      end: LogicalDate.normalized(start.year, start.month + 1, day).previous,
    );
  }

  /// Periodo desplazado [months] meses (negativo hacia atrás).
  FinancePeriod shift(int months) => FinancePeriod(
    start: LogicalDate.normalized(start.year, start.month + months, start.day),
    end: LogicalDate.normalized(
      start.year,
      start.month + months + 1,
      start.day,
    ).previous,
  );

  /// `YYYY-MM` del mes en que empieza. Es la clave de `registradoMeses`.
  String get key =>
      '${start.year.toString().padLeft(4, '0')}-'
      '${start.month.toString().padLeft(2, '0')}';

  bool contains(LogicalDate date) =>
      date.isAtOrAfter(start) && date.isAtOrBefore(end);

  /// Día de este periodo en el que "cae" un gasto fijo con [dayOfMonth].
  LogicalDate dayFor(int dayOfMonth) {
    final inStartMonth = LogicalDate(start.year, start.month, dayOfMonth);
    if (inStartMonth.isAtOrAfter(start)) return inStartMonth;
    return LogicalDate.normalized(start.year, start.month + 1, dayOfMonth);
  }

  @override
  bool operator ==(Object other) =>
      other is FinancePeriod && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}
