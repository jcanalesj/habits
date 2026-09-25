import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/app_lifecycle.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/controllers/home_controller.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';

import '../../../helpers/auth_test_helpers.dart';

/// Deja pasar las microtareas y los `Future`s encolados (sincronización de
/// recordatorios, concesión de comodines…).
Future<void> settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthTestEnv env;
  late ProviderContainer container;

  setUp(() {
    env = AuthTestEnv(initialUser: verifiedUser);
    container = ProviderContainer(
      overrides: withoutForcedPremium(env.overrides),
    );
    addTearDown(container.dispose);
  });

  Future<void> buildHome() async {
    // Se mantiene escuchado: es autoDispose y sin oyente moriría al instante.
    container.listen(homeControllerProvider, (_, _) {});
    await container.read(homeControllerProvider.future);
    await settle();
  }

  group('recordatorios', () {
    test(
      'al construir la Home programa los avisos en la zona del perfil',
      () async {
        await buildHome();

        final notifications = env.notifications;
        expect(notifications.syncCalls, greaterThanOrEqualTo(1));
        expect(notifications.lastTimezone, testTimezone);
        // "Entrenar" es el único hábito sembrado con hora: tiene avisos en el
        // horizonte (hoy solo si su objetivo semanal no está ya cumplido).
        expect(
          notifications.scheduled.any((r) => r.habitId == 'entrenar'),
          isTrue,
        );
        expect(
          notifications.scheduled.every((r) => r.date.isAtOrAfter(testToday)),
          isTrue,
        );
      },
    );

    test('sin permiso no programa nada; al concederlo, reprograma', () async {
      env.notifications.permission = NotificationPermission.denied;
      await buildHome();

      expect(env.notifications.syncCalls, 0);
      expect(env.notifications.cancelAllCalls, greaterThanOrEqualTo(1));

      // El usuario concede el permiso en Ajustes y vuelve a la app.
      env.notifications.permission = NotificationPermission.granted;
      container.read(systemStateTickProvider.notifier).bump();
      await settle();

      expect(env.notifications.syncCalls, greaterThanOrEqualTo(1));
      expect(env.notifications.scheduled, isNotEmpty);
    });

    test('la misma Home no se reprograma dos veces', () async {
      await buildHome();
      final calls = env.notifications.syncCalls;

      // Un tick sin que cambie nada (permiso, zona, hábitos, día).
      container.read(systemStateTickProvider.notifier).bump();
      await settle();

      expect(env.notifications.syncCalls, calls);
    });
  });

  group('cambio de día', () {
    test('al volver a la app en otro día, "hoy" cambia', () async {
      container.listen(todayProvider, (_, _) {});
      expect(container.read(todayProvider), testToday);

      env.clock.instant = testInstant.add(const Duration(days: 1));
      container.read(systemStateTickProvider.notifier).bump();

      expect(container.read(todayProvider), testToday.next);
    });

    test(
      'marcar con la Home desfasada no escribe en el día anterior',
      () async {
        await buildHome();
        final controller = container.read(homeControllerProvider.notifier);

        // Pasa la medianoche con la Home todavía en "ayer".
        env.clock.instant = testInstant.add(const Duration(days: 1));
        final result = await controller.toggleToday('leer');

        expect(result, isNull);
        expect(
          await env.habits.fetchHabitLogs(
            'leer',
            from: testToday,
            to: testToday,
          ),
          isEmpty,
        );
        // Y la Home se ha pedido a sí misma el día correcto.
        await settle();
        expect(container.read(todayProvider), testToday.next);
      },
    );

    test('con la Home al día, marcar escribe en hoy', () async {
      await buildHome();
      final controller = container.read(homeControllerProvider.notifier);

      final result = await controller.toggleToday('leer');

      expect(result, isA<ToggleHabitCompletionSuccess>());
      expect(
        await env.habits.fetchHabitLogs('leer', from: testToday, to: testToday),
        hasLength(1),
      );
    });
  });
}
