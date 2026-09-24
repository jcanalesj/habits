import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/appearance/theme_mode_preferences.dart';
import 'package:habits/firebase_setup.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/navigation.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Base de datos IANA para resolver el día lógico en la zona del perfil
  // (§12/§35). Es Dart puro y va embebida: no hace red ni I/O.
  initializeTimezones();
  await initializeFirebase();
  final preferences = await _loadPreferences();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    ProviderScope(
      overrides: [
        welcomeAnimationPreferencesProvider.overrideWithValue(
          preferences == null
              ? MemoryWelcomeAnimationPreferences()
              : SharedWelcomeAnimationPreferences(preferences),
        ),
        themeModePreferencesProvider.overrideWithValue(
          preferences == null
              ? MemoryThemeModePreferences()
              : SharedThemeModePreferences(preferences),
        ),
      ],
      child: const HabitsApp(),
    ),
  );
}

/// Preferencias locales (animación de bienvenida, tema…). Se leen antes del
/// primer frame para que el tema elegido no parpadee al arrancar.
Future<SharedPreferences?> _loadPreferences() async {
  try {
    return await SharedPreferences.getInstance();
  } on PlatformException catch (error) {
    // Un plugin añadido durante una sesión de depuración no registra su canal
    // hasta reiniciar la app. Las preferencias pasan a memoria en vez de
    // impedir que toda la aplicación arranque.
    debugPrint('SharedPreferences no disponible: $error');
    return null;
  }
}

class HabitsApp extends ConsumerWidget {
  const HabitsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      // Las barras del sistema siguen al tema claro u oscuro elegido.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.systemOverlayStyle(Theme.of(context).brightness),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
