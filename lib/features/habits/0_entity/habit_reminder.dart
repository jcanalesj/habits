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
  });

  final String habitId;
  final String habitName;
  final LogicalDate date;
  final int hour;
  final int minute;
  final String? customMessage;

  /// Id estable y único para el sistema de notificaciones.
  ///
  /// Se deriva del hábito y del día, así que reprogramar el mismo
  /// recordatorio dos veces no crea duplicados: pisa el anterior.
  /// Se recorta a 31 bits porque Android exige un int de 32 bits con signo.
  int get notificationId => Object.hash(habitId, date.key) & 0x7fffffff;

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
      other.customMessage == customMessage;

  @override
  int get hashCode => Object.hash(habitId, date, hour, minute, customMessage);

  @override
  String toString() => 'HabitReminder($habitId, ${date.key} $time)';
}
