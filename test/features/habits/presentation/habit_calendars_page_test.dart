import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/habit_calendars_page.dart';

import '../../../helpers/auth_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  testWidgets('muestra un calendario por hábito con días cumplidos y vacíos', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await env.habits.setHabitCompletion(
      habitId: 'agua',
      date: testToday,
      completed: true,
    );

    await tester.pumpWidget(
      localizedApp(const HabitCalendarsPage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    expect(find.text('Calendarios de hábitos'), findsOneWidget);
    expect(find.byKey(const ValueKey('habit-calendar-agua')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('habit-calendar-agua')),
        matching: find.byKey(const ValueKey('calendar-day-11-done')),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('habit-calendar-meditacion')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const ValueKey('habit-calendar-meditacion')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('en la pestaña muestra Mis hábitos y la acción de editar', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);

    await tester.pumpWidget(
      localizedApp(
        const HabitCalendarsPage(isHabitsTab: true),
        overrides: env.overrides,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mis hábitos'), findsOneWidget);
    expect(find.byKey(const ValueKey('edit-habits-action')), findsOneWidget);
    expect(find.text('Editar hábitos'), findsOneWidget);

    final list = tester.widget<ListView>(find.byType(ListView));
    expect(
      (list.padding! as EdgeInsets).bottom,
      HabitCalendarsPage.bottomBarClearance,
    );
  });
}
