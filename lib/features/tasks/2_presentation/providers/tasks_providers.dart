import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/1_domain/domain.dart';
// Capa de inyección de dependencias: único punto autorizado a importar 3_data.
import 'package:habits/features/tasks/3_data/data.dart';

final tasksRepositoryProvider = Provider.autoDispose<TasksRepository>((ref) {
  final userId = ref.read(authControllerProvider).value?.id ?? 'anonymous';
  return FirestoreTasksRepository(userId: userId);
});

/// Tareas sin completar, de cualquier día y sin fecha.
final pendingTasksProvider = StreamProvider.autoDispose<List<TaskItem>>(
  (ref) => ref.watch(tasksRepositoryProvider).watchPending(),
);

final tasksByDayProvider = StreamProvider.autoDispose
    .family<List<TaskItem>, LogicalDate>(
      (ref, day) => ref.watch(tasksRepositoryProvider).watchByDay(day),
    );

final undatedTasksProvider = StreamProvider.autoDispose<List<TaskItem>>(
  (ref) => ref.watch(tasksRepositoryProvider).watchUndated(),
);

/// Pendientes de días anteriores a hoy: candidatas al arrastre.
final overdueTasksProvider = Provider.autoDispose<List<TaskItem>>((ref) {
  final today = ref.watch(todayProvider);
  final pending = ref.watch(pendingTasksProvider).value ?? const [];
  return [
    for (final task in pending)
      if (task.date case final date? when date.isBefore(today)) task,
  ];
});

/// Pendientes de hoy (para el dato vivo del panel y la tira de días).
final todayPendingTasksCountProvider = Provider.autoDispose<int?>((ref) {
  final today = ref.watch(todayProvider);
  final pending = ref.watch(pendingTasksProvider);
  if (!pending.hasValue) return null;
  return pending.value!.where((task) => task.date == today).length;
});

/// Programa una notificación local por cada tarea pendiente con fecha y
/// hora. Es un "sync": sustituye todas las de tareas por las actuales.
final taskReminderSyncerProvider = Provider<TaskReminderSyncer>(
  (ref) => TaskReminderSyncer(ref.watch(notificationsRepositoryProvider)),
);

class TaskReminderSyncer {
  TaskReminderSyncer(this._notifications);

  final NotificationsRepository _notifications;

  static const tag = 'task';

  Future<void> sync(
    List<TaskItem> pending, {
    required LogicalCalendar calendar,
    required String title,
  }) async {
    try {
      final permission = await _notifications.currentPermission();
      if (permission == NotificationPermission.denied) {
        await _notifications.cancelTagged(tag);
        return;
      }
      final notifications = <ScheduledNotification>[];
      for (final task in pending) {
        final date = task.date;
        final parts = task.timeParts;
        if (date == null || parts == null) continue;
        notifications.add(
          ScheduledNotification(
            id: HabitReminder.stableNotificationId('task|${task.id}'),
            title: title,
            body: task.title,
            whenUtc: calendar.instantAt(date, parts.$1, parts.$2).toUtc(),
            payload: task.id,
          ),
        );
      }
      await _notifications.syncTagged(tag, notifications);
    } catch (_) {
      // Los avisos son un extra: que fallen no impide usar las tareas.
    }
  }
}

/// Clave local: último día en que se ofreció el arrastre a este usuario.
String tasksRolloverAskedKey(String userId) => 'tasks_rollover_asked_$userId';
