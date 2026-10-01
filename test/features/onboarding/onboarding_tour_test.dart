import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';
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
}) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.platformDispatcher.localeTestValue = const Locale('es');
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  final env = AuthTestEnv(initialUser: verifiedUser);
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
    test('avanza por los pasos y termina tras el último', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(guidedTourProvider.notifier);

      expect(container.read(guidedTourProvider), isNull);
      controller.next();
      expect(container.read(guidedTourProvider), isNull);

      controller.start();
      for (var i = 0; i < GuidedTourStep.values.length - 1; i++) {
        expect(container.read(guidedTourProvider), i);
        controller.next();
      }
      expect(
        container.read(guidedTourProvider),
        GuidedTourStep.values.length - 1,
      );
      controller.next();
      expect(container.read(guidedTourProvider), isNull);
    });
  });

  group('Recorrido guiado sobre la app real', () {
    testWidgets('recorre las pantallas y vuelve a Inicio al terminar', (
      tester,
    ) async {
      final preferences = MemoryOnboardingTourPreferences();
      await _pumpApp(tester, tourPreferences: preferences);

      // Primer paso sobre la Home, con el botón de nuevo hábito como foco.
      expect(_tour, findsOneWidget);
      expect(find.text('1 de 7'), findsOneWidget);
      expect(find.text('Crea tus hábitos'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-new-habit')), findsOneWidget);
      expect(preferences.isSeen(verifiedUser.id), isTrue);
      // El recorrido ya presenta el peso: la invitación no se encadena.
      expect(
        find.byKey(const ValueKey('weight-invitation-never')),
        findsNothing,
      );

      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('2 de 7'), findsOneWidget);
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

      // Estadísticas: último paso, sin "Saltar" y con botón de cierre.
      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(find.text('7 de 7'), findsOneWidget);
      expect(find.text('Tus estadísticas'), findsOneWidget);
      expect(_skip, findsNothing);
      expect(find.text('¡Listo!'), findsOneWidget);

      await tester.tap(_next);
      await tester.pumpAndSettle();
      expect(_tour, findsNothing);
      expect(find.text('Racha general'), findsOneWidget);
    });

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
      expect(find.byKey(const ValueKey('edit-habits-action')), findsOneWidget);

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
      expect(find.text('Crea tus hábitos'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-new-habit')), findsOneWidget);
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
