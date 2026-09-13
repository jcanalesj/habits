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

    expect(find.text('Elige la hora del recordatorio'), findsOneWidget);
  });
}
