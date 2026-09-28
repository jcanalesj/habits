import 'package:flutter/services.dart';

/// Respuesta háptica propia de Constanza.
///
/// El canal nativo evita que algunos dispositivos ignoren los impactos
/// genéricos de Flutter. Si no está disponible (web, tests o una instalación
/// antigua), se conserva el comportamiento estándar como respaldo.
abstract final class AppHaptics {
  static const _channel = MethodChannel('constanza/haptics');

  static Future<void> habitCompleted() async {
    try {
      await _channel.invokeMethod<void>('habitCompleted');
    } on PlatformException {
      await HapticFeedback.vibrate();
    } on MissingPluginException {
      await HapticFeedback.vibrate();
    }
  }

  static Future<void> stepsGoalCompleted() async {
    try {
      await _channel.invokeMethod<void>('stepsGoalCompleted');
    } on PlatformException {
      await HapticFeedback.vibrate();
    } on MissingPluginException {
      await HapticFeedback.vibrate();
    }
  }
}
