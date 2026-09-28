import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

/// Decoración base de las tarjetas de contenido: superficie ligeramente
/// translúcida en claro (opaca en oscuro), borde suave y radio 22.
///
/// Es la misma que usan las pantallas de peso y perfil; vive aquí para que
/// todas las herramientas la compartan en vez de copiarla.
BoxDecoration surfaceDecoration(
  AppPalette palette, {
  double radius = 22,
  double lightAlpha = .86,
}) => BoxDecoration(
  color: palette.surface.withValues(alpha: palette.isDark ? 1 : lightAlpha),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: palette.border),
);
