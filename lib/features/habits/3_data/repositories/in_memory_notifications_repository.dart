import 'package:habits/features/habits/0_entity/habit_reminder.dart';
import 'package:habits/features/habits/1_domain/repositories/notifications_repository.dart';

/// [NotificationsRepository] en memoria para tests: registra qué se ha
/// programado y permite simular el permiso del sistema.
class InMemoryNotificationsRepository implements NotificationsRepository {
  InMemoryNotificationsRepository({
    this.permission = NotificationPermission.granted,
  });

  NotificationPermission permission;

  /// Lo último que se programó (vacío tras `cancelAll`).
  List<HabitReminder> scheduled = const [];
  String? lastTimezone;
  int syncCalls = 0;
  int cancelAllCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermission> currentPermission() async => permission;

  @override
  Future<NotificationPermission> requestPermission() async => permission;

  @override
  Future<void> sync(
    List<HabitReminder> reminders, {
    required String timezone,
    required String Function(HabitReminder reminder) title,
    required String Function(HabitReminder reminder) body,
  }) async {
    syncCalls++;
    scheduled = List.unmodifiable(reminders);
    lastTimezone = timezone;
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled = const [];
  }

  @override
  Future<int> pendingCount() async => scheduled.length;
}
