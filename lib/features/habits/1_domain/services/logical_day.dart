/// Utilidades del "día lógico": cambia a las 00:00 en la zona horaria del
/// dispositivo (decisión cerrada, sección 4.2 del documento funcional).
abstract final class LogicalDay {
  /// Normaliza una fecha a su día lógico (medianoche local).
  static DateTime of(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  static DateTime today() => of(DateTime.now());

  /// Lunes de la semana a la que pertenece [date].
  static DateTime mondayOfWeek(DateTime date) {
    final day = of(date);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
