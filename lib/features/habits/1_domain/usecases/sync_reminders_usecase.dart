import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/repositories/notifications_repository.dart';
import 'package:habits/features/habits/1_domain/services/reminder_scheduler.dart';

/// Textos de la notificación. Se inyectan porque el dominio no conoce la
/// localización.
typedef ReminderCopy = String Function(HabitReminder reminder);

/// Deja las notificaciones del sistema en sintonía con los hábitos.
///
/// Se llama al abrir la app y cada vez que cambia algo que afecte a los
/// recordatorios: crear, editar o borrar un hábito, cambiar su hora, o
/// registrarlo (para no avisar de lo ya hecho).
///
/// Es idempotente: reprogramar con los mismos datos deja el mismo estado.
class SyncRemindersUsecase {
  const SyncRemindersUsecase(this._notifications);

  final NotificationsRepository _notifications;

  /// Devuelve cuántos recordatorios quedaron programados.
  ///
  /// Si el permiso está denegado no programa nada y cancela lo pendiente:
  /// no tiene sentido dejar avisos que el sistema no va a mostrar.
  Future<int> execute({
    required List<Habit> habits,
    required LogicalDate today,
    required int nowMinutes,
    required String timezone,
    required Map<String, Set<LogicalDate>> completedDays,
    required ReminderCopy title,
    required ReminderCopy body,
    bool Function(Habit habit, LogicalDate day)? isGoalMetOn,
    bool enabled = true,
  }) async {
    try {
      if (!enabled) {
        await _notifications.cancelAll();
        return 0;
      }

      final permission = await _notifications.currentPermission();
      if (permission == NotificationPermission.denied) {
        await _notifications.cancelAll();
        return 0;
      }

      final reminders = ReminderScheduler.schedule(
        habits: habits,
        today: today,
        completedDays: completedDays,
        nowMinutes: nowMinutes,
        isGoalMetOn: isGoalMetOn,
      );

      await _notifications.sync(
        reminders,
        timezone: timezone,
        title: title,
        body: body,
      );
      return reminders.length;
    } catch (_) {
      // Los recordatorios son un extra: que fallen no puede impedir usar la
      // app. Se traga el error a propósito.
      return 0;
    }
  }
}
