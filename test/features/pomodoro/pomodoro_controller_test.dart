import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/pomodoro/0_entity/entity.dart';
import 'package:habits/features/pomodoro/2_presentation/controllers/pomodoro_controller.dart';
import 'package:habits/features/pomodoro/2_presentation/providers/pomodoro_providers.dart';
import 'package:habits/features/pomodoro/3_data/data.dart';

import '../../helpers/auth_test_helpers.dart';

const copy = PomodoroCopy(
  workDoneTitle: 'Fin',
  workDoneBody: _body,
  breakDoneTitle: 'Fin descanso',
  breakDoneBody: _body,
);
String _body(int minutes) => '$minutes min';

({
  ProviderContainer container,
  AuthTestEnv env,
  InMemoryPomodoroRepository repo,
  InMemoryPomodoroStateStore store,
})
makeContainer({PomodoroConfig? config, PomodoroState? saved}) {
  final env = AuthTestEnv(initialUser: verifiedUser);
  final repo = InMemoryPomodoroRepository(config: config);
  final store = InMemoryPomodoroStateStore()..state = saved;
  final container = ProviderContainer(
    overrides: [
      ...env.overrides,
      pomodoroRepositoryProvider.overrideWithValue(repo),
      pomodoroStateStoreProvider.overrideWithValue(store),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(repo.dispose);
  return (container: container, env: env, repo: repo, store: store);
}

void main() {
  test(
    'empieza con la duración de concentración y programa el aviso',
    () async {
      final t = makeContainer();
      final controller = t.container.read(pomodoroControllerProvider.notifier);
      controller.copy = copy;
      expect(
        t.container.read(pomodoroControllerProvider).remainingSeconds,
        25 * 60,
      );

      controller.start();
      final state = t.container.read(pomodoroControllerProvider);
      expect(state.isRunning, isTrue);
      expect(state.endAtUtc, testInstant.add(const Duration(minutes: 25)));
      await Future<void>.delayed(Duration.zero);
      final scheduled = t.env.notifications.tagged['pomodoro']!;
      expect(
        scheduled.single.whenUtc,
        testInstant.add(const Duration(minutes: 25)),
      );
      expect(scheduled.single.body, '5 min');
      expect(t.store.state?.isRunning, isTrue);
    },
  );

  test('pausar guarda lo que queda y cancela el aviso', () async {
    final t = makeContainer();
    final controller = t.container.read(pomodoroControllerProvider.notifier);
    controller.copy = copy;
    controller.start();
    t.env.clock.instant = testInstant.add(const Duration(minutes: 10));
    controller.pause();
    await Future<void>.delayed(Duration.zero);
    final state = t.container.read(pomodoroControllerProvider);
    expect(state.isPaused, isTrue);
    expect(state.remainingSeconds, 15 * 60);
    expect(state.endAtUtc, isNull);
    expect(t.env.notifications.tagged.containsKey('pomodoro'), isFalse);

    // Reanudar recalcula el instante de fin desde "ahora".
    controller.start();
    expect(
      t.container.read(pomodoroControllerProvider).endAtUtc,
      testInstant.add(const Duration(minutes: 25)),
    );
  });

  test(
    'al volver de segundo plano con la fase vencida registra la sesión',
    () async {
      final t = makeContainer();
      final controller = t.container.read(pomodoroControllerProvider.notifier);
      controller.copy = copy;
      controller.setLabel('Tesis');
      controller.start();
      t.env.clock.instant = testInstant.add(const Duration(minutes: 26));
      controller.syncClock();
      await Future<void>.delayed(Duration.zero);

      expect(t.repo.sessions.length, 1);
      expect(t.repo.sessions.single.durationMinutes, 25);
      expect(t.repo.sessions.single.label, 'Tesis');
      expect(t.repo.sessions.single.startedAt, testInstant);
      expect(t.repo.sessions.single.day, testToday);
      final state = t.container.read(pomodoroControllerProvider);
      expect(state.phase, PomodoroPhase.shortBreak);
      expect(state.isIdle, isTrue);
      expect(state.remainingSeconds, 5 * 60);
      expect(state.completedInCycle, 1);
    },
  );

  test('saltar una fase de trabajo no registra sesión', () async {
    final t = makeContainer();
    final controller = t.container.read(pomodoroControllerProvider.notifier);
    controller.start();
    controller.skip();
    await Future<void>.delayed(Duration.zero);
    expect(t.repo.sessions, isEmpty);
    expect(
      t.container.read(pomodoroControllerProvider).phase,
      PomodoroPhase.shortBreak,
    );
  });

  test('tras el último pomodoro del ciclo toca descanso largo', () async {
    final t = makeContainer(config: const PomodoroConfig(pomodorosPerCycle: 2));
    final controller = t.container.read(pomodoroControllerProvider.notifier);
    controller.applyConfig(const PomodoroConfig(pomodorosPerCycle: 2));
    for (var i = 0; i < 2; i++) {
      controller.start();
      t.env.clock.instant = t.env.clock.nowUtc().add(
        const Duration(minutes: 26),
      );
      controller.syncClock();
      await Future<void>.delayed(Duration.zero);
      if (i == 0) {
        expect(
          t.container.read(pomodoroControllerProvider).phase,
          PomodoroPhase.shortBreak,
        );
        controller.skip();
      }
    }
    final state = t.container.read(pomodoroControllerProvider);
    expect(state.phase, PomodoroPhase.longBreak);
    expect(state.remainingSeconds, 15 * 60);
    expect(t.repo.sessions.length, 2);
  });

  test('recupera un temporizador guardado en marcha', () {
    final saved = PomodoroState(
      phase: PomodoroPhase.work,
      status: PomodoroStatus.running,
      totalSeconds: 1500,
      remainingSeconds: 1500,
      completedInCycle: 0,
      endAtUtc: testInstant.add(const Duration(minutes: 3)),
      label: 'Leer',
    );
    final t = makeContainer(saved: saved);
    final state = t.container.read(pomodoroControllerProvider);
    expect(state.isRunning, isTrue);
    expect(state.label, 'Leer');
  });
}
