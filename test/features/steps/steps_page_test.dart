import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/2_presentation/pages/steps_page.dart';
import 'package:habits/features/steps/2_presentation/providers/steps_providers.dart';
import 'package:habits/features/steps/3_data/data.dart';
import 'package:habits/local_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  Future<(FakePedometerSource, InMemoryStepsRepository)> pumpSteps(
    WidgetTester tester, {
    StepsConfig config = const StepsConfig(consented: true),
    Iterable<StepsDay> seeded = const [],
    FakePedometerSource? source,
  }) async {
    // Pantalla alta: la página es larga y así los botones quedan a la vista.
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final env = AuthTestEnv(initialUser: verifiedUser);
    final pedometer = source ?? FakePedometerSource();
    final repo = InMemoryStepsRepository(config: config, seeded: seeded);
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
          stepLedgerStoreProvider.overrideWithValue(InMemoryStepLedgerStore()),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return (pedometer, repo);
  }

  testWidgets('cuenta en vivo y muestra distancia, calorías y evolución', (
    tester,
  ) async {
    final (source, _) = await pumpSteps(
      tester,
      seeded: [
        StepsDay(day: testToday.previous, steps: 9100),
        StepsDay(day: testToday.addDays(-2), steps: 4200),
      ],
    );
    source.emit(PedometerSample(at: testInstant, steps: 6240));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('6.240'), findsOneWidget);
    expect(find.text('de 8.000'), findsOneWidget);
    expect(find.text('Te faltan 1.760 pasos'), findsOneWidget);
    expect(find.text('4,6 km'), findsOneWidget);
    expect(find.textContaining('kcal'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Tu evolución'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Tu evolución'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(ValueKey('steps-day-${testToday.previous.key}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('9.100 pasos'), findsOneWidget);
    // Cierra el temporizador de guardado pendiente.
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('pide consentimiento la primera vez y luego el permiso', (
    tester,
  ) async {
    final source = FakePedometerSource(
      permission: PedometerPermission.notDetermined,
    );
    final (_, repo) = await pumpSteps(
      tester,
      config: const StepsConfig(),
      source: source,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('steps-consent-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('steps-consent-accept')));
    await tester.pumpAndSettle();
    expect(repo.config.consented, isTrue);
    expect(source.requestCount, 1);
    expect(find.byKey(const ValueKey('steps-today')), findsOneWidget);
  });

  testWidgets('felicita con el gato al cumplir el objetivo', (tester) async {
    final (source, _) = await pumpSteps(tester);
    source.emit(PedometerSample(at: testInstant, steps: 8100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.byKey(const ValueKey('steps-celebration-dialog')),
      findsOneWidget,
    );
    expect(find.text('¡Enhorabuena!'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('steps-celebration-ok')));
    await tester.pump(const Duration(seconds: 5));
    expect(
      find.byKey(const ValueKey('steps-celebration-dialog')),
      findsNothing,
    );
    // No vuelve a felicitar el mismo día.
    source.emit(PedometerSample(at: testInstant, steps: 8200));
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.byKey(const ValueKey('steps-celebration-dialog')),
      findsNothing,
    );
  });

  testWidgets('cambia el objetivo', (tester) async {
    final (source, repo) = await pumpSteps(tester);
    source.emit(PedometerSample(at: testInstant, steps: 100));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const ValueKey('steps-change-goal')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('steps-goal-plus')));
    await tester.tap(find.byKey(const ValueKey('steps-goal-plus')));
    await tester.pumpAndSettle();
    expect(find.text('9.000'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('steps-goal-save')));
    await tester.pumpAndSettle();
    expect(repo.config.goal, 9000);
    expect(find.text('de 9.000'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
