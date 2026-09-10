import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

Widget _appUnderTest({required Locale locale, bool seeded = true}) {
  return ProviderScope(
    overrides: AuthTestEnv(
      initialUser: verifiedUser,
      seededHabits: seeded,
    ).overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    ),
  );
}

void main() {
  testWidgets('HomePage muestra las secciones del dashboard en español', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('Rachas por ámbito'), findsOneWidget);
    expect(find.text('días consecutivos'), findsOneWidget);

    // La lista de hábitos queda por debajo del viewport inicial del test.
    await tester.scrollUntilVisible(
      find.text('Beber agua'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mis hábitos'), findsOneWidget);
    expect(find.text('Beber agua'), findsOneWidget);
  });

  testWidgets('HomePage shows dashboard sections in English', (tester) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Overall streak'), findsOneWidget);
    expect(find.text('Streaks by area'), findsOneWidget);
    expect(find.text('consecutive days'), findsOneWidget);
  });
  testWidgets('HomePage sin hábitos muestra el estado vacío y rachas a cero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appUnderTest(locale: const Locale('es'), seeded: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    await tester.scrollUntilVisible(
      find.textContaining('Aún no tienes hábitos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Aún no tienes hábitos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
