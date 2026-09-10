import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/features/auth/2_presentation/pages/register_page.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  late AuthTestEnv env;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() => env = AuthTestEnv());

  Widget app() => localizedApp(const RegisterPage(), overrides: env.overrides);

  testWidgets('RegisterPage muestra el formulario de alta', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.text('Nickname'), findsOneWidget);
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

    expect(find.text('Introduce un nickname'), findsOneWidget);
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

  testWidgets('Un correo ya registrado muestra el error del proveedor', (
    tester,
  ) async {
    env.auth.registerAccount(unverifiedUser);
    await tester.pumpWidget(app());
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Nuevo');
    await tester.enterText(fields.at(1), unverifiedUser.email);
    await tester.enterText(fields.at(2), 'secreta12');
    await tester.enterText(fields.at(3), 'secreta12');
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(find.text('Ya existe una cuenta con ese correo.'), findsOneWidget);
    expect(env.auth.currentUser, isNull);
  });

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
