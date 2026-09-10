import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/features/auth/2_presentation/pages/verify_email_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  late AuthTestEnv env;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() => env = AuthTestEnv(initialUser: unverifiedUser));

  Widget app() =>
      localizedApp(const VerifyEmailPage(), overrides: env.overrides);

  testWidgets('VerifyEmailPage explica el flujo por enlace con el correo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Verifica tu cuenta'), findsOneWidget);
    expect(
      find.text('Te hemos enviado un enlace de verificación a'),
      findsOneWidget,
    );
    expect(find.text(unverifiedUser.email), findsOneWidget);
    expect(find.text('Ya he verificado mi correo'), findsOneWidget);
    expect(find.text('Reenviar correo'), findsOneWidget);
    expect(find.text('Usar otra cuenta'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Comprobar sin haber verificado muestra el aviso de pendiente', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Ya he verificado mi correo'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Todavía no consta como verificado'),
      findsOneWidget,
    );
    expect(env.auth.currentUser?.emailVerified, isFalse);
  });

  testWidgets(
    'Reenviar envía el correo y bloquea el botón durante el cooldown',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pump();

      await tester.tap(find.text('Reenviar correo'));
      await tester.pumpAndSettle();

      expect(env.auth.verificationEmailsSent, [unverifiedUser.email]);
      expect(find.textContaining('Correo reenviado'), findsOneWidget);
      expect(find.text('Reenviar en 30 s'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Reenviar en 29 s'), findsOneWidget);
    },
  );

  testWidgets('El sondeo automático detecta la verificación y navega', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const VerifyEmailPage()),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('HOME')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: env.overrides,
        child: MaterialApp.router(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    env.auth.markEmailVerified(unverifiedUser.email);
    await tester.pump(VerifyEmailPage.pollInterval);
    await tester.pumpAndSettle();

    expect(env.auth.currentUser?.emailVerified, isTrue);
    expect(find.text('HOME'), findsOneWidget);
  });
}
