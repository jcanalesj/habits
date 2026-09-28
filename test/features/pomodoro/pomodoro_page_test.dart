import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/pomodoro/2_presentation/pages/pomodoro_page.dart';
import 'package:habits/features/pomodoro/2_presentation/providers/pomodoro_providers.dart';
import 'package:habits/features/pomodoro/3_data/data.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  testWidgets('muestra el reloj, arranca y pausa', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    final repo = InMemoryPomodoroRepository();
    addTearDown(repo.dispose);
    await repo.addSession(
      day: testToday,
      startedAt: testInstant.subtract(const Duration(hours: 2)),
      durationMinutes: 25,
      label: 'Informe',
    );
    await tester.pumpWidget(
      localizedApp(
        const PomodoroPage(),
        overrides: [
          ...env.overrides,
          pomodoroRepositoryProvider.overrideWithValue(repo),
          pomodoroStateStoreProvider.overrideWithValue(
            InMemoryPomodoroStateStore(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('CONCENTRACIÓN'), findsOneWidget);
    expect(find.text('Pomodoro 1 de 4'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Informe'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Informe'), findsOneWidget);
    expect(find.text('25 min'), findsWidgets);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 800));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('pomodoro-toggle')));
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsNothing);
    expect(env.notifications.tagged['pomodoro']?.length, 1);

    await tester.tap(find.byKey(const ValueKey('pomodoro-toggle')));
    await tester.pump();
    expect(env.notifications.tagged.containsKey('pomodoro'), isFalse);

    // Ajustes: abrir y guardar sin cambios.
    await tester.tap(find.byKey(const ValueKey('pomodoro-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes del Pomodoro'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pomodoro-settings-save')));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes guardados'), findsOneWidget);
  });
}
