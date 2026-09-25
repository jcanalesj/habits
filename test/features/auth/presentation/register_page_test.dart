import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/features/auth/2_presentation/pages/register_page.dart';
import 'package:habits/features/auth/2_presentation/pages/forgot_password_page.dart';
import 'package:habits/features/auth/2_presentation/pages/login_page.dart';
import 'package:habits/features/auth/2_presentation/pages/verify_email_page.dart';
import 'package:habits/features/auth/2_presentation/pages/welcome_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  late AuthTestEnv env;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() => env = AuthTestEnv());

  Widget app() => localizedApp(const RegisterPage(), overrides: env.overrides);

  /// App con router real: registro, login, recuperación y verificación,
  /// para comprobar adónde navega cada acción.
  Widget routedApp(WidgetTester tester) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const RegisterPage()),
        GoRoute(
          path: '/login',
          builder: (_, state) =>
              LoginPage(initialEmail: state.uri.queryParameters['email']),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, state) => ForgotPasswordPage(
            initialEmail: state.uri.queryParameters['email'],
          ),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (_, _) => const VerifyEmailPage(),
        ),
        GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),
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

  Future<void> fillForm(
    WidgetTester tester, {
    required String email,
    required String password,
  }) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Nuevo');
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), password);
    await tester.enterText(fields.at(3), password);
    await tester.tap(find.byType(Checkbox));
  }

  testWidgets('RegisterPage muestra el formulario de alta', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Apodo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Confirma tu contraseña'), findsOneWidget);
    expect(find.text('Registrarme'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).resizeToAvoidBottomInset,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Enviar vacío muestra los errores del registro', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(find.text('Introduce un apodo'), findsOneWidget);
    expect(find.text('Introduce un correo válido'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener al menos 8 caracteres'),
      findsOneWidget,
    );
    expect(
      find.text('Debes aceptar los términos y la política de privacidad'),
      findsOneWidget,
    );
    expect(env.auth.currentUser, isNull);
  });

  testWidgets('Un correo ya registrado muestra el error y NO inicia sesión', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Misma contraseña que la cuenta existente: aun así no debe entrar.
    env.auth.registerAccount(unverifiedUser, password: 'secreta12');
    await tester.pumpWidget(routedApp(tester));
    await tester.pump();

    await fillForm(tester, email: unverifiedUser.email, password: 'secreta12');
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(find.text('Ya existe una cuenta con este correo.'), findsOneWidget);
    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(env.auth.currentUser, isNull);
    expect(env.auth.verificationEmailsSent, isEmpty);
    // Y se ofrecen las dos salidas.
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
  });

  testWidgets('"Iniciar sesión" navega al login con el correo precargado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    env.auth.registerAccount(unverifiedUser, password: 'secreta12');
    await tester.pumpWidget(routedApp(tester));
    await tester.pump();

    await fillForm(tester, email: unverifiedUser.email, password: 'secreta12');
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Accede a tu cuenta'), findsOneWidget);
    final emailField = tester.widget<TextField>(find.byType(TextField).first);
    expect(emailField.controller?.text, unverifiedUser.email);
  });

  testWidgets('La recuperación también llega con el correo precargado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    env.auth.registerAccount(unverifiedUser, password: 'secreta12');
    await tester.pumpWidget(routedApp(tester));
    await tester.pump();

    await fillForm(tester, email: unverifiedUser.email, password: 'secreta12');
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();

    expect(find.text('Recupera tu contraseña'), findsOneWidget);
    final emailField = tester.widget<TextField>(find.byType(TextField).first);
    expect(emailField.controller?.text, unverifiedUser.email);
  });

  testWidgets(
    'Un alta válida lleva a la bienvenida, sin correo ni verificación',
    (tester) async {
      tester.view.physicalSize = const Size(390, 950);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(routedApp(tester));
      await tester.pump();

      await fillForm(tester, email: 'nueva@example.com', password: 'secreta12');
      await tester.tap(find.text('Registrarme'));
      await tester.pumpAndSettle();

      expect(find.text('Tu cambio empieza aquí'), findsOneWidget);
      expect(find.text('Empezar'), findsOneWidget);
      expect(env.auth.currentUser?.email, 'nueva@example.com');
      // Verificación desactivada: no se envía ningún correo al alta.
      expect(env.auth.verificationEmailsSent, isEmpty);
    },
  );

  testWidgets('El campo enfocado sube sobre el teclado sin cambiar de tamaño', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final confirmField = find.byType(TextField).at(3);
    final sizeBefore = tester.getSize(confirmField);
    final topBefore = tester.getTopLeft(confirmField).dy;

    await tester.tap(confirmField);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(confirmField).dy, lessThan(topBefore));
    expect(tester.getSize(confirmField), sizeBefore);
    expect(tester.getBottomRight(confirmField).dy, lessThan(544));
    expect(tester.takeException(), isNull);
  });
}
