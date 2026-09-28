import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/tasks/2_presentation/providers/tasks_providers.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/3_data/data.dart';
import 'package:habits/features/tools/2_presentation/pages/tools_panel_page.dart';
import 'package:habits/features/tools/2_presentation/providers/tools_providers.dart';
import 'package:habits/local_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  Future<void> pumpPanel(
    WidgetTester tester, {
    TargetPlatform platform = TargetPlatform.iOS,
    bool isWeb = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final env = AuthTestEnv(initialUser: verifiedUser);
    final tasks = InMemoryTasksRepository(now: () => testInstant);
    addTearDown(tasks.dispose);
    await tasks.create(const TaskDraft(title: 'Una', date: testToday));
    await tasks.create(const TaskDraft(title: 'Dos', date: testToday));
    await tester.pumpWidget(
      localizedApp(
        const Scaffold(body: ToolsPanelPage()),
        overrides: [
          ...env.overrides,
          sharedPreferencesProvider.overrideWithValue(preferences),
          tasksRepositoryProvider.overrideWithValue(tasks),
          toolsPlatformProvider.overrideWithValue((
            platform: platform,
            isWeb: isWeb,
          )),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra las cinco herramientas con su dato vivo', (
    tester,
  ) async {
    await pumpPanel(tester);
    expect(find.byKey(const ValueKey('tool-card-tasks')), findsOneWidget);
    expect(find.byKey(const ValueKey('tool-card-pomodoro')), findsOneWidget);
    expect(find.byKey(const ValueKey('tool-card-shopping')), findsOneWidget);
    expect(find.byKey(const ValueKey('tool-card-finance')), findsOneWidget);
    expect(find.byKey(const ValueKey('tool-card-steps')), findsOneWidget);
    expect(find.text('2 pendientes hoy'), findsOneWidget);
  });

  testWidgets('en web no aparece Pasos', (tester) async {
    await pumpPanel(tester, isWeb: true);
    expect(find.byKey(const ValueKey('tool-card-steps')), findsNothing);
    expect(find.byKey(const ValueKey('tool-card-tasks')), findsOneWidget);
  });

  testWidgets('sin Premium explica los planes al abrir una herramienta', (
    tester,
  ) async {
    await pumpPanel(tester);
    await tester.tap(find.byKey(const ValueKey('tool-card-tasks')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('premium-tools-dialog')), findsOneWidget);
  });

  testWidgets('el aviso de racha se puede cerrar y no vuelve', (tester) async {
    await pumpPanel(tester);
    final dismiss = find.byKey(const ValueKey('tools-notice-dismiss'));
    await tester.scrollUntilVisible(
      dismiss,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(dismiss, findsOneWidget);
    await tester.tap(dismiss);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tools-notice-dismiss')), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(toolsNoticeHiddenKey), isTrue);
  });
}
