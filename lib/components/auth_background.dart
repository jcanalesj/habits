import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

/// Fondo a pantalla completa de las pantallas de acceso y del splash.
///
/// Las ilustraciones de `assets/backgrounds/` son lila claro. En el tema
/// claro se pintan tal cual; en el oscuro se pinta el fondo de la paleta y
/// la ilustración queda como una textura tenue encima, de modo que las
/// ondas siguen ahí sin que el texto claro pierda contraste.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final image = Image.asset(asset, fit: BoxFit.cover);
    if (!palette.isDark) return image;
    return ColoredBox(
      color: palette.background,
      child: Opacity(opacity: .14, child: image),
    );
  }
}
