import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';
import 'package:habits/features/steps/2_presentation/controllers/steps_controller.dart';
import 'package:habits/features/steps/2_presentation/providers/steps_providers.dart';
import 'package:habits/features/steps/2_presentation/widgets/steps_history.dart';
import 'package:habits/features/steps/3_data/data.dart';

import '../../helpers/auth_test_helpers.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  final calendar = LogicalCalendar(testTimezone);

  group('StepLedger (contador acumulado de Android)', () {
    test('la primera lectura fija la referencia sin sumar', () {
      final state = StepLedger.apply(const StepLedgerState(), 5000, testToday);
      expect(state.todaySteps, 0);
      expect(state.lastCounter, 5000);
    });

    test('suma la diferencia dentro del mismo día', () {
      var state = StepLedger.apply(const StepLedgerState(), 5000, testToday);
      state = StepLedger.apply(state, 5120, testToday);
      state = StepLedger.apply(state, 5300, testToday);
      expect(state.todaySteps, 300);
    });

    test('un reinicio del móvil (contador menor) cuenta todo como nuevo', () {
      var state = StepLedger.apply(const StepLedgerState(), 5000, testToday);
      state = StepLedger.apply(state, 40, testToday);
      expect(state.todaySteps, 40);
    });

    test('al cambiar de día empieza de cero con la diferencia', () {
      var state = StepLedger.apply(const StepLedgerState(), 5000, testToday);
      state = StepLedger.apply(state, 5500, testToday);
      state = StepLedger.apply(state, 5800, testToday.next);
      expect(state.dayKey, testToday.next.key);
      expect(state.todaySteps, 300);
    });

    test('se serializa y recupera', () {
      const state = StepLedgerState(
        lastCounter: 9,
        dayKey: '2026-09-11',
        todaySteps: 3,
      );
      expect(StepLedgerState.fromJson(state.toJson()), state);
    });
  });

  group('StepsEstimator', () {
    test('distancia y calorías con y sin perfil', () {
      expect(StepsEstimator.distanceMeters(1000), 740);
      expect(StepsEstimator.distanceMeters(1000, heightCm: 180), 745);
      expect(StepsEstimator.calories(1000), 40);
      expect(StepsEstimator.calories(1000, weightKg: 90), 51);
    });
  });

  group('StepsHistorySummary', () {
    test('totales, mejor día, días con objetivo y racha', () {
      final days = [
        StepsDay(day: testToday.addDays(-3), steps: 9000),
        StepsDay(day: testToday.addDays(-2), steps: 8100),
        StepsDay(day: testToday.addDays(-1), steps: 12000),
        StepsDay(day: testToday, steps: 500),
      ];
      final summary = StepsHistorySummary.of(days, 8000);
      expect(summary.totalSteps, 29600);
      expect(summary.dailyAverage, 7400);
      expect(summary.bestDay!.steps, 12000);
      expect(summary.goalDays, 3);
      // Hoy aún no cumple: la racha vigente termina ayer.
      expect(StepsHistorySummary.goalStreak(days, 8000, testToday), 3);
      final withToday = [
        ...days.take(3),
        StepsDay(day: testToday, steps: 8000),
      ];
      expect(StepsHistorySummary.goalStreak(withToday, 8000, testToday), 4);
      expect(StepsChartBuilder.monthly(days).single.$2, 29600);
    });
  });

  group('StepsController', () {
    ({
      ProviderContainer container,
      FakePedometerSource source,
      InMemoryStepsRepository repo,
      InMemoryStepLedgerStore ledger,
    })
    make({
      StepsConfig? config,
      Iterable<StepsDay> seeded = const [],
      FakePedometerSource? sourceOverride,
    }) {
      final env = AuthTestEnv(initialUser: verifiedUser);
      final source = sourceOverride ?? FakePedometerSource();
      final repo = InMemoryStepsRepository(
        config: config ?? const StepsConfig(consented: true),
        seeded: seeded,
      );
      final ledger = InMemoryStepLedgerStore();
      final container = ProviderContainer(
        overrides: [
          ...env.overrides,
          stepsRepositoryProvider.overrideWithValue(repo),
          pedometerSourceProvider.overrideWithValue(source),
          stepLedgerStoreProvider.overrideWithValue(ledger),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(repo.dispose);
      addTearDown(source.dispose);
      return (container: container, source: source, repo: repo, ledger: ledger);
    }

    test('sin consentimiento no toca el sensor', () async {
      final t = make(
        config: const StepsConfig(),
        sourceOverride: FakePedometerSource(
          permission: PedometerPermission.notDetermined,
        ),
      );
      final sub = t.container.listen(stepsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await settle();
      expect(
        t.container.read(stepsControllerProvider).status,
        StepsStatus.needsConsent,
      );
      expect(t.source.requestCount, 0);
    });

    test(
      'con permiso cuenta en vivo (iOS: pasos absolutos del día) y guarda',
      () async {
        final t = make();
        final sub = t.container.listen(stepsControllerProvider, (_, _) {});
        addTearDown(sub.close);
        await t.container.read(stepsConfigProvider.future);
        await settle();
        expect(
          t.container.read(stepsControllerProvider).status,
          StepsStatus.counting,
        );
        expect(t.source.lastDayStart, calendar.startOfDayUtc(testToday));

        t.source.emit(
          PedometerSample(at: testInstant, steps: 6240, distanceMeters: 4700),
        );
        await settle();
        final state = t.container.read(stepsControllerProvider);
        expect(state.todaySteps, 6240);
        expect(state.todayDistanceMeters, 4700);
        expect(state.progress, closeTo(.78, .01));

        await Future<void>.delayed(
          StepsController.saveDelay + const Duration(milliseconds: 50),
        );
        expect(t.repo.days[testToday]!.steps, 6240);
      },
    );

    test(
      'Android: el acumulado del sensor se reparte con el libro diario',
      () async {
        final t = make();
        final sub = t.container.listen(stepsControllerProvider, (_, _) {});
        addTearDown(sub.close);
        await t.container.read(stepsConfigProvider.future);
        await settle();
        t.source.emit(PedometerSample(at: testInstant, counter: 100000));
        t.source.emit(PedometerSample(at: testInstant, counter: 100250));
        await settle();
        expect(t.container.read(stepsControllerProvider).todaySteps, 250);
        expect(StepLedgerState.fromJson(t.ledger.json!).lastCounter, 100250);
      },
    );

    test('arranca con lo guardado hoy y nunca baja', () async {
      final t = make(seeded: [StepsDay(day: testToday, steps: 3000)]);
      final sub = t.container.listen(stepsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await t.container.read(storedStepsDaysProvider.future);
      await settle();
      // El provider arrancó antes de que llegara lo guardado: se reconstruye.
      t.container.invalidate(stepsControllerProvider);
      await settle();
      expect(t.container.read(stepsControllerProvider).todaySteps, 3000);
      t.source.emit(PedometerSample(at: testInstant, steps: 200));
      await settle();
      expect(t.container.read(stepsControllerProvider).todaySteps, 3000);
    });

    test('Android continúa sumando desde un total remoto mayor', () async {
      final t = make(seeded: [StepsDay(day: testToday, steps: 6842)]);
      final sub = t.container.listen(stepsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await t.container.read(storedStepsDaysProvider.future);
      await settle();
      t.container.invalidate(stepsControllerProvider);
      await settle();

      t.source.emit(PedometerSample(at: testInstant, counter: 23595));
      t.source.emit(PedometerSample(at: testInstant, counter: 23596));
      await settle();

      expect(t.container.read(stepsControllerProvider).todaySteps, 6843);
      expect(StepLedgerState.fromJson(t.ledger.json!).todaySteps, 6843);
    });

    test(
      'sin permiso lo pide al solicitarlo y rellena el historial en iOS',
      () async {
        final source = FakePedometerSource(
          permission: PedometerPermission.notDetermined,
          history: {calendar.startOfDayUtc(testToday.previous): 7000},
        );
        final t = make(sourceOverride: source);
        final sub = t.container.listen(stepsControllerProvider, (_, _) {});
        addTearDown(sub.close);
        await t.container.read(stepsConfigProvider.future);
        await settle();
        expect(
          t.container.read(stepsControllerProvider).status,
          StepsStatus.noPermission,
        );

        await t.container
            .read(stepsControllerProvider.notifier)
            .requestPermission();
        await settle();
        expect(source.requestCount, 1);
        expect(
          t.container.read(stepsControllerProvider).status,
          StepsStatus.counting,
        );
        expect(t.repo.days[testToday.previous]!.steps, 7000);
      },
    );

    test('sin sensor queda como no disponible', () async {
      final t = make(sourceOverride: FakePedometerSource(available: false));
      final sub = t.container.listen(stepsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await t.container.read(stepsConfigProvider.future);
      await settle();
      expect(
        t.container.read(stepsControllerProvider).status,
        StepsStatus.unavailable,
      );
    });
  });
}
