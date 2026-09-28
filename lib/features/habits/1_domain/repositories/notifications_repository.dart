import 'package:habits/features/habits/0_entity/habit_reminder.dart';
import 'package:habits/features/habits/0_entity/scheduled_notification.dart';

/// Permiso del sistema para mostrar notificaciones.
enum NotificationPermission {
  /// Concedido: se pueden mostrar recordatorios.
  granted,

  /// Denegado por el usuario. La app debe explicarlo, no insistir.
  denied,

  /// La plataforma no expone permiso (p. ej. Android < 13): se asume que sí.
  notApplicable,
}

/// Notificaciones locales de recordatorio.
///
/// Son LOCALES a propósito: no necesitan backend, ni Blaze, ni push. El
/// dispositivo se encarga de despertar a la hora indicada aunque la app esté
/// cerrada.
abstract class NotificationsRepository {
  /// Prepara el plugin. Idempotente.
  Future<void> initialize();

  Future<NotificationPermission> currentPermission();

  /// Pide permiso al usuario. En iOS abre el diálogo del sistema; en Android
  /// 13+ el de POST_NOTIFICATIONS.
  Future<NotificationPermission> requestPermission();

  /// Sustituye TODOS los recordatorios pendientes por [reminders].
  ///
  /// Es un "sync", no un "add": cancelar lo anterior y programar lo nuevo en
  /// una sola operación evita duplicados y recordatorios huérfanos de
  /// hábitos ya borrados o con la hora cambiada.
  Future<void> sync(
    List<HabitReminder> reminders, {
    required String timezone,
    required String Function(HabitReminder reminder) title,
    required String Function(HabitReminder reminder) body,
  });

  /// Cancela solo los recordatorios de hábitos (los de las herramientas se
  /// conservan). Se usa al desactivar los recordatorios o sin permiso.
  Future<void> cancelHabitReminders();

  /// Cancela absolutamente todo. Se usa al cerrar sesión.
  Future<void> cancelAll();

  /// Sustituye las notificaciones de la herramienta [tag] (tareas,
  /// pomodoro…) por [notifications]. Mismo criterio que [sync]: cancelar y
  /// reprogramar en bloque, sin tocar las de otras herramientas ni las de
  /// hábitos.
  Future<void> syncTagged(String tag, List<ScheduledNotification> notifications);

  /// Cancela todas las notificaciones de la herramienta [tag].
  Future<void> cancelTagged(String tag);

  /// Recordatorios realmente pendientes en el sistema. Para diagnóstico.
  Future<int> pendingCount();
}
