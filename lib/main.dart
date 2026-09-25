import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/app_lifecycle.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/appearance/app_icon.dart';
import 'package:habits/features/profile/appearance/theme_mode_preferences.dart';
import 'package:habits/firebase_setup.dart';
import 'package:habits/local_preferences.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/navigation.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Las fuentes van en assets/fonts: nada de pedirlas a Google en tiempo de
  // ejecución (privacidad y primer arranque sin conexión).
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(_fontLicenses);
  // Base de datos IANA para resolver el día lógico en la zona del perfil
  // (§12/§35). Es Dart puro y va embebida: no hace red ni I/O.
  initializeTimezones();
  final preferences = await _loadPreferences();
  final clearCache =
      preferences?.getBool(clearFirestoreCacheOnStartKey) ?? false;
  await initializeFirebase(clearCache: clearCache);
  if (clearCache) await preferences?.remove(clearFirestoreCacheOnStartKey);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
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

/// Licencias OFL de las fuentes empaquetadas (las exige la licencia).
Stream<LicenseEntry> _fontLicenses() async* {
  for (final (family, file) in [
    ('Inter', 'assets/fonts/Inter-OFL.txt'),
    ('Playfair Display', 'assets/fonts/PlayfairDisplay-OFL.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks([
      family,
    ], await rootBundle.loadString(file));
  }
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

class HabitsApp extends ConsumerStatefulWidget {
  const HabitsApp({super.key});

  @override
  ConsumerState<HabitsApp> createState() => _HabitsAppState();
}

class _HabitsAppState extends ConsumerState<HabitsApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Al volver de segundo plano puede ser otro día o haber otros permisos.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(systemStateTickProvider.notifier).bump(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Mantiene vivo el control del icono para revertirlo si caduca Premium.
    ref.watch(appIconProvider);

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
