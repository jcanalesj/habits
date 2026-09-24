import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
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
  final welcomePreferences = await _loadWelcomePreferences();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ProviderScope(
      overrides: [
        welcomeAnimationPreferencesProvider.overrideWithValue(
          welcomePreferences,
        ),
      ],
      child: const HabitsApp(),
    ),
  );
}

Future<WelcomeAnimationPreferences> _loadWelcomePreferences() async {
  try {
    final preferences = await SharedPreferences.getInstance();
    return SharedWelcomeAnimationPreferences(preferences);
  } on PlatformException catch (error) {
    // Un plugin añadido durante una sesión de depuración no registra su canal
    // hasta reiniciar la app. La preferencia pasa a memoria en vez de impedir
    // que toda la aplicación arranque.
    debugPrint('SharedPreferences no disponible: $error');
    return MemoryWelcomeAnimationPreferences();
  }
}

class HabitsApp extends ConsumerWidget {
  const HabitsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
