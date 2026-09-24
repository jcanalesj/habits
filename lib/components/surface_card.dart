import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

/// Tarjeta blanca redondeada con sombra suave, contenedor base de
/// formularios y secciones destacadas.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: palette.isDark ? 1 : 0.92),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
