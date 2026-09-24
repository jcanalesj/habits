import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/2_presentation/pages/login_page.dart';
import 'package:habits/features/auth/2_presentation/pages/register_page.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/habit_calendars_page.dart';
import 'package:habits/features/habits/2_presentation/pages/habits_list_page.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';
import 'package:habits/features/habits/2_presentation/pages/statistics_page.dart';
import 'package:habits/features/profile/notifications/notification_settings_page.dart';
import 'package:habits/features/profile/profile_page.dart';
import 'package:habits/features/profile/timezone/timezone_page.dart';
import 'package:habits/theme/app_theme.dart';

import '../helpers/auth_test_helpers.dart';

/// Cada pantalla se pinta con el tema oscuro y sin excepciones de layout ni
/// de pintura. No comprueba colores concretos: protege de widgets que sigan
/// asumiendo un fondo claro y rompan al leer la paleta.
void main() {
  setUpAll(initializeTimezones);

  final pages = <String, Widget>{
    'HomePage': const HomePage(),
    'HabitsListPage': const HabitsListPage(),
    'StatisticsPage': const StatisticsPage(),
    'HabitCalendarsPage': const HabitCalendarsPage(),
    'ProfilePage': const ProfilePage(),
    'TimezonePage': const TimezonePage(),
    'NotificationSettingsPage': const NotificationSettingsPage(),
  };

  for (final entry in pages.entries) {
    testWidgets('${entry.key} se pinta en modo oscuro', (tester) async {
      final env = AuthTestEnv(initialUser: verifiedUser);
      await tester.pumpWidget(
        localizedApp(
          entry.value,
          overrides: env.overrides,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final context = tester.element(find.byType(entry.value.runtimeType));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(context.palette.isDark, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  for (final entry in {
    'LoginPage': const LoginPage(),
    'RegisterPage': const RegisterPage(),
  }.entries) {
    testWidgets('${entry.key} se pinta en modo oscuro', (tester) async {
      final env = AuthTestEnv();
      await tester.pumpWidget(
        localizedApp(
          entry.value,
          overrides: env.overrides,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(entry.value.runtimeType));
      expect(context.palette.isDark, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
