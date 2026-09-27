import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/statistics_page.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  testWidgets('permite cambiar entre semana, mes y año', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(const StatisticsPage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('stats-period-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Este mes').last);
    await tester.pumpAndSettle();
    expect(find.text('Tu progreso este mes'), findsOneWidget);
    expect(find.byKey(const ValueKey('stats-month-chart')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('stats-period-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Este año').last);
    await tester.pumpAndSettle();
    expect(find.text('Tu progreso este año'), findsOneWidget);
    expect(find.byKey(const ValueKey('stats-year-chart')), findsOneWidget);
  });

  testWidgets('muestra estadísticas semanales calculadas con los registros', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await env.habits.setHabitCompletion(
      habitId: 'agua',
      date: testToday,
      completed: true,
    );
    await env.habits.setHabitCompletion(
      habitId: 'agua',
      date: testToday.addDays(-7),
      completed: true,
    );

    await tester.pumpWidget(
      localizedApp(const StatisticsPage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.text('Racha actual'), findsOneWidget);
    expect(find.text('Mejor racha'), findsOneWidget);
    expect(find.text('Actividad semanal'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.byKey(const ValueKey('week-range-2026-09-07')), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('weekly-history-pages')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week-range-2026-08-31')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Beber agua'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final progress = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('habit-stat-progress-agua')),
    );
    expect(progress.value, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra los tiempos y récords de los hábitos que se dejan', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    final habit = await env.habits.createHabit(
      HabitDraft(
        name: 'Dejar de fumar',
        ambitoId: Ambito.generalId,
        colorValue: 0xFFF59E0B,
        emoji: '🚭',
        kind: HabitKind.quit,
        abstinenceStartedAt: testInstant.subtract(const Duration(days: 4)),
      ),
      today: testToday,
    );
    await env.habits.resetQuitHabit(habit.id, resetAt: testInstant);

    await tester.pumpWidget(
      localizedApp(const StatisticsPage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Logros al dejar hábitos'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(ValueKey('quit-habit-stat-${habit.id}')), findsOneWidget);
    expect(find.text('Dejar de fumar'), findsOneWidget);
    expect(find.text('Tiempo actual'), findsOneWidget);
    expect(find.text('Mejor récord'), findsOneWidget);
    expect(find.text('1 nuevo comienzo'), findsOneWidget);
  });
}
