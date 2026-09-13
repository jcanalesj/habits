import 'package:habits/features/habits/0_entity/habit.dart';
import 'package:habits/features/habits/0_entity/habit_reminder.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

/// Decide qué recordatorios hay que programar. **Dart puro**: sin plugins,
/// sin Firebase y sin reloj propio, así que es trivial de testear.
///
/// Programa ocurrencias concretas (día a día) en vez de una notificación
/// diaria repetida. Es algo más de trabajo, pero permite dos cosas que la
/// repetición no da:
///
///  - **no avisar de lo ya hecho**: si hoy ya registraste el hábito, hoy no
///    suena;
///  - **respetar el objetivo**: si un hábito es "3 veces por semana" y ya
///    van 3, no tiene sentido dar la lata el resto de la semana.
abstract final class ReminderScheduler {
  /// Días por delante que se programan. Se reprograma al abrir la app y con
  /// cada cambio, así que no hace falta mirar muy lejos.
  static const horizonDays = 7;

  /// Tope de notificaciones pendientes.
  ///
  /// iOS descarta silenciosamente lo que pase de 64 por aplicación, así que
  /// se recorta aquí y se conservan las más próximas, que son las que
  /// importan.
  static const maxScheduled = 56;

  /// Recordatorios a programar, ordenados por fecha y hora.
  ///
  /// [completedDays] son los días que ya tienen registro, por hábito: se usa
  /// tanto para saltar hoy como para contar el progreso del periodo.
  /// [isGoalMetOn] responde si el objetivo del periodo al que pertenece ese
  /// día ya está cumplido. Se inyecta para que este servicio no dependa del
  /// calendario ni de zonas horarias; por defecto no filtra nada.
  static List<HabitReminder> schedule({
    required List<Habit> habits,
    required LogicalDate today,
    required Map<String, Set<LogicalDate>> completedDays,
    required int nowMinutes,
    bool Function(Habit habit, LogicalDate day)? isGoalMetOn,
    int horizonDays = horizonDays,
    int maxScheduled = maxScheduled,
  }) {
    final reminders = <HabitReminder>[];

    for (final habit in habits) {
      if (habit.isDeleted) continue;
      final parsed = _parseTime(habit.reminderTime);
      if (parsed == null) continue;
      final (hour, minute) = parsed;
      final done = completedDays[habit.id] ?? const <LogicalDate>{};

      for (var offset = 0; offset < horizonDays; offset++) {
        final day = today.addDays(offset);

        // Ese día ya está registrado: no hay nada que recordar.
        if (done.contains(day)) continue;
        // El objetivo del periodo ya está cumplido (p. ej. 3 de 3 esta
        // semana): seguir avisando sería dar la lata.
        if (isGoalMetOn?.call(habit, day) ?? false) continue;
        // Hoy, si la hora ya pasó, no se programa nada para hoy.
        if (offset == 0 && hour * 60 + minute <= nowMinutes) continue;

        reminders.add(
          HabitReminder(
            habitId: habit.id,
            habitName: habit.name,
            date: day,
            hour: hour,
            minute: minute,
          ),
        );
      }
    }

    reminders.sort();
    return reminders.length <= maxScheduled
        ? reminders
        : reminders.sublist(0, maxScheduled);
  }

  /// "HH:mm" -> (hora, minuto). Null si falta o no es válido.
  static (int, int)? _parseTime(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value);
    if (match == null) return null;
    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }
}
