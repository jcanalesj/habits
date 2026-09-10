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

  /// Domingo de la semana a la que pertenece [date].
  static DateTime sundayOfWeek(DateTime date) =>
      mondayOfWeek(date).add(const Duration(days: 6));

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Clave `YYYY-MM-DD` del día lógico, independiente de zona horaria. Es el
  /// formato del campo `dia` y de los ids de registro en Firestore.
  static String format(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Inversa de [format]. Lanza [FormatException] si no es `YYYY-MM-DD`.
  static DateTime parse(String key) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key);
    if (match == null) throw FormatException('Día lógico inválido: $key');
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
}
