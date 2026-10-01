import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/repositories/notifications_repository.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';
import 'package:habits/features/steps/2_presentation/controllers/steps_controller.dart';
import 'package:habits/features/steps/2_presentation/pages/steps_page.dart';
import 'package:habits/features/steps/2_presentation/providers/steps_providers.dart';
import 'package:habits/features/steps/3_data/data.dart';
import 'package:habits/local_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_test_helpers.dart';

const _labels = StepsLiveNotificationLabels(
  title: '{n} pasos',
  kcal: '{n} kcal',
  km: '{n} km',
  goal: 'Objetivo {n}',
  goalReached: '¡Objetivo conseguido!',
  channelName: 'Pasos en directo',
  channelDescription: 'Notificación fija con los pasos de hoy.',
);

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  group('StepsLiveNotificationController', () {
    ({
      ProviderContainer container,
      FakeStepsLiveNotification live,
      InMemoryStepsRepository repo,
      AuthTestEnv env,
    })
    setUp({
      StepsLiveNotificationResult result = StepsLiveNotificationResult.started,
      NotificationPermission permission = NotificationPermission.granted,
      bool enabled = false,
    }) {
      final env = AuthTestEnv(initialUser: verifiedUser)
        ..notifications.permission = permission;
      final live = env.stepsLiveNotification
        ..supported = true
        ..result = result
        ..enabled = enabled;
      final repo = InMemoryStepsRepository(
        config: const StepsConfig(consented: true, goal: 6000),
      );
      final container = ProviderContainer(
        overrides: [
          ...env.overrides,
          stepsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(repo.dispose);
      // Como la página de Pasos: con un observador el provider está activo
      // y mantiene vivas sus dependencias (en Riverpod 3, sin observadores
      // queda en pausa).
      container.listen(stepsLiveNotificationEnabledProvider, (_, _) {});
      return (container: container, live: live, repo: repo, env: env);
    }

    test(
      'enciende con la configuración del usuario y sigue los cambios',
      () async {
        final t = setUp();
        final controller = t.container.read(
          stepsLiveNotificationEnabledProvider.notifier,
        );
        expect(
          await t.container.read(stepsLiveNotificationEnabledProvider.future),
          isFalse,
        );
        // La configuración de pasos tiene que haber llegado.
        await t.container.read(stepsConfigProvider.future);

        final result = await controller.enable(
          labels: _labels,
          locale: 'es-ES',
        );
        expect(result, StepsLiveNotificationResult.started);
        expect(
          t.container.read(stepsLiveNotificationEnabledProvider).value,
          isTrue,
        );
        final config = t.live.started.single;
        expect(config.userId, verifiedUser.id);
        expect(config.goal, 6000);
        expect(config.timezone, testTimezone);
        expect(config.locale, 'es-ES');
        expect(config.strideMeters, StepsEstimator.defaultStrideMeters);
        expect(config.labels.title, '{n} pasos');

        // Objetivo nuevo: el servicio recibe la configuración actualizada.
        await t.repo.saveConfig(const StepsConfig(consented: true, goal: 9000));
        await _settle();
        expect(t.live.updated, isNotEmpty);
        expect(t.live.updated.last.goal, 9000);

        await controller.disable();
        expect(t.live.stopCount, 1);
        expect(
          t.container.read(stepsLiveNotificationEnabledProvider).value,
          isFalse,
        );
      },
    );

    test('sin permiso de notificaciones no arranca nada', () async {
      final t = setUp(permission: NotificationPermission.denied);
      final controller = t.container.read(
        stepsLiveNotificationEnabledProvider.notifier,
      );
      await t.container.read(stepsLiveNotificationEnabledProvider.future);

      final result = await controller.enable(labels: _labels, locale: 'es');
      expect(result, StepsLiveNotificationResult.notificationsDenied);
      expect(t.live.started, isEmpty);
      expect(
        t.container.read(stepsLiveNotificationEnabledProvider).value,
        isFalse,
      );
    });

    test('refleja lo que el lado nativo dice al arrancar', () async {
      final t = setUp(enabled: true);
      expect(
        await t.container.read(stepsLiveNotificationEnabledProvider.future),
        isTrue,
      );
    });
  });

  group('StepsController con el servicio nativo', () {
    test('toma el libro escrito desde fuera antes de contar', () async {
      final env = AuthTestEnv(initialUser: verifiedUser);
      final repo = InMemoryStepsRepository(
        config: const StepsConfig(consented: true),
      );
      final source = FakePedometerSource();
      // El servicio nativo ha ido contando con la app cerrada.
      final ledger = InMemoryStepLedgerStore()
        ..onDisk = StepLedgerState(
          lastCounter: 70000,
          dayKey: testToday.key,
          todaySteps: 4321,
        ).toJson();
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

      container.listen(stepsControllerProvider, (_, _) {});
      await _settle();
      await _settle();
      final state = container.read(stepsControllerProvider);
      expect(state.status, StepsStatus.counting);
      expect(state.todaySteps, 4321);

      // Con el servicio activo las lecturas llegan ya como pasos del día.
      source.emit(PedometerSample(at: testInstant, steps: 4400));
      await _settle();
      expect(container.read(stepsControllerProvider).todaySteps, 4400);
    });
  });

  group('StepsPage', () {
    Future<FakeStepsLiveNotification> pumpSteps(
      WidgetTester tester, {
      bool supported = true,
    }) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final env = AuthTestEnv(initialUser: verifiedUser);
      final pedometer = FakePedometerSource();
      final repo = InMemoryStepsRepository(
        config: const StepsConfig(consented: true),
      );
      final live = env.stepsLiveNotification..supported = supported;
      addTearDown(repo.dispose);
      addTearDown(pedometer.dispose);
      await tester.pumpWidget(
        localizedApp(
          const StepsPage(),
          overrides: [
            ...env.overrides,
            sharedPreferencesProvider.overrideWithValue(preferences),
            stepsRepositoryProvider.overrideWithValue(repo),
            pedometerSourceProvider.overrideWithValue(pedometer),
            stepLedgerStoreProvider.overrideWithValue(
              InMemoryStepLedgerStore(),
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      return live;
    }

    testWidgets('el interruptor enciende la notificación fija', (tester) async {
      final live = await pumpSteps(tester);
      final toggle = find.byKey(const ValueKey('steps-live-notification'));
      await tester.scrollUntilVisible(
        toggle,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pasos en la barra de notificaciones'), findsOneWidget);

      await tester.tap(toggle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(live.started, hasLength(1));
      expect(live.started.single.labels.goal, 'Objetivo {n}');
      expect(live.started.single.labels.title, '{n} pasos');
      expect(tester.widget<Switch>(toggle).value, isTrue);
    });

    testWidgets('donde no existe, el interruptor no aparece', (tester) async {
      await pumpSteps(tester, supported: false);
      expect(
        find.byKey(const ValueKey('steps-live-notification')),
        findsNothing,
      );
    });
  });
}
