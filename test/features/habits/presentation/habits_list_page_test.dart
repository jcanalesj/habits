import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/habits_list_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  Widget appWith({bool seeded = true}) {
    return ProviderScope(
      overrides: AuthTestEnv(
        initialUser: verifiedUser,
        seededHabits: seeded,
      ).overrides,
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HabitsListPage(),
      ),
    );
  }

  testWidgets('lista todos los hábitos con su objetivo', (tester) async {
    await tester.pumpWidget(appWith());
    await tester.pumpAndSettle();

    expect(find.text('Mis hábitos'), findsOneWidget);
    expect(find.text('Beber agua'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Entrenar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('3 veces por semana'), findsOneWidget);
  });

  testWidgets('sin hábitos muestra el estado vacío', (tester) async {
    await tester.pumpWidget(appWith(seeded: false));
    await tester.pumpAndSettle();

    expect(find.textContaining('Aún no tienes hábitos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ofrece crear un hábito nuevo', (tester) async {
    await tester.pumpWidget(appWith());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FloatingActionButton, 'Nuevo hábito'),
        findsOneWidget);
  });
}
