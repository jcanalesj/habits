import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/features/splash/2_presentation/pages/splash_page.dart';
import 'package:habits/main.dart';

import '../helpers/auth_test_helpers.dart';

/// Flujo completo de autenticación sobre la app real (router, splash,
/// páginas y shell) con los repositorios de auth en memoria.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpApp(WidgetTester tester, AuthTestEnv env) async {
    // La app resuelve el idioma del dispositivo: forzamos español para que
    // las aserciones por texto sean estables.
    tester.platformDispatcher.localeTestValue = const Locale('es');
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(overrides: env.overrides, child: const HabitsApp()),
    );
    // Splash completo + restauración de sesión.
    await tester.pump(SplashPage.duration + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  Future<void> enterCredentials(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
  }

  testWidgets('registro → bienvenida → perfil → logout → login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final env = AuthTestEnv();
    await pumpApp(tester, env);

    // Sin sesión: el splash lleva al login.
    expect(find.text('Inicia sesión'), findsOneWidget);

    // Registro.
    await tester.tap(find.text('Regístrate'));
    await tester.pumpAndSettle();
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Alex');
    await tester.enterText(fields.at(1), 'alex@example.com');
    await tester.enterText(fields.at(2), 'secreta12');
    await tester.enterText(fields.at(3), 'secreta12');
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    // Bienvenida, no verificación: con la verificación desactivada no se
    // envía ningún correo.
    expect(find.text('Tu cambio empieza aquí'), findsOneWidget);
    expect(
      find.textContaining('El siguiente mejor momento es', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('HOY.', findRichText: true), findsOneWidget);
    expect(find.text('Verifica tu cuenta'), findsNothing);
    expect(env.auth.verificationEmailsSent, isEmpty);
    expect(env.auth.currentUser?.email, 'alex@example.com');

    // "Empezar" entra en la app y crea el perfil con sus ámbitos.
    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.textContaining('Alex'), findsWidgets);
    final profile = env.profiles.profiles.values.single;
    expect(profile.email, 'alex@example.com');
    expect(profile.displayName, 'Alex');
    expect(profile.locale, 'es');
    expect(profile.timezone, 'Europe/Madrid');
    expect(profile.ambitos, hasLength(5));

    // Logout desde Perfil.
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(env.auth.currentUser, isNull);

    // Login: home directa, sin pasar de nuevo por la bienvenida.
    await enterCredentials(
      tester,
      email: 'alex@example.com',
      password: 'secreta12',
    );
    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('Tu cambio empieza aquí'), findsNothing);
    expect(env.profiles.profiles, hasLength(1));
  });

  testWidgets('una cuenta sin verificar entra con normalidad', (tester) async {
    // Viewport de móvil: el de por defecto (800x600) no es representativo.
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final env = AuthTestEnv();
    env.auth.registerAccount(unverifiedUser, password: 'secreta12');
    await pumpApp(tester, env);

    await enterCredentials(
      tester,
      email: unverifiedUser.email,
      password: 'secreta12',
    );

    // Con la verificación desactivada no hay pantalla intermedia.
    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('Verifica tu cuenta'), findsNothing);
    expect(env.profiles.profiles.keys, [unverifiedUser.id]);
  });

  testWidgets('una sesión verificada restaurada entra directa a la home', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await pumpApp(tester, env);

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('Inicia sesión'), findsNothing);
    expect(env.profiles.profiles.keys, [verifiedUser.id]);
  });

  testWidgets('recuperar contraseña desde el login envía el enlace', (
    tester,
  ) async {
    final env = AuthTestEnv();
    await pumpApp(tester, env);

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();
    expect(find.text('Recupera tu contraseña'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'alex@example.com');
    await tester.tap(find.text('Enviar enlace'));
    await tester.pumpAndSettle();

    expect(env.auth.passwordResetEmailsSent, ['alex@example.com']);
    await tester.tap(find.text('Volver a iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Inicia sesión'), findsOneWidget);
  });
}
