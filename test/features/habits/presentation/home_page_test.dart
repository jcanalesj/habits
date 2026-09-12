import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

import '../../../helpers/auth_test_helpers.dart';

Widget _appUnderTest({
  required Locale locale,
  bool seeded = true,
  WildcardBalance? wildcards,
}) {
  return ProviderScope(
    overrides: AuthTestEnv(
      initialUser: verifiedUser,
      seededHabits: seeded,
      wildcards: wildcards,
    ).overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    ),
  );
}

void main() {
  setUpAll(initializeTimezones);

  testWidgets('HomePage muestra la racha general y los hábitos', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('días consecutivos'), findsOneWidget);
    // Ya no existe el carrusel de rachas por ámbito (§29).
    expect(find.text('Rachas por ámbito'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Beber agua'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mis hábitos'), findsOneWidget);
    expect(find.text('Beber agua'), findsOneWidget);
  });

  testWidgets('HomePage shows the overall streak in English', (tester) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Overall streak'), findsOneWidget);
    expect(find.text('consecutive days'), findsOneWidget);
    expect(find.text('Streaks by area'), findsNothing);
  });

  testWidgets('HomePage muestra el progreso del objetivo, no una racha', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Entrenar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    // "Entrenar" está sembrado como 3 veces por semana.
    expect(find.text('3 veces por semana'), findsOneWidget);
    expect(find.textContaining('esta semana'), findsWidgets);
  });

  testWidgets('HomePage sin hábitos muestra el estado vacío y racha a cero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appUnderTest(locale: const Locale('es'), seeded: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Racha general'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.textContaining('Completa un hábito'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Aún no tienes hábitos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Aún no tienes hábitos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con saldo se muestran los comodines disponibles', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appUnderTest(
        locale: const Locale('es'),
        // Ya concedido este mes: así la concesión perezosa no lo altera.
        wildcards: WildcardBalance(
          available: 2,
          lastGrantYearMonth: testToday.yearMonth,
          grantedTotal: 2,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 comodines disponibles'), findsOneWidget);
  });

  group('Inicio: registrar, no editar', () {
    setUp(() {
      // La Home es larga: con el viewport por defecto (800x600) los botones
      // de registro quedan fuera de pantalla y no reciben taps.
      final view = TestWidgetsFlutterBinding.instance.platformDispatcher
          .implicitView!;
      view.physicalSize = const Size(1200, 3000);
      view.devicePixelRatio = 1;
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });
    });

    testWidgets('separa hábitos pendientes y completados de hoy', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      // El sembrado deja la semana hecha hasta ayer, así que hoy no hay
      // nada registrado: los 5 hábitos están pendientes.
      expect(find.text('Pendientes (5)'), findsOneWidget);
      expect(find.textContaining('Completados hoy'), findsNothing);
    });

    testWidgets('registrar un hábito lo mueve a completados', (tester) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('habit-track-agua')));
      await tester.pumpAndSettle();

      expect(find.text('Pendientes (4)'), findsOneWidget);
      expect(find.text('Completados hoy (1)'), findsOneWidget);
    });

    testWidgets('desmarcar lo devuelve a pendientes', (tester) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('habit-track-agua')));
      await tester.pumpAndSettle();
      expect(find.text('Completados hoy (1)'), findsOneWidget);

      // El mismo botón, ya en la sección de completados, deshace el registro.
      await tester.tap(find.byKey(const ValueKey('habit-track-agua')));
      await tester.pumpAndSettle();

      expect(find.text('Pendientes (5)'), findsOneWidget);
      expect(find.textContaining('Completados hoy'), findsNothing);
    });

    testWidgets('las filas de Inicio no llevan a la edición', (tester) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      // Sin chevron y sin acción de navegación: desde Inicio solo se
      // registra; editar vive en la pestaña Hábitos.
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      for (final tile in tester.widgetList<HabitListTile>(
        find.byType(HabitListTile),
      )) {
        expect(tile.mode, HabitTileMode.track);
      }
      final inkWells = tester.widgetList<InkWell>(
        find.descendant(
          of: find.byType(HabitListTile).first,
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWells.every((w) => w.onTap == null), isTrue);
    });

    testWidgets('la semana es solo historial en Inicio', (tester) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      // Ningún punto de la semana es pulsable: el único control es el botón.
      final monday = testToday.addDays(-(testToday.weekday - DateTime.monday));
      for (var i = 0; i < 7; i++) {
        final dot = find.byKey(
          ValueKey('habit-dot-agua-${monday.addDays(i).key}'),
        );
        expect(dot, findsOneWidget);
        final detector = tester.widget<GestureDetector>(
          find.descendant(of: dot, matching: find.byType(GestureDetector)),
        );
        expect(detector.onTap, isNull);
      }
    });

    testWidgets('con todo registrado muestra el estado de "todo hecho"', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      for (final id in ['agua', 'meditacion', 'entrenar', 'leer', 'ingles']) {
        await tester.tap(find.byKey(ValueKey('habit-track-$id')));
        await tester.pumpAndSettle();
      }

      expect(find.textContaining('Todo hecho por hoy'), findsOneWidget);
      expect(find.textContaining('Pendientes'), findsNothing);
      expect(find.text('Completados hoy (5)'), findsOneWidget);
    });
  });
}
