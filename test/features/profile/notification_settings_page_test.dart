import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/profile/notifications/notification_settings_page.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  testWidgets('muestra los recordatorios configurados por hábito', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser, seededHabits: true);
    await tester.pumpWidget(
      localizedApp(const NotificationSettingsPage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Un empujoncito a tiempo'), findsOneWidget);
    expect(find.text('Recordatorios de hábitos'), findsOneWidget);
    expect(find.text('Beber agua'), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('activar un hábito abre el selector de hora', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser, seededHabits: true);
    await tester.pumpWidget(
      localizedApp(const NotificationSettingsPage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    final disabledSwitch = find.byWidgetPredicate(
      (widget) => widget is Switch && !widget.value,
    );
    await tester.tap(disabledSwitch.first);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reminder-time-dialog')), findsOneWidget);
    expect(find.text('¿A qué hora te avisamos?'), findsOneWidget);
    expect(find.text('Mañana'), findsOneWidget);
    expect(find.text('Tarde'), findsOneWidget);
    expect(find.text('Noche'), findsOneWidget);
  });

  testWidgets('un acceso rápido guarda la hora elegida', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser, seededHabits: true);
    await tester.pumpWidget(
      localizedApp(const NotificationSettingsPage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    final disabledSwitch = find.byWidgetPredicate(
      (widget) => widget is Switch && !widget.value,
    );
    await tester.tap(disabledSwitch.first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tarde'));
    await tester.tap(find.text('Tarde'));
    await tester.pumpAndSettle();

    expect(find.text('15:00'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('save-reminder-time')),
    );
    await tester.tap(find.byKey(const ValueKey('save-reminder-time')));
    await tester.pumpAndSettle();

    expect(find.text('Cada día a las 15:00'), findsOneWidget);
  });

  testWidgets(
    'el mensaje personalizado pide Premium y se desbloquea al comprar',
    (tester) async {
      final env = AuthTestEnv(initialUser: verifiedUser, seededHabits: true);
      await tester.pumpWidget(
        localizedApp(
          const NotificationSettingsPage(),
          overrides: env.overrides,
        ),
      );
      await tester.pumpAndSettle();

      final action = find.byKey(const ValueKey('reminder-message-entrenar'));
      await tester.scrollUntilVisible(
        action,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
      await tester.pumpAndSettle();
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('premium-reminder-message-dialog')),
        findsOneWidget,
      );
      expect(find.text('Tus recordatorios, a tu manera'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('reminder-message-view-premium-plans')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('paywall-page')), findsOneWidget);
      await buyPremiumOnPaywall(tester);
      expect(find.byKey(const ValueKey('paywall-page')), findsNothing);
      expect(
        find.byKey(const ValueKey('premium-reminder-message-dialog')),
        findsNothing,
      );

      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('reminder-message-dialog')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Premium guarda un mensaje distinto para cada hábito', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser, seededHabits: true);
    env.profiles.premium[verifiedUser.id] = true;
    await tester.pumpWidget(
      localizedApp(const NotificationSettingsPage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    final action = find.byKey(const ValueKey('reminder-message-entrenar'));
    await tester.scrollUntilVisible(
      action,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('reminder-message-dialog')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('reminder-message-field')),
      'Hoy entrenas por ti 💪',
    );
    await tester.tap(find.byKey(const ValueKey('save-reminder-message')));
    await tester.pumpAndSettle();

    expect(
      (await env.habits.getHabit('entrenar'))?.reminderMessage,
      'Hoy entrenas por ti 💪',
    );
    expect(find.text('Hoy entrenas por ti 💪'), findsOneWidget);
  });
}
