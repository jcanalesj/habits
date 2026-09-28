import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/widgets.dart' show Color, IconData;

/// Identificador estable de cada herramienta. Se usa en rutas, analítica y
/// preferencias locales, así que no se renombra.
enum ToolId { tasks, pomodoro, shopping, finance, steps }

/// Registro de una herramienta: lo que el panel necesita para pintar su
/// tarjeta y abrirla. Cada herramienta es una feature propia; el panel solo
/// conoce esta descripción.
final class ToolDescriptor {
  const ToolDescriptor({
    required this.id,
    required this.route,
    required this.icon,
    required this.accent,
    this.platforms,
    this.premium = true,
  });

  final ToolId id;
  final String route;
  final IconData icon;
  final Color accent;

  /// Plataformas donde existe. `null` = todas.
  final Set<TargetPlatform>? platforms;

  /// Toda la sección es Premium; el acceso libre actual lo desactiva en
  /// tiempo de ejecución sin tocar esta declaración.
  final bool premium;

  bool availableOn(TargetPlatform platform, {required bool isWeb}) {
    if (platforms == null) return true;
    if (isWeb) return false;
    return platforms!.contains(platform);
  }
}
