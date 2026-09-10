import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/components/auth_header.dart';
import 'package:habits/features/auth/2_presentation/pages/login_page.dart';

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
}
