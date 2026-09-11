/// Un día del calendario (año/mes/día) **sin hora y sin zona horaria**.
///
/// Es el tipo con el que trabaja todo el motor de rachas y de objetivos. Un
/// [LogicalDate] ya está resuelto: la conversión "instante → día" la hace
/// [LogicalCalendar] con la zona IANA del perfil, y a partir de ahí el día
/// es un dato inmutable que no vuelve a reinterpretarse (documento de fase
/// 5, §13: cambiar de zona horaria no reescribe el pasado).
///
/// La aritmética interna usa UTC a propósito: UTC no tiene horario de
/// verano, así que "sumar un día" siempre avanza exactamente un día natural
/// aunque el día real en Europe/Madrid haya durado 23 o 25 horas (§35).
class LogicalDate implements Comparable<LogicalDate> {
  const LogicalDate(this.year, this.month, this.day);

  /// Crea el día a partir de sus componentes normalizándolos (acepta
  /// desbordamientos como mes 13 o día 32).
  factory LogicalDate.normalized(int year, int month, int day) {
    final utc = DateTime.utc(year, month, day);
    return LogicalDate(utc.year, utc.month, utc.day);
  }

  /// Inversa de [key]. Lanza [FormatException] si no es `YYYY-MM-DD` o si
  /// la fecha no existe en el calendario (p. ej. `2026-02-30`).
  factory LogicalDate.parse(String key) {
    final match = _keyPattern.firstMatch(key);
    if (match == null) throw FormatException('Día lógico inválido: $key');
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final utc = DateTime.utc(year, month, day);
    if (utc.year != year || utc.month != month || utc.day != day) {
      throw FormatException('Día lógico inexistente: $key');
    }
    return LogicalDate(year, month, day);
  }

  static LogicalDate? tryParse(String? key) {
    if (key == null) return null;
    try {
      return LogicalDate.parse(key);
    } on FormatException {
      return null;
    }
  }

  static final _keyPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// Clave `YYYY-MM-DD`. Es el formato del campo `dia` en Firestore, del id
  /// de los registros y del id de los días protegidos.
  String get key =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// Instante de medianoche UTC de este día. Solo para aritmética interna y
  /// para comparaciones; no representa un instante real del usuario.
  DateTime get _utc => DateTime.utc(year, month, day);

  /// 1 = lunes … 7 = domingo (igual que [DateTime.weekday]).
  int get weekday => _utc.weekday;

  LogicalDate addDays(int days) {
    final shifted = _utc.add(Duration(days: days));
    return LogicalDate(shifted.year, shifted.month, shifted.day);
  }

  LogicalDate get next => addDays(1);
  LogicalDate get previous => addDays(-1);

  /// Días naturales de diferencia (`other` - `this`).
  int differenceInDays(LogicalDate other) =>
      other._utc.difference(_utc).inDays;

  bool isBefore(LogicalDate other) => compareTo(other) < 0;
  bool isAfter(LogicalDate other) => compareTo(other) > 0;
  bool isAtOrBefore(LogicalDate other) => compareTo(other) <= 0;
  bool isAtOrAfter(LogicalDate other) => compareTo(other) >= 0;

  /// Año y mes como entero monótono (`año * 12 + mes`). Es la unidad con la
  /// que se cuentan los meses transcurridos para la concesión de comodines.
  int get yearMonth => year * 12 + month;

  @override
  int compareTo(LogicalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LogicalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => key;
}
