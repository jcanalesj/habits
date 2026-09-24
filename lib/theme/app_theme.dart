import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores de marca de Constanza. Son los mismos en el tema claro y en el
/// oscuro: identidad, degradados y la paleta asignable a ámbitos y hábitos.
///
/// Todo lo que cambia con el tema (fondos, superficies, textos, bordes…)
/// vive en [AppPalette] y se lee con `context.palette`.
abstract final class AppColors {
  static const primary = Color(0xFF7C5CE0);
  static const primaryDeep = Color(0xFF6D28D9);
  static const gradientStart = Color(0xFFA78BFA);
  static const gradientEnd = Color(0xFF7C3AED);

  static const flame = Color(0xFFFF9F43);

  // Colores de ámbitos / hábitos (paleta asignable). Se guardan en Firestore
  // como enteros, así que no pueden depender del tema.
  static const lilac = Color(0xFF8B5CF6);
  static const pink = Color(0xFFF16A8F);
  static const green = Color(0xFF34B379);
  static const orange = Color(0xFFF59E0B);
  static const blue = Color(0xFF38BDF8);
}

/// Paleta semántica dependiente del tema. Se registra como
/// [ThemeExtension] en [AppTheme.light] y [AppTheme.dark] y se lee con
/// `context.palette`.
///
/// Los nombres describen el uso, no el color, para que un mismo widget quede
/// coherente en ambos temas sin condicionales.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceElevated,
    required this.dialogSurface,
    required this.border,
    required this.divider,
    required this.shadow,
    required this.scrim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.primary,
    required this.primaryDeep,
    required this.primarySoft,
    required this.onPrimary,
    required this.inputFill,
    required this.authHeading,
    required this.authBrand,
    required this.authSecondary,
    required this.authFieldLabel,
    required this.authFieldHint,
    required this.authLegalText,
    required this.authPromptText,
  });

  /// Tema claro: la paleta original de Constanza
  /// (documentation/visuals/home.png).
  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF3F1FB),
    surface: Colors.white,
    surfaceMuted: Color(0xFFF7F5FC),
    surfaceElevated: Colors.white,
    dialogSurface: Color(0xFFFCFAFF),
    border: Colors.white,
    divider: Color(0xFFECE8F5),
    shadow: Color(0x24705AC8),
    scrim: Color(0x94231E38),
    textPrimary: Color(0xFF231E38),
    textSecondary: Color(0xFF6E6A82),
    textHint: Color(0xFF9B97AE),
    primary: Color(0xFF7C5CE0),
    primaryDeep: Color(0xFF6D28D9),
    primarySoft: Color(0xFFF0EAFF),
    onPrimary: Colors.white,
    inputFill: Color(0x0E7C5CE0),
    authHeading: Color(0xFF1D1766),
    authBrand: Color(0xFF352A6E),
    authSecondary: Color(0xFF7373A7),
    authFieldLabel: Color(0xFF211A69),
    authFieldHint: Color(0xFF8584BA),
    authLegalText: Color(0xFF65659B),
    authPromptText: Color(0xFF6F6EA1),
  );

  /// Tema oscuro: negro-violeta profundo en lugar de negro puro para
  /// conservar la identidad lila; superficies en capas cada vez más claras
  /// y un primario algo más luminoso para que el texto y los iconos
  /// mantengan contraste sobre fondo oscuro.
  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF100C1B),
    surface: Color(0xFF1C1530),
    surfaceMuted: Color(0xFF291F46),
    surfaceElevated: Color(0xFF302252),
    dialogSurface: Color(0xFF24183D),
    border: Color(0xFF443266),
    divider: Color(0xFF392951),
    shadow: Color(0x66000000),
    scrim: Color(0xB8000000),
    textPrimary: Color(0xFFF8F4FF),
    textSecondary: Color(0xFFBBB0D8),
    textHint: Color(0xFF9184B5),
    primary: Color(0xFFB794FF),
    primaryDeep: Color(0xFFD4C2FF),
    primarySoft: Color(0xFF412C70),
    onPrimary: Colors.white,
    inputFill: Color(0x1AA18BF5),
    authHeading: Color(0xFFEEEAFF),
    authBrand: Color(0xFFD9D0FF),
    authSecondary: Color(0xFFA8A2C4),
    authFieldLabel: Color(0xFFE2DCFF),
    authFieldHint: Color(0xFF8A85B3),
    authLegalText: Color(0xFF9D97C2),
    authPromptText: Color(0xFFA8A2C4),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  final Brightness brightness;

  /// Fondo de las pantallas.
  final Color background;

  /// Tarjetas y tiles sobre [background].
  final Color surface;

  /// Relleno de chips, celdas secundarias y bloques dentro de una tarjeta.
  final Color surfaceMuted;

  /// Barra de navegación, hojas inferiores y capas que flotan sobre todo.
  final Color surfaceElevated;

  /// Fondo de los diálogos.
  final Color dialogSurface;

  /// Contorno de tarjetas (blanco en claro, línea sutil en oscuro).
  final Color border;

  /// Separadores entre filas.
  final Color divider;

  /// Sombra proyectada por tarjetas y diálogos.
  final Color shadow;

  /// Velo detrás de diálogos y hojas.
  final Color scrim;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  /// Acento principal para texto, iconos y estados activos. Es la marca en
  /// claro y una variante más luminosa en oscuro.
  final Color primary;

  /// Acento intenso para textos y controles de énfasis (enlaces legales,
  /// checkbox, resaltados). Violeta profundo en claro; en oscuro un lila
  /// más claro que [primary] para no perder contraste.
  final Color primaryDeep;

  /// Fondo tenue de acento (pastillas, iconos en contenedor, selección).
  final Color primarySoft;

  /// Texto e iconos sobre [primary] o sobre el degradado de marca.
  final Color onPrimary;

  /// Relleno de campos de texto.
  final Color inputFill;

  // Colores semánticos de autenticación.
  final Color authHeading;
  final Color authBrand;
  final Color authSecondary;
  final Color authFieldLabel;
  final Color authFieldHint;
  final Color authLegalText;
  final Color authPromptText;

  bool get isDark => brightness == Brightness.dark;

  /// Tinte suave de [color] para fondos de icono o chips. En oscuro se
  /// refuerza un poco: sobre superficies oscuras un 12 % apenas se ve.
  Color tint(Color color, [double alpha = .12]) =>
      color.withValues(alpha: isDark ? alpha + .08 : alpha);

  @override
  AppPalette copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceElevated,
    Color? dialogSurface,
    Color? border,
    Color? divider,
    Color? shadow,
    Color? scrim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? primary,
    Color? primaryDeep,
    Color? primarySoft,
    Color? onPrimary,
    Color? inputFill,
    Color? authHeading,
    Color? authBrand,
    Color? authSecondary,
    Color? authFieldLabel,
    Color? authFieldHint,
    Color? authLegalText,
    Color? authPromptText,
  }) => AppPalette(
    brightness: brightness ?? this.brightness,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    dialogSurface: dialogSurface ?? this.dialogSurface,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    shadow: shadow ?? this.shadow,
    scrim: scrim ?? this.scrim,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textHint: textHint ?? this.textHint,
    primary: primary ?? this.primary,
    primaryDeep: primaryDeep ?? this.primaryDeep,
    primarySoft: primarySoft ?? this.primarySoft,
    onPrimary: onPrimary ?? this.onPrimary,
    inputFill: inputFill ?? this.inputFill,
    authHeading: authHeading ?? this.authHeading,
    authBrand: authBrand ?? this.authBrand,
    authSecondary: authSecondary ?? this.authSecondary,
    authFieldLabel: authFieldLabel ?? this.authFieldLabel,
    authFieldHint: authFieldHint ?? this.authFieldHint,
    authLegalText: authLegalText ?? this.authLegalText,
    authPromptText: authPromptText ?? this.authPromptText,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < .5 ? brightness : other.brightness,
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      surfaceElevated: mix(surfaceElevated, other.surfaceElevated),
      dialogSurface: mix(dialogSurface, other.dialogSurface),
      border: mix(border, other.border),
      divider: mix(divider, other.divider),
      shadow: mix(shadow, other.shadow),
      scrim: mix(scrim, other.scrim),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textHint: mix(textHint, other.textHint),
      primary: mix(primary, other.primary),
      primaryDeep: mix(primaryDeep, other.primaryDeep),
      primarySoft: mix(primarySoft, other.primarySoft),
      onPrimary: mix(onPrimary, other.onPrimary),
      inputFill: mix(inputFill, other.inputFill),
      authHeading: mix(authHeading, other.authHeading),
      authBrand: mix(authBrand, other.authBrand),
      authSecondary: mix(authSecondary, other.authSecondary),
      authFieldLabel: mix(authFieldLabel, other.authFieldLabel),
      authFieldHint: mix(authFieldHint, other.authFieldHint),
      authLegalText: mix(authLegalText, other.authLegalText),
      authPromptText: mix(authPromptText, other.authPromptText),
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// Paleta del tema activo (claro u oscuro).
  AppPalette get palette => AppPalette.of(this);
}

abstract final class AppTheme {
  static ThemeData get light => _build(AppPalette.light);

  static ThemeData get dark => _build(AppPalette.dark);

  /// Estilo de barras del sistema coherente con el tema: iconos oscuros
  /// sobre el fondo lila claro e iconos claros sobre el fondo oscuro.
  static SystemUiOverlayStyle systemOverlayStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark
          ? AppPalette.dark.surfaceElevated
          : Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    );
  }

  static ThemeData _build(AppPalette palette) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: palette.brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.border,
      outlineVariant: palette.divider,
      surfaceContainerHighest: palette.surfaceMuted,
      surfaceContainerHigh: palette.surfaceElevated,
      surfaceContainer: palette.surfaceElevated,
      surfaceContainerLow: palette.surface,
      surfaceContainerLowest: palette.dialogSurface,
      shadow: palette.shadow,
      scrim: palette.scrim,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
    );
    final textTheme = GoogleFonts.interTextTheme(
      base.textTheme,
    ).apply(bodyColor: palette.textPrimary, displayColor: palette.textPrimary);
    final rounded20 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );

    return base.copyWith(
      extensions: [palette],
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: palette.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w900,
        ),
        systemOverlayStyle: systemOverlayStyle(palette.brightness),
      ),
      dividerTheme: DividerThemeData(color: palette.divider, thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.dialogSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: palette.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: palette.scrim,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: palette.shadow,
      ),
      listTileTheme: ListTileThemeData(
        textColor: palette.textPrimary,
        iconColor: palette.textSecondary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: rounded20,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.isDark
            ? palette.surfaceElevated
            : palette.textPrimary,
        contentTextStyle: TextStyle(
          color: palette.isDark ? palette.textPrimary : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: rounded20,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputFill,
        hintStyle: TextStyle(color: palette.textHint),
        labelStyle: TextStyle(color: palette.textSecondary),
        prefixIconColor: palette.textSecondary,
        suffixIconColor: palette.textSecondary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.primary,
        selectionColor: palette.primary.withValues(alpha: .3),
        selectionHandleColor: palette.primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: palette.primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary.withValues(alpha: .6)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.isDark
              ? palette.primarySoft
              : palette.primary,
          foregroundColor: palette.isDark
              ? palette.primaryDeep
              : palette.onPrimary,
          side: palette.isDark
              ? BorderSide(color: palette.primary.withValues(alpha: .52))
              : null,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.onPrimary
              : palette.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.primary
              : palette.surfaceMuted,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : palette.divider,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceMuted,
        selectedColor: palette.primarySoft,
        side: BorderSide(color: palette.divider),
        labelStyle: TextStyle(color: palette.textPrimary),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: palette.dialogSurface,
        dialBackgroundColor: palette.surfaceMuted,
        hourMinuteColor: palette.surfaceMuted,
        dayPeriodColor: palette.surfaceMuted,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.dialogSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
