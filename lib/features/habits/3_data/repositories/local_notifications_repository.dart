import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habits/features/habits/0_entity/habit_reminder.dart';
import 'package:habits/features/habits/1_domain/repositories/notifications_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

/// [NotificationsRepository] con `flutter_local_notifications`.
///
/// Programa cada recordatorio en la zona IANA del perfil, la misma que usa
/// el motor de rachas: si el usuario dice "a las 21:00" quiere decir las
/// 21:00 de SU zona, no las del dispositivo.
class LocalNotificationsRepository implements NotificationsRepository {
  LocalNotificationsRepository({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'habit_reminders';
  static const _channelName = 'Recordatorios de hábitos';
  static const _channelDescription =
      'Avisos a la hora que hayas elegido para cada hábito.';

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    initializeTimezones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // El permiso se pide explícitamente desde los ajustes, no al
          // arrancar: pedirlo a bocajarro se deniega mucho más.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<NotificationPermission> currentPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final enabled = await android?.areNotificationsEnabled();
      // Antes de Android 13 no hay permiso que conceder.
      if (enabled == null) return NotificationPermission.notApplicable;
      return enabled
          ? NotificationPermission.granted
          : NotificationPermission.denied;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.checkPermissions();
      if (granted == null) return NotificationPermission.notApplicable;
      return granted.isEnabled
          ? NotificationPermission.granted
          : NotificationPermission.denied;
    }
    return NotificationPermission.notApplicable;
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      if (granted == null) return NotificationPermission.notApplicable;
      return granted
          ? NotificationPermission.granted
          : NotificationPermission.denied;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted == null) return NotificationPermission.notApplicable;
      return granted
          ? NotificationPermission.granted
          : NotificationPermission.denied;
    }
    return NotificationPermission.notApplicable;
  }

  @override
  Future<void> sync(
    List<HabitReminder> reminders, {
    required String timezone,
    required String Function(HabitReminder reminder) title,
    required String Function(HabitReminder reminder) body,
  }) async {
    await initialize();
    // Cancelar y reprogramar entero: mucho más simple de razonar que
    // calcular diferencias, y son unas pocas decenas de avisos.
    await _plugin.cancelAll();

    // El calendario ya sabe resolver "esta hora en la zona del perfil", y
    // degrada a UTC si la zona guardada es inválida.
    final calendar = LogicalCalendar(timezone);
    final nowInZone = tz.TZDateTime.now(
      TimezoneDatabase.locationOf(timezone),
    );

    for (final reminder in reminders) {
      final when = calendar.instantAt(
        reminder.date,
        reminder.hour,
        reminder.minute,
      );
      // Defensa: el planificador ya descarta el pasado, pero programar algo
      // anterior a "ahora" dispararía el aviso al instante.
      if (!when.isAfter(nowInZone)) continue;

      await _plugin.zonedSchedule(
        id: reminder.notificationId,
        title: title(reminder),
        body: body(reminder),
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Inexacto a propósito: las alarmas exactas exigen un permiso
        // especial en Android 12+ que Google Play restringe a relojes y
        // calendarios. Para un recordatorio de hábito, unos minutos de
        // margen son irrelevantes y evitan pedir ese permiso.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.habitId,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  @override
  Future<int> pendingCount() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }
}
