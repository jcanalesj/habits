import 'package:habits/features/habits/0_entity/logical_date.dart';

/// Un recordatorio concreto: qué hábito, qué día y a qué hora.
///
/// Es el resultado del planificador, no configuración. La configuración es
/// `Habit.reminderTime`; esto es una de sus ocurrencias ya resuelta.
class HabitReminder implements Comparable<HabitReminder> {
  const HabitReminder({
    required this.habitId,
    required this.habitName,
    required this.date,
    required this.hour,
    required this.minute,
    this.customMessage,
    this.repeatsDaily = false,
  });

  final String habitId;
  final String habitName;
  final LogicalDate date;
  final int hour;
  final int minute;
  final String? customMessage;

  /// Aviso de respaldo: se repite cada día a esta hora desde [date] hasta
  /// que la app vuelva a sincronizar. Cubre al usuario que deja de abrir la
  /// app, que es justo cuando el recordatorio más importa.
  final bool repeatsDaily;

  /// Id estable y único para el sistema de notificaciones.
  ///
  /// Se deriva del hábito y del día (o de "diario" en el respaldo), así que
  /// reprogramar el mismo recordatorio dos veces no crea duplicados: pisa el
  /// anterior. Usa FNV-1a en vez de `Object.hash`, que cambia entre
  /// ejecuciones, para poder cancelar avisos concretos entre arranques.
  /// Se recorta a 31 bits porque Android exige un int de 32 bits con signo.
  int get notificationId =>
      stableNotificationId('$habitId|${repeatsDaily ? 'daily' : date.key}');

  /// Hash FNV-1a de 32 bits recortado a 31, estable entre ejecuciones.
  static int stableNotificationId(String key) {
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  /// "HH:mm", el mismo formato que guarda `Habit.reminderTime`.
  String get time =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(HabitReminder other) {
    final byDate = date.compareTo(other.date);
    if (byDate != 0) return byDate;
    final byHour = hour.compareTo(other.hour);
    if (byHour != 0) return byHour;
    final byMinute = minute.compareTo(other.minute);
    if (byMinute != 0) return byMinute;
    return habitId.compareTo(other.habitId);
  }

  @override
  bool operator ==(Object other) =>
      other is HabitReminder &&
      other.habitId == habitId &&
      other.date == date &&
      other.hour == hour &&
      other.minute == minute &&
      other.customMessage == customMessage &&
      other.repeatsDaily == repeatsDaily;

  @override
  int get hashCode =>
      Object.hash(habitId, date, hour, minute, customMessage, repeatsDaily);

  @override
  String toString() =>
      'HabitReminder($habitId, ${date.key} $time${repeatsDaily ? ' diario' : ''})';
}
