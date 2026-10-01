import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';
import 'package:habits/features/habits/2_presentation/pages/statistics_page.dart';
import 'package:habits/features/onboarding/guided_tour.dart';
import 'package:habits/features/onboarding/onboarding_tour_preferences.dart';
import 'package:habits/features/profile/weight/in_memory_weight_repository.dart';
import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_providers.dart';
import 'package:habits/features/splash/2_presentation/pages/splash_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';
import 'package:habits/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_test_helpers.dart';

final _tour = find.byKey(const ValueKey('guided-tour'));
final _next = find.byKey(const ValueKey('guided-tour-next'));
final _skip = find.byKey(const ValueKey('guided-tour-skip'));

/// App real (router, shell y páginas) con un usuario verificado.
Future<void> _pumpApp(
  WidgetTester tester, {
  required OnboardingTourPreferences tourPreferences,
  bool weightConfigured = false,
  bool seededHabits = true,
}) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.platformDispatcher.localeTestValue = const Locale('es');
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  final env = AuthTestEnv(
    initialUser: verifiedUser,
    seededHabits: seededHabits,
  );
  // Con peso registrado no aparece la invitación de peso, que taparía la
  // pantalla en los tests que no arrancan el recorrido.
  final weightRepository = InMemoryWeightRepository();
  if (weightConfigured) {
    weightRepository.entries.add(
      WeightEntry(id: 'w', kilograms: 72, recordedAt: testInstant),
    );
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: withoutForcedPremium([
        ...env.overrides,
        weightRepositoryProvider.overrideWithValue(weightRepository),
        onboardingTourPreferencesProvider.overrideWithValue(tourPreferences),
      ]),
      child: const HabitsApp(),
    ),
  );
  // Splash completo, restauración de sesión y bienvenida de arranque.
  await tester.pump(SplashPage.duration + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

Widget _homeUnderTest({required OnboardingTourPreferences tourPreferences}) {
  final env = AuthTestEnv(initialUser: verifiedUser);
  return ProviderScope(
    overrides: withoutForcedPremium([
      ...env.overrides,
      weightRepositoryProvider.overrideWithValue(InMemoryWeightRepository()),
      onboardingTourPreferencesProvider.overrideWithValue(tourPreferences),
    ]),
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    ),
  );
}

void main() {
  setUpAll(() {
    initializeTimezones();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('OnboardingTourPreferences', () {
    test('la copia en SharedPreferences recuerda por usuario', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = SharedOnboardingTourPreferences(
        await SharedPreferences.getInstance(),
      );

      expect(preferences.isSeen('a'), isFalse);
      await preferences.markSeen('a');
      expect(preferences.isSeen('a'), isTrue);
      expect(preferences.isSeen('b'), isFalse);
    });

    test('en memoria se puede dar por visto para todos', () async {
      final seen = MemoryOnboardingTourPreferences(seenByDefault: true);
      expect(seen.isSeen('a'), isTrue);

      final fresh = MemoryOnboardingTourPreferences();
      expect(fresh.isSeen('a'), isFalse);
      await fresh.markSeen('a');
      expect(fresh.isSeen('a'), isTrue);
    });

    test('la sesión solo concede el tutorial una vez', () {
      final session = OnboardingTourSession();
      expect(session.take(), isTrue);
      expect(session.take(), isFalse);
    });
  });

  group('GuidedTourController', () {
    test('sin hábitos usa datos de ejemplo y termina tras el último', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(guidedTourProvider.notifier);

      expect(container.read(guidedTourProvider), isNull);
      expect(container.read(guidedTourDemoDataProvider), isFalse);
      controller.next();
      expect(container.read(guidedTourProvider), isNull);

      controller.start(hasHabits: true);
      expect(controller.usesDemoData, isFalse);
      expect(container.read(guidedTourDemoDataProvider), isFalse);
      controller.finish();

      controller.start(hasHabits: false);
      expect(controller.usesDemoData, isTrue);
      expect(container.read(guidedTourDemoDataProvider), isTrue);
      expect(controller.steps, GuidedTourStep.values);
      expect(controller.isFirst, isTrue);

      controller.previous();
      expect(container.read(guidedTourProvider), 0);
      for (var i = 0; i < controller.steps.length - 1; i++) {
        expect(container.read(guidedTourProvider), i);
        controller.next();
      }
      expect(controller.isLast, isTrue);
      controller.previous();
      expect(container.read(guidedTourProvider), controller.steps.length - 2);
      controller.next();
      controller.next();
      expect(container.read(guidedTourProvider), isNull);
      expect(container.read(guidedTourDemoDataProvider), isFalse);
    });
  });

  group('Recorrido guiado sobre la app real', () {
    testWidgets('recorre las pantallas y vuelve a Inicio al terminar', (
      tester,
    ) async {
      final preferences = MemoryOnboardingTourPreferences();
      await _pumpApp(tester, tourPreferences: preferences);

      // Bienvenida centrada, sin foco todavía.
      expect(_tour, findsOneWidget);
      expect(find.text('1 de 10'), findsOneWidget);
      expect(find.text('¡Bienvenido a Constanza!'), findsOneWidget);
      expect(find.text('Empezar'), findsOneWidget);
      expect(find.byKey(const ValueKey('guided-tour-previous')), findsNothing);
      expect(preferences.isSeen(verifiedUser.id), isTrue);
      // El recorrido ya presenta el peso: la invitación no se encadena.
      expect(
        find.byKey(const ValueKey('weight-invitation-never')),
        findsNothing,
      );

      // Crear hábitos: foco en el botón de Inicio. Tocar el foco avanza.
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('2 de 10'), findsOneWidget);
      expect(find.text('Crea tus hábitos'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-new-habit')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('guided-tour-focus')));
      await tester.pumpAndSettle();

      // Marcar un hábito: solo porque la cuenta ya tiene hábitos.
      expect(find.text('3 de 10'), findsOneWidget);
      expect(find.text('Marca lo que hagas hoy'), findsOneWidget);

      // "Anterior" y el botón atrás del sistema retroceden un paso.
      await tester.tap(find.byKey(const ValueKey('guided-tour-previous')));
      await tester.pumpAndSettle();
      expect(find.text('2 de 10'), findsOneWidget);
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('3 de 10'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('2 de 10'), findsOneWidget);
      expect(_tour, findsOneWidget);
      await tester.tap(_next);
      await tester.pumpAndSettle();

      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('4 de 10'), findsOneWidget);
      expect(find.text('Tu racha y tus protectores'), findsOneWidget);

      // Calendarios: navega a la pestaña Mis hábitos.
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('Consulta tus calendarios'), findsOneWidget);
      expect(find.byKey(const ValueKey('edit-habits-action')), findsOneWidget);

      // Dejar hábitos: lista de hábitos en la pestaña de dejar.
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('Deja un hábito'), findsOneWidget);
      expect(find.text('Dejar hábitos'), findsWidgets);

      // Peso: Perfil con la fila de peso a la vista.
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('Registra tu peso'), findsOneWidget);
      expect(find.text('Peso y objetivos'), findsOneWidget);

      // Herramientas.
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('Herramientas para tu día a día'), findsOneWidget);
      expect(find.byKey(const ValueKey('tools-panel')), findsOneWidget);

      // Estadísticas: foco en las barras de progreso por hábito, reales.
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('9 de 10'), findsOneWidget);
      expect(find.text('Tus estadísticas'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('stats-habits-progress')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('guided-tour-demo')), findsNothing);
      expect(find.byKey(const ValueKey('guided-tour-focus')), findsOneWidget);

      // Cierre en Inicio: con hábitos no hay CTA de crear, solo "Listo".
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('10 de 10'), findsOneWidget);
      expect(find.text('¡Eso es todo!'), findsOneWidget);
      expect(_skip, findsNothing);
      expect(find.text('¡Listo!'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-new-habit')), findsOneWidget);

      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(_tour, findsNothing);
      expect(find.text('Racha general'), findsOneWidget);
    });

    testWidgets(
      'en una cuenta nueva enseña datos de ejemplo y termina creando el '
      'primer hábito',
      (tester) async {
        await _pumpApp(
          tester,
          tourPreferences: MemoryOnboardingTourPreferences(),
          seededHabits: false,
        );
        expect(find.text('1 de 10'), findsOneWidget);
        // La bienvenida no lleva el aviso; los pasos sobre pantallas, sí.
        expect(find.byKey(const ValueKey('guided-tour-demo')), findsNothing);

        // Inicio con hábitos de ejemplo: hay fila que marcar.
        await tester.tap(_next);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('guided-tour-demo')), findsOneWidget);
        expect(find.text('Datos de ejemplo'), findsOneWidget);
        await tester.tap(_next);
        await tester.pumpAndSettle();
        expect(find.text('Marca lo que hagas hoy'), findsOneWidget);
        expect(find.text('Beber agua'), findsWidgets);

        for (var i = 0; i < 6; i++) {
          await tester.tap(_next);
          await tester.pumpAndSettle();
        }
        // Estadísticas con las barras de los hábitos de ejemplo.
        expect(find.text('9 de 10'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('stats-habits-progress')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('stats-habits-empty')), findsNothing);

        await tester.tap(_next);
        await tester.pumpAndSettle();
        expect(find.text('10 de 10'), findsOneWidget);
        expect(find.text('Tu turno'), findsOneWidget);
        expect(find.text('Crear mi primer hábito'), findsOneWidget);

        await tester.tap(_next);
        await tester.pumpAndSettle();
        expect(_tour, findsNothing);
        // Se abre el formulario de nuevo hábito directamente.
        expect(find.text('Nuevo hábito'), findsWidgets);
        expect(find.byKey(const ValueKey('guided-tour-next')), findsNothing);
        // Al cerrar vuelven los datos reales.
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HabitsApp)),
        );
        expect(container.read(guidedTourDemoDataProvider), isFalse);
      },
    );

    testWidgets('saltar cierra el recorrido y vuelve a Inicio', (tester) async {
      await _pumpApp(
        tester,
        tourPreferences: MemoryOnboardingTourPreferences(),
      );
      expect(_tour, findsOneWidget);

      await tester.tap(_next);
      await tester.pumpAndSettle();
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('Marca lo que hagas hoy'), findsOneWidget);

      await tester.tap(_skip);
      await tester.pumpAndSettle();
      expect(_tour, findsNothing);
      expect(find.text('Racha general'), findsOneWidget);
    });

    testWidgets('no se abre si ya se vio', (tester) async {
      await _pumpApp(
        tester,
        tourPreferences: MemoryOnboardingTourPreferences()
          ..markSeen(verifiedUser.id),
      );
      expect(_tour, findsNothing);
    });

    testWidgets('se puede repetir desde Perfil', (tester) async {
      await _pumpApp(
        tester,
        tourPreferences: MemoryOnboardingTourPreferences(seenByDefault: true),
        weightConfigured: true,
      );
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      final link = find.byKey(const ValueKey('profile-tutorial'));
      await tester.scrollUntilVisible(
        link,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pumpAndSettle();

      // Arranca en Inicio, sea cual sea la pestaña desde la que se pida.
      expect(_tour, findsOneWidget);
      expect(find.text('¡Bienvenido a Constanza!'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-new-habit')), findsOneWidget);

      // Perfil se quedó desplazado al final al pulsar el enlace: al volver
      // en el paso del peso, la fila tiene que estar construida y con foco.
      for (var i = 0; i < 6; i++) {
        await tester.tap(_next);
        await tester.pumpAndSettle();
      }
      expect(find.text('Registra tu peso'), findsOneWidget);
      expect(find.text('Peso y objetivos'), findsOneWidget);
      expect(find.byKey(const ValueKey('guided-tour-focus')), findsOneWidget);
    });
  });

  group('StatisticsPage', () {
    testWidgets('sin hábitos y sin recorrido muestra el estado vacío', (
      tester,
    ) async {
      final env = AuthTestEnv(initialUser: verifiedUser, seededHabits: false);
      await tester.pumpWidget(
        localizedApp(const StatisticsPage(), overrides: env.overrides),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('stats-habits-empty')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const ValueKey('stats-habits-empty')), findsOneWidget);
    });
  });

  group('HomePage', () {
    testWidgets('arranca el recorrido tras la animación de bienvenida', (
      tester,
    ) async {
      final preferences = MemoryOnboardingTourPreferences();
      await tester.pumpWidget(_homeUnderTest(tourPreferences: preferences));
      // Pumps cortos: llega el primer resumen sin agotar la animación.
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 1));
      }
      final welcome = find.byKey(const ValueKey('cold-start-welcome'));
      expect(welcome, findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomePage)),
      );
      expect(container.read(guidedTourProvider), isNull);

      await tester.pump(ColdStartWelcome.duration);
      await tester.pumpAndSettle();
      expect(welcome, findsNothing);
      expect(container.read(guidedTourProvider), 0);
      expect(preferences.isSeen(verifiedUser.id), isTrue);
    });
  });
}
