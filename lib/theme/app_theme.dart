import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta base de la app, tomada del visual de referencia
/// (documentation/visuals/image.png).
abstract final class AppColors {
  static const background = Color(0xFFF3F1FB);
  static const surface = Colors.white;

  static const primary = Color(0xFF7C5CE0);
  static const primaryDeep = Color(0xFF6D28D9);
  static const gradientStart = Color(0xFFA78BFA);
  static const gradientEnd = Color(0xFF7C3AED);

  static const textPrimary = Color(0xFF231E38);
  static const textSecondary = Color(0xFF6E6A82);

  // Colores semánticos de autenticación.
  static const authHeading = Color(0xFF1D1766);
  static const authBrand = Color(0xFF352A6E);
  static const authSecondary = Color(0xFF7373A7);
  static const authFieldLabel = Color(0xFF211A69);
  static const authFieldHint = Color(0xFF8584BA);
  static const authLegalText = Color(0xFF65659B);
  static const authPromptText = Color(0xFF6F6EA1);

  static const flame = Color(0xFFFF9F43);

  // Colores de ámbitos / hábitos (paleta asignable).
  static const lilac = Color(0xFF8B5CF6);
  static const pink = Color(0xFFF16A8F);
  static const green = Color(0xFF34B379);
  static const orange = Color(0xFFF59E0B);
  static const blue = Color(0xFF38BDF8);
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
