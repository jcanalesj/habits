import 'package:flutter/services.dart';
import 'package:habits/features/steps/1_domain/domain.dart';

/// [StepsLiveNotification] sobre el canal `constanza/steps_notification`
/// de `MainActivity.kt`. Donde no existe el canal (iOS, web, escritorio)
/// responde "no soportado" sin fallar.
class PlatformStepsLiveNotification implements StepsLiveNotification {
  PlatformStepsLiveNotification({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('constanza/steps_notification');

  final MethodChannel _channel;

  @override
  Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> isEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isEnabled') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<StepsLiveNotificationResult> start(
    StepsLiveNotificationConfig config,
  ) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'start',
        config.toMap(),
      );
      return switch (result) {
        'started' => StepsLiveNotificationResult.started,
        'notifications_denied' =>
          StepsLiveNotificationResult.notificationsDenied,
        'activity_denied' => StepsLiveNotificationResult.activityDenied,
        _ => StepsLiveNotificationResult.unsupported,
      };
    } on MissingPluginException {
      return StepsLiveNotificationResult.unsupported;
    }
  }

  @override
  Future<void> update(StepsLiveNotificationConfig config) async {
    try {
      await _channel.invokeMethod<String>('update', config.toMap());
    } on MissingPluginException {
      // Sin canal no hay notificación que actualizar.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Nada que parar.
    }
  }
}
