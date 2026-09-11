import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/habit_form_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  late AuthTestEnv env;

  setUp(() {
    // El formulario es largo; con el viewport por defecto (800x600) los
    // controles de abajo quedan fuera de pantalla y no reciben taps.
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher
        .implicitView!;
    view.physicalSize = const Size(1200, 2600);
    view.devicePixelRatio = 1;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });
  });

  Widget appWith(Widget home) {
    env = AuthTestEnv(initialUser: verifiedUser);
    return ProviderScope(
      overrides: env.overrides,
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  testWidgets('crear un hábito lo guarda en el repositorio', (tester) async {
    await tester.pumpWidget(appWith(const HabitFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo hábito'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Correr');
    // Objetivo: 3 veces por semana.
    await tester.tap(find.widgetWithText(ChoiceChip, 'esta semana'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('3 veces por semana'), findsOneWidget);

    await tester.tap(find.text('Crear hábito'));
    await tester.pumpAndSettle();

    final habits = await env.habits.watchActiveHabits().first;
    final creado = habits.firstWhere((h) => h.name == 'Correr');
    expect(creado.periodicityOn(testToday).type, PeriodicityType.weekly);
    expect(creado.periodicityOn(testToday).timesPerPeriod, 3);
  });

  testWidgets('un nombre vacío muestra error y no guarda', (tester) async {
    await tester.pumpWidget(appWith(const HabitFormPage()));
    await tester.pumpAndSettle();
    final antes = (await env.habits.watchActiveHabits().first).length;

    await tester.tap(find.text('Crear hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe un nombre'), findsOneWidget);
    expect((await env.habits.watchActiveHabits().first).length, antes);
  });

  testWidgets('cambiar el objetivo avisa de la fecha efectiva antes de guardar',
      (tester) async {
    // "entrenar" está sembrado como 3 veces por semana.
    await tester.pumpWidget(appWith(const HabitFormPage(habitId: 'entrenar')));
    await tester.pumpAndSettle();

    expect(find.text('Editar hábito'), findsOneWidget);
    expect(find.text('3 veces por semana'), findsOneWidget);
    // Sin cambios no hay aviso.
    expect(find.textContaining('se aplicará'), findsNothing);

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('4 veces por semana'), findsOneWidget);
    // testToday es viernes 11/09/2026 → el cambio entra el lunes 14.
    expect(find.textContaining('2026-09-14'), findsOneWidget);
  });

  testWidgets('el cambio de objetivo se guarda como diferido', (tester) async {
    await tester.pumpWidget(appWith(const HabitFormPage(habitId: 'entrenar')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final habit = (await env.habits.getHabit('entrenar'))!;
    // El periodo en curso conserva el objetivo antiguo.
    expect(habit.periodicityOn(testToday).timesPerPeriod, 3);
    expect(
      habit.periodicityOn(const LogicalDate(2026, 9, 14)).timesPerPeriod,
      4,
    );
  });

  testWidgets('eliminar pide confirmación y hace soft delete', (tester) async {
    await tester.pumpWidget(appWith(const HabitFormPage(habitId: 'entrenar')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eliminar hábito'));
    await tester.pumpAndSettle();
    expect(find.text('¿Eliminar este hábito?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect((await env.habits.getHabit('entrenar'))!.isDeleted, isTrue);
    // Soft delete: el histórico se conserva.
    expect(await env.habits.fetchHabitLogs('entrenar'), isNotEmpty);
  });
}
