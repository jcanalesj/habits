import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/components/auth_header.dart';
import 'package:habits/features/auth/2_presentation/pages/login_page.dart';
import 'package:habits/features/auth/2_presentation/pages/verify_email_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  late AuthTestEnv env;

  setUpAll(() {
    // En tests no hay red: evita que google_fonts intente descargar fuentes.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    env = AuthTestEnv();
    env.auth.registerAccount(verifiedUser, password: 'secreta12');
  });

  Widget app() => localizedApp(const LoginPage(), overrides: env.overrides);

  /// App con router real: login, verificación y home.
  Widget routedApp(WidgetTester tester) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LoginPage()),
        GoRoute(
          path: '/verify-email',
          builder: (_, _) => const VerifyEmailPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('HOME')),
        ),
      ],
    );
    addTearDown(router.dispose);
    return ProviderScope(
      overrides: env.overrides,
      child: MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  Future<void> signIn(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
  }

  testWidgets('LoginPage muestra el formulario de inicio de sesión', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Accede a tu cuenta'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).resizeToAvoidBottomInset,
      isFalse,
    );
  });

  testWidgets('LoginPage se adapta a una pantalla compacta sin overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Al abrir el teclado oculta la marca y mantiene ambos campos', (
    tester,
  ) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final hiddenHeader = find.ancestor(
      of: find.byType(AuthHeader),
      matching: find.byType(ClipRect),
    );
    expect(tester.getSize(hiddenHeader.first).height, 0);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Enviar vacío muestra errores de validación', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(find.text('Introduce un correo válido'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener al menos 6 caracteres'),
      findsOneWidget,
    );
    expect(env.auth.currentUser, isNull);
  });

  testWidgets('Credenciales incorrectas muestran el error localizado', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), verifiedUser.email);
    await tester.enterText(find.byType(TextField).at(1), 'incorrecta');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(env.auth.currentUser, isNull);
  });

  testWidgets('Llega con el correo precargado cuando se le pasa', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const LoginPage(initialEmail: 'alex@example.com'),
        overrides: env.overrides,
      ),
    );
    await tester.pump();

    final emailField = tester.widget<TextField>(find.byType(TextField).first);
    expect(emailField.controller?.text, 'alex@example.com');
  });

  testWidgets('Rellena el correo aunque la página ya estuviera montada', (
    tester,
  ) async {
    // go_router reutiliza la página de login cuando solo cambia el
    // `?email=`: el State sobrevive y debe resincronizarse igualmente.
    await tester.pumpWidget(app());
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      isEmpty,
    );

    await tester.pumpWidget(
      localizedApp(
        const LoginPage(initialEmail: 'alex@example.com'),
        overrides: env.overrides,
      ),
    );
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'alex@example.com',
    );
  });

  testWidgets('Una cuenta verificada entra en la home', (tester) async {
    await tester.pumpWidget(routedApp(tester));
    await tester.pump();

    await signIn(tester, email: verifiedUser.email, password: 'secreta12');

    expect(find.text('HOME'), findsOneWidget);
    expect(env.auth.currentUser?.emailVerified, isTrue);
  });

  testWidgets(
    'Una cuenta sin verificar va a la verificación, avisa y envía el enlace',
    (tester) async {
      tester.view.physicalSize = const Size(390, 950);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      env.auth.registerAccount(unverifiedUser, password: 'secreta12');
      await tester.pumpWidget(routedApp(tester));
      await tester.pump();

      await signIn(tester, email: unverifiedUser.email, password: 'secreta12');

      expect(find.text('Verifica tu cuenta'), findsOneWidget);
      expect(find.text('Tu cuenta todavía no está verificada'), findsOneWidget);
      expect(find.text(unverifiedUser.email), findsOneWidget);
      expect(env.auth.currentUser?.id, unverifiedUser.id);

      // El enlace se envía solo al llegar a la verificación.
      expect(env.auth.verificationEmailsSent, [unverifiedUser.email]);
      expect(find.textContaining('Correo reenviado'), findsOneWidget);
    },
  );
}
