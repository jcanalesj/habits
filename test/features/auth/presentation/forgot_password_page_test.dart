import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/features/auth/2_presentation/pages/forgot_password_page.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  late AuthTestEnv env;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() => env = AuthTestEnv());

  Widget app() =>
      localizedApp(const ForgotPasswordPage(), overrides: env.overrides);

  testWidgets('Muestra el formulario y valida el email', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Recupera tu contraseña'), findsOneWidget);
    expect(find.text('Enviar enlace'), findsOneWidget);

    await tester.tap(find.text('Enviar enlace'));
    await tester.pumpAndSettle();

    expect(find.text('Introduce un correo válido'), findsOneWidget);
    expect(env.auth.passwordResetEmailsSent, isEmpty);
  });

  testWidgets('Envía el enlace y muestra un mensaje neutro', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'alex@example.com');
    await tester.tap(find.text('Enviar enlace'));
    await tester.pumpAndSettle();

    expect(env.auth.passwordResetEmailsSent, ['alex@example.com']);
    expect(find.textContaining('recibirás un enlace'), findsOneWidget);
    expect(find.text('Volver a iniciar sesión'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
