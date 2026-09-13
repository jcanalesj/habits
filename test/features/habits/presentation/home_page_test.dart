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
    // El asset se reutiliza en la mascota del header, así que la aserción
    // se acota a la tarjeta de racha.
    expect(
      find.descendant(
        of: find.byType(GeneralStreakCard),
        matching: find.image(const AssetImage('assets/images/cards/card1.png')),
      ),
      findsOneWidget,
    );
    expect(find.text('Beber agua'), findsOneWidget);
    expect(find.text('Anuales'), findsOneWidget);
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
    expect(find.textContaining('3 veces por semana'), findsOneWidget);
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

  testWidgets('con saldo se muestran los protectores de racha', (tester) async {
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

    expect(find.text('2 protectores de racha'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  group('Inicio: registrar, no editar', () {
    setUp(() {
      // La Home es larga: con el viewport por defecto (800x600) los botones
      // de registro quedan fuera de pantalla y no reciben taps.
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.implicitView!;
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

    testWidgets('toda la tarjeta registra sin llevar a la edición', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      // Sin chevron: al tocar cualquier punto de la tarjeta se registra;
      // editar sigue viviendo exclusivamente en la pestaña Hábitos.
      expect(
        find.descendant(
          of: find.byType(HabitListTile),
          matching: find.byIcon(Icons.chevron_right_rounded),
        ),
        findsNothing,
      );
      for (final tile in tester.widgetList<HabitListTile>(
        find.byType(HabitListTile),
      )) {
        expect(tile.mode, HabitTileMode.trackCompact);
      }
      final cardInkWell = tester.widget<InkWell>(
        find
            .descendant(
              of: find.byType(HabitListTile).first,
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(cardInkWell.onTap, isNotNull);

      await tester.tap(find.text('Beber agua'));
      await tester.pumpAndSettle();
      expect(find.text('Completados hoy (1)'), findsOneWidget);
    });

    testWidgets('las cards compactas no muestran la semana en Inicio', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      // El resumen semanal vive fuera de las cards compactas de Inicio.
      final monday = testToday.addDays(-(testToday.weekday - DateTime.monday));
      for (var i = 0; i < 7; i++) {
        final dot = find.byKey(
          ValueKey('habit-dot-agua-${monday.addDays(i).key}'),
        );
        expect(dot, findsNothing);
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
      final completedTopBefore = tester.getTopLeft(
        find.text('Completados hoy (5)'),
      );

      await tester.tap(find.byKey(const ValueKey('dismiss-all-done')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Todo hecho por hoy'), findsNothing);
      expect(find.text('Completados hoy (5)'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Completados hoy (5)')).dy,
        lessThan(completedTopBefore.dy),
      );
    });
  });

  testWidgets('la bienvenida de arranque se muestra y termina sola', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
    // Varios pumps cortos: deja llegar el primer HomeSummary sin agotar la
    // animación (pumpAndSettle la consumiría entera de una vez).
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }

    final welcome = find.byKey(const ValueKey('cold-start-welcome'));
    expect(welcome, findsOneWidget, reason: 'debe aparecer al arrancar');

    // A mitad de recorrido sigue visible: es una transición, no un flash.
    await tester.pump(ColdStartWelcome.duration ~/ 2);
    expect(welcome, findsOneWidget);

    // Y se retira sola al completarse, sin dejar la Home tapada.
    await tester.pump(ColdStartWelcome.duration);
    await tester.pumpAndSettle();
    expect(welcome, findsNothing);
    expect(find.text('Racha general'), findsOneWidget);
  });
}
