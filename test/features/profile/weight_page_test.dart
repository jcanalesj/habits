import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/profile/weight/in_memory_weight_repository.dart';
import 'package:habits/features/profile/weight/weight_page.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';
import 'package:habits/features/profile/weight/weight_providers.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  testWidgets('muestra peso actual, objetivo, gráfica e historial', (
    tester,
  ) async {
    final repository = InMemoryWeightRepository();
    addTearDown(repository.dispose);
    await repository.addEntry(72.4, DateTime(2026, 9, 1));
    await repository.addEntry(71.8, DateTime(2026, 9, 10));
    await repository.updateGoal(68);

    await tester.pumpWidget(
      localizedApp(
        const WeightPage(),
        overrides: [weightRepositoryProvider.overrideWithValue(repository)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Peso'), findsOneWidget);
    expect(find.text('71.8 kg'), findsWidgets);
    expect(find.text('68 kg'), findsWidgets);
    expect(find.text('Evolución'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Historial'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('72.4 kg'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la primera vez completa el cuestionario y calcula calorías', (
    tester,
  ) async {
    final repository = InMemoryWeightRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      localizedApp(
        const WeightPage(),
        overrides: [weightRepositoryProvider.overrideWithValue(repository)],
      ),
    );
    await tester.pumpAndSettle();

    // Antes de pedir datos de salud, consentimiento explícito.
    expect(find.byKey(const ValueKey('weight-consent-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('weight-consent-accept')));
    await tester.pumpAndSettle();
    expect(find.text('¿Cuál es tu objetivo?'), findsOneWidget);
    expect(find.byKey(const ValueKey('weight-gym-cat')), findsOneWidget);
    expect(find.bySemanticsLabel('Gato deportista de Constanza'), findsWidgets);
    final onboardingDialog = find.byType(Dialog);
    expect(tester.getTopLeft(onboardingDialog), Offset.zero);
    expect(
      tester.getSize(onboardingDialog),
      tester.view.physicalSize / tester.view.devicePixelRatio,
    );

    Future<void> next() async {
      await tester.tap(find.byKey(const Key('weight-onboarding-next')));
      await tester.pumpAndSettle();
    }

    await next();
    await tester.enterText(find.byType(TextField).hitTestable(), '70,5');
    await tester.pump();
    await next();

    await tester.enterText(find.byType(TextField).hitTestable(), '65');
    await tester.pump();
    await next();

    final aboutFields = find.byType(TextField).hitTestable();
    expect(aboutFields, findsNWidgets(2));
    await tester.enterText(aboutFields.at(0), '30');
    await tester.enterText(aboutFields.at(1), '170');
    await tester.pump();
    await next();

    expect(find.text('Dato biológico para el cálculo'), findsOneWidget);
    await next();
    expect(find.text('¿Cómo es tu nivel de actividad?'), findsOneWidget);
    await next();

    expect(find.text('Tu estimación está lista'), findsOneWidget);
    expect(find.textContaining('kcal'), findsOneWidget);
    await next();
    await tester.pumpAndSettle();

    expect(repository.entries.single.kilograms, 70.5);
    expect(repository.profile?.goalKg, 65);
    expect(repository.profile?.age, 30);
    expect(repository.profile?.recommendedCalories, greaterThanOrEqualTo(1200));
    expect(find.text('70.5 kg'), findsWidgets);
  });

  testWidgets('un error de permisos no deja la pantalla cargando', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const WeightPage(),
        overrides: [
          weightEntriesProvider.overrideWith(
            (ref) => Stream.error(Exception('permission-denied')),
          ),
          weightGoalProvider.overrideWith((ref) => Stream.value(null)),
          weightProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('No hemos podido cargar'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('permite modificar el plan con los datos precargados', (
    tester,
  ) async {
    final repository = InMemoryWeightRepository();
    addTearDown(repository.dispose);
    await repository.addEntry(71.8, DateTime(2026, 9, 10));
    await repository.saveProfile(
      const WeightProfile(
        currentKg: 72,
        goalKg: 68,
        age: 31,
        heightCm: 170,
        sex: CalorieSex.female,
        activityLevel: ActivityLevel.moderate,
        goalType: WeightGoalType.lose,
        recommendedCalories: 1800,
      ),
    );

    await tester.pumpWidget(
      localizedApp(
        const WeightPage(),
        overrides: [weightRepositoryProvider.overrideWithValue(repository)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('weight-calories-card')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('1.800'), findsOneWidget);
    expect(find.text('Para tu objetivo'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('weight-modify-goals')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('weight-modify-goals')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('weight-onboarding-next')));
    await tester.pumpAndSettle();

    final currentField = tester.widget<TextField>(
      find.byType(TextField).hitTestable(),
    );
    expect(currentField.controller?.text, '71.8');
  });

  testWidgets('sin consentimiento no se piden datos de salud', (tester) async {
    final repository = InMemoryWeightRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      localizedApp(
        const WeightPage(),
        overrides: [weightRepositoryProvider.overrideWithValue(repository)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('weight-consent-decline')));
    await tester.pumpAndSettle();

    expect(find.text('¿Cuál es tu objetivo?'), findsNothing);
    expect(repository.profile, isNull);
  });
}
