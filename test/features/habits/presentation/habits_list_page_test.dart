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
    expect(find.byKey(const ValueKey('open-habit-calendars')), findsOneWidget);
    expect(find.text('Beber agua'), findsOneWidget);
    expect(find.text('Salud'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Meditación'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mente'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Estudiar inglés'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Desarrollo'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Entrenar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('3 veces por semana'), findsOneWidget);
    expect(find.text('Energía'), findsOneWidget);
    expect(find.text('Editar hábito'), findsWidgets);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
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

    expect(
      find.widgetWithText(FloatingActionButton, 'Nuevo hábito'),
      findsOneWidget,
    );
  });

  testWidgets('muestra Premium al intentar superar 5 hábitos', (tester) async {
    await tester.pumpWidget(appWith());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Nuevo hábito'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('premium-habit-limit-dialog')),
      findsOneWidget,
    );
    expect(find.text('Desbloquea más hábitos con Premium'), findsOneWidget);
    expect(find.textContaining('límite de 5 hábitos'), findsOneWidget);
    expect(find.text('Hábitos ilimitados'), findsOneWidget);
    expect(find.text('Estadísticas avanzadas'), findsOneWidget);
    expect(find.text('Nuevas funcionalidades'), findsOneWidget);
    expect(find.text('Ahora no'), findsOneWidget);
    expect(find.text('Ver planes Premium'), findsOneWidget);

    await tester.ensureVisible(find.text('Ahora no'));
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('premium-habit-limit-dialog')),
      findsNothing,
    );
  });

  testWidgets('avisa antes de abrir la edición', (tester) async {
    await tester.pumpWidget(appWith());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('habit-edit-agua')));
    await tester.pumpAndSettle();

    expect(find.text('¿Cambiar frecuencia?'), findsOneWidget);
    expect(find.textContaining('progreso se recalculará'), findsOneWidget);
    expect(find.text('Tu historial se mantendrá.'), findsOneWidget);
    expect(find.text('Tu racha no se borrará.'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/icons/edit.png')),
      findsOneWidget,
    );
    expect(find.text('Continuar'), findsOneWidget);
  });
}
