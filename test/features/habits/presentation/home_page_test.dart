import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

Widget _appUnderTest({
  required Locale locale,
  bool seeded = true,
  WildcardBalance? wildcards,
}) {
  return ProviderScope(
    overrides: AuthTestEnv(
      initialUser: verifiedUser,
      seededHabits: seeded,
      wildcards: wildcards,
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
  setUpAll(initializeTimezones);

  testWidgets('HomePage muestra la racha general y los hábitos', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('días consecutivos'), findsOneWidget);
    // Ya no existe el carrusel de rachas por ámbito (§29).
    expect(find.text('Rachas por ámbito'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Beber agua'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mis hábitos'), findsOneWidget);
    expect(find.text('Beber agua'), findsOneWidget);
  });

  testWidgets('HomePage shows the overall streak in English', (tester) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Overall streak'), findsOneWidget);
    expect(find.text('consecutive days'), findsOneWidget);
    expect(find.text('Streaks by area'), findsNothing);
  });

  testWidgets('HomePage muestra el progreso del objetivo, no una racha', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Entrenar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    // "Entrenar" está sembrado como 3 veces por semana.
    expect(find.text('3 veces por semana'), findsOneWidget);
    expect(find.textContaining('esta semana'), findsWidgets);
  });

  testWidgets('HomePage sin hábitos muestra el estado vacío y racha a cero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appUnderTest(locale: const Locale('es'), seeded: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.textContaining('Completa un hábito'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Aún no tienes hábitos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Aún no tienes hábitos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con saldo se muestran los comodines disponibles', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appUnderTest(
        locale: const Locale('es'),
        // Ya concedido este mes: así la concesión perezosa no lo altera.
        wildcards: WildcardBalance(
          available: 2,
          lastGrantYearMonth: testToday.yearMonth,
          grantedTotal: 2,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 comodines disponibles'), findsOneWidget);
  });
}
