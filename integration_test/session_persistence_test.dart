// Persistencia de sesión entre procesos: debe ejecutarse DESPUÉS de
// auth_flow_emulator_test.dart, en una invocación distinta de `flutter test`
// (proceso nuevo), con los mismos emuladores levantados y el mismo flag.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/env.dart';
import 'package:habits/features/splash/2_presentation/pages/splash_page.dart';
import 'package:habits/firebase_setup.dart';
import 'package:habits/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    expect(Env.useFirebaseEmulator, isTrue);
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeFirebase();
  });

  testWidgets('la sesión verificada sobrevive a un arranque nuevo', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('es');
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final restored = FirebaseAuth.instance.currentUser;
    expect(restored, isNotNull, reason: 'el SDK no restauró la sesión');
    expect(restored!.emailVerified, isTrue);

    await tester.pumpWidget(const ProviderScope(child: HabitsApp()));
    await tester.pump(SplashPage.duration + const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('Inicia sesión'), findsNothing);
  });
}
