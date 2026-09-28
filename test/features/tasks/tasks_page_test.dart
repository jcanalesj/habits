import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/2_presentation/pages/tasks_page.dart';
import 'package:habits/features/tasks/2_presentation/providers/tasks_providers.dart';
import 'package:habits/features/tasks/3_data/data.dart';
import 'package:habits/local_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_test_helpers.dart';

Future<(AuthTestEnv, InMemoryTasksRepository)> pumpTasks(
  WidgetTester tester, {
  Iterable<TaskDraft> seeded = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final env = AuthTestEnv(initialUser: verifiedUser);
  final repository = InMemoryTasksRepository(now: () => testInstant);
  addTearDown(repository.dispose);
  for (final draft in seeded) {
    await repository.create(draft);
  }
  await tester.pumpWidget(
    localizedApp(
      const TasksPage(),
      overrides: [
        ...env.overrides,
        sharedPreferencesProvider.overrideWithValue(preferences),
        tasksRepositoryProvider.overrideWithValue(repository),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return (env, repository);
}

void main() {
  testWidgets('lista las pendientes de hoy y permite completarlas', (
    tester,
  ) async {
    final (_, repository) = await pumpTasks(
      tester,
      seeded: const [
        TaskDraft(title: 'Llamar al médico', date: testToday, time: '10:30'),
        TaskDraft(title: 'Leer 20 páginas', date: testToday),
      ],
    );

    expect(find.text('Llamar al médico'), findsOneWidget);
    expect(find.text('Leer 20 páginas'), findsOneWidget);
    expect(find.textContaining('10:30'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('task-toggle-task-1')));
    await tester.pumpAndSettle();

    expect(
      repository.all.firstWhere((t) => t.id == 'task-1').isCompleted,
      isTrue,
    );
    // Pasa a la sección plegada de completadas.
    expect(find.text('Completadas · 1'), findsOneWidget);
  });

  testWidgets('crea una tarea desde la pantalla de alta', (tester) async {
    final (_, repository) = await pumpTasks(tester);
    expect(find.text('Nada pendiente para este día'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tasks-new')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-form-page')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('task-title-field')),
      'Regar las plantas',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('task-priority-high')),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-priority-high')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('task-form-save')),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('task-form-save')));
    await tester.pumpAndSettle();

    expect(repository.all.single.title, 'Regar las plantas');
    expect(repository.all.single.priority, TaskPriority.high);
    expect(repository.all.single.date, testToday);
    expect(find.text('Regar las plantas'), findsOneWidget);
    expect(find.text('Alta'), findsOneWidget);
  });

  testWidgets('ofrece arrastrar las atrasadas y las pasa todas a hoy', (
    tester,
  ) async {
    final (env, repository) = await pumpTasks(
      tester,
      seeded: [
        TaskDraft(title: 'Pagar la luz', date: testToday.addDays(-2)),
        TaskDraft(title: 'Devolver libro', date: testToday.addDays(-1)),
        const TaskDraft(title: 'De hoy', date: testToday),
      ],
    );

    expect(find.text('Tienes 2 tareas sin terminar'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('rollover-all')));
    await tester.pumpAndSettle();

    final moved = repository.all.where((t) => t.date == testToday);
    expect(moved.length, 3);
    expect(
      repository.all.firstWhere((t) => t.title == 'Pagar la luz').rolledFrom,
      testToday.addDays(-2),
    );
    expect(find.text('Pagar la luz'), findsOneWidget);
    expect(env.notifications.tagged.containsKey('task'), isTrue);
  });

  testWidgets('las tareas con hora programan una notificación', (tester) async {
    final (env, _) = await pumpTasks(
      tester,
      seeded: const [
        TaskDraft(title: 'Con hora', date: testToday, time: '18:00'),
        TaskDraft(title: 'Sin hora', date: testToday),
      ],
    );
    final scheduled = env.notifications.tagged['task']!;
    expect(scheduled.length, 1);
    expect(scheduled.single.body, 'Con hora');
    // 18:00 en Europe/Madrid (CEST) son las 16:00 UTC.
    expect(scheduled.single.whenUtc, DateTime.utc(2026, 9, 11, 16));
  });
}
