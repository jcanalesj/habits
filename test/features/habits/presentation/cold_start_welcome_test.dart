import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  test('la sesión de bienvenida solo se consume una vez por cold start', () {
    final session = ColdStartWelcomeSession();
    expect(session.take(enabled: true), isTrue);
    expect(session.take(enabled: true), isFalse);
  });

  test('si está desactivada se omite durante todo el cold start', () {
    final session = ColdStartWelcomeSession();
    expect(session.take(enabled: false), isFalse);
    expect(session.take(enabled: true), isFalse);
  });

  testWidgets('se puede saltar tocando y deja visible la Home', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      ProviderScope(
        overrides: env.overrides,
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const ValueKey('cold-start-welcome')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cold-start-welcome')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cold-start-welcome')), findsNothing);
    expect(find.text('Racha general'), findsOneWidget);
  });

  testWidgets('Reduce Motion usa una bienvenida breve', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      ProviderScope(
        overrides: env.overrides,
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: HomePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cold-start-welcome')), findsNothing);
    expect(find.text('Racha general'), findsOneWidget);
  });

  test('el selector motivacional siempre devuelve un índice válido', () {
    final random = Random(7);
    for (var i = 0; i < 30; i++) {
      expect(
        WelcomeMessageSelector.randomIndex(random),
        inInclusiveRange(0, 5),
      );
    }
  });
}
