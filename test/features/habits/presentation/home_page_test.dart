import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/weight/in_memory_weight_repository.dart';
import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_providers.dart';
import 'package:habits/local_preferences.dart';
import 'package:habits/localization/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/auth_test_helpers.dart';

Widget _appUnderTest({
  required Locale locale,
  bool seeded = true,
  WildcardBalance? wildcards,
  List<WeightEntry> weightEntries = const [],
  bool weightConfigured = true,
  SharedPreferences? preferences,
}) {
  final weightRepository = InMemoryWeightRepository()
    ..entries.addAll(weightEntries);
  if (weightConfigured && weightRepository.entries.isEmpty) {
    weightRepository.entries.add(
      WeightEntry(id: 'default-weight', kilograms: 72, recordedAt: testInstant),
    );
  }
  return ProviderScope(
    overrides: withoutForcedPremium([
      ...AuthTestEnv(
        initialUser: verifiedUser,
        seededHabits: seeded,
        wildcards: wildcards,
      ).overrides,
      weightRepositoryProvider.overrideWithValue(weightRepository),
      if (preferences != null)
        sharedPreferencesProvider.overrideWithValue(preferences),
    ]),
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    ),
  );
}

InMemoryWeightRepository _configuredWeightRepository() =>
    InMemoryWeightRepository()
      ..entries.add(
        WeightEntry(
          id: 'default-weight',
          kilograms: 72,
          recordedAt: testInstant,
        ),
      );

Widget _streakCardAtHour(int hour) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: GeneralStreakCard(
      streak: StreakState.empty,
      wildcards: WildcardBalance.empty,
      deviceHour: hour,
    ),
  ),
);

void main() {
  setUpAll(initializeTimezones);

  testWidgets('la tarjeta usa la escena correspondiente a cada franja', (
    tester,
  ) async {
    const scenes = {
      0: 'assets/images/cards/00:00-5:00.png',
      6: 'assets/images/cards/6:00-8:00.png',
      9: 'assets/images/cards/9:00-12:00.png',
      13: 'assets/images/cards/13:00-15:00.png',
      16: 'assets/images/cards/16:00-18:00.png',
      19: 'assets/images/cards/19:00-20:00.png',
      21: 'assets/images/cards/21:00-23:00.png',
    };

    for (final MapEntry(key: hour, value: asset) in scenes.entries) {
      await tester.pumpWidget(_streakCardAtHour(hour));
      await tester.pump();
      expect(find.image(AssetImage(asset)), findsOneWidget);
    }
  });

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
        matching: find.image(
          AssetImage(switch (DateTime.now().hour) {
            < 6 => 'assets/images/cards/00:00-5:00.png',
            < 9 => 'assets/images/cards/6:00-8:00.png',
            < 13 => 'assets/images/cards/9:00-12:00.png',
            < 16 => 'assets/images/cards/13:00-15:00.png',
            < 19 => 'assets/images/cards/16:00-18:00.png',
            < 21 => 'assets/images/cards/19:00-20:00.png',
            _ => 'assets/images/cards/21:00-23:00.png',
          }),
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Beber agua'), findsOneWidget);
    expect(find.text('Anuales'), findsOneWidget);
  });

  testWidgets('HomePage muestra el último peso y su variación', (tester) async {
    await tester.pumpWidget(
      _appUnderTest(
        locale: const Locale('es'),
        weightEntries: [
          WeightEntry(
            id: 'latest',
            kilograms: 71.8,
            recordedAt: DateTime(2026, 9, 25),
          ),
          WeightEntry(
            id: 'previous',
            kilograms: 72.4,
            recordedAt: DateTime(2026, 9, 18),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-weight-card')), findsOneWidget);
    expect(find.text('71,8 kg'), findsOneWidget);
    expect(find.text('0,6 kg'), findsOneWidget);
  });

  testWidgets('sin peso muestra la invitación y no muestra la tarjeta', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appUnderTest(locale: const Locale('es'), weightConfigured: false),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('weight-invitation-dialog')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-weight-card')), findsNothing);
    expect(find.text('Configurar mi peso'), findsOneWidget);
    expect(find.text('Ahora no'), findsOneWidget);
    expect(find.text('No volver a mostrar'), findsOneWidget);
  });

  testWidgets('no volver a mostrar guarda la decisión para ese usuario', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      _appUnderTest(
        locale: const Locale('es'),
        weightConfigured: false,
        preferences: preferences,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('weight-invitation-never')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('weight-invitation-dialog')),
      findsNothing,
    );
    expect(
      preferences.getBool('weight_invitation_hidden_${verifiedUser.id}'),
      isTrue,
    );
  });

  testWidgets('Nuevo hábito muestra Premium cuando ya hay 5 hábitos', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-new-habit')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('home-new-habit')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('premium-habit-limit-dialog')),
      findsOneWidget,
    );
    expect(find.text('Desbloquea más hábitos con Premium'), findsOneWidget);
  });

  testWidgets('HomePage shows the overall streak in English', (tester) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Overall streak'), findsOneWidget);
    expect(find.text('consecutive days'), findsOneWidget);
    expect(find.text('Streaks by area'), findsNothing);
  });

  testWidgets('la tarjeta de racha se puede reducir y volver a ampliar', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
    await tester.pumpAndSettle();

    final expandedHeight = tester
        .getSize(find.byType(GeneralStreakCard))
        .height;
    await tester.tap(find.byKey(const Key('collapse-streak-card')));
    await tester.pumpAndSettle();

    final compactHeight = tester.getSize(find.byType(GeneralStreakCard)).height;
    expect(compactHeight, lessThan(expandedHeight / 2));
    expect(find.byKey(const Key('expand-streak-card')), findsOneWidget);

    await tester.tap(find.byKey(const Key('expand-streak-card')));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(GeneralStreakCard)).height,
      expandedHeight,
    );
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
    expect(find.textContaining('/ 3'), findsOneWidget);
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

    testWidgets('la card abre edición y solo el control registra', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnderTest(locale: const Locale('es')));
      await tester.pumpAndSettle();

      // Sin chevron: toda la superficie libre de la card abre la edición.
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
      expect(find.text('Editar hábito'), findsOneWidget);
      expect(find.text('Pendientes (5)'), findsOneWidget);
      expect(find.textContaining('Completados hoy'), findsNothing);
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

  testWidgets('no muestra la bienvenida si Firebase la desactiva', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser, seededHabits: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: withoutForcedPremium([
          ...env.overrides,
          remoteWelcomeAnimationEnabledProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
          weightRepositoryProvider.overrideWithValue(
            _configuredWeightRepository(),
          ),
        ]),
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cold-start-welcome')), findsNothing);
    expect(find.text('Racha general'), findsOneWidget);
  });

  testWidgets('rota las frases personalizadas bajo el saludo', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser, seededHabits: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: withoutForcedPremium([
          ...env.overrides,
          remoteWelcomeAnimationEnabledProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
          remoteCustomMotivationMessagesProvider.overrideWith(
            (ref) => Stream.value(const ['Primera frase', 'Segunda frase']),
          ),
          weightRepositoryProvider.overrideWithValue(
            _configuredWeightRepository(),
          ),
        ]),
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Primera frase'), findsOneWidget);
    await tester.pump(const Duration(seconds: 12));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Segunda frase'), findsOneWidget);

    await tester.pump(const Duration(seconds: 12));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Un pequeño paso también cuenta.'), findsOneWidget);
  });
}
