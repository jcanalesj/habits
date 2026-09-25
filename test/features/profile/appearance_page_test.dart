import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/appearance/app_icon.dart';
import 'package:habits/features/profile/appearance/appearance_page.dart';
import 'package:habits/features/profile/appearance/theme_mode_preferences.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  testWidgets('muestra motivación y opciones de aspecto', (tester) async {
    await tester.pumpWidget(localizedApp(const AppearancePage()));
    await tester.pumpAndSettle();

    expect(find.text('Personalización'), findsOneWidget);
    expect(find.text('Tus frases'), findsOneWidget);
    expect(find.text('Mostrar mensajes'), findsNothing);
    expect(find.text('Añadir mensaje'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Animación de bienvenida'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Aspecto'), findsOneWidget);
    expect(find.text('Animación de bienvenida'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Sistema'), findsNothing);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);
    expect(find.text('Próximamente'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Premium puede elegir el tema oscuro y lo sincroniza', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.profiles.premium[verifiedUser.id] = true;
    await tester.pumpWidget(
      localizedApp(
        const AppearancePage(),
        overrides: [
          ...env.overrides,
          themeModePreferencesProvider.overrideWithValue(
            SharedThemeModePreferences(preferences),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    expect(container.read(themeModeProvider), ThemeMode.light);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('theme-mode-dark')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-mode-dark')));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(preferences.getString(SharedThemeModePreferences.key), 'dark');
    expect(env.profiles.themeModes[verifiedUser.id], ThemeMode.dark);

    await tester.ensureVisible(find.byKey(const ValueKey('theme-mode-light')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-mode-light')));
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(preferences.getString(SharedThemeModePreferences.key), 'light');
  });

  testWidgets('el tema oscuro muestra su preview Premium a cuentas gratis', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(
        const AppearancePage(),
        overrides: [
          ...env.overrides,
          themeModePreferencesProvider.overrideWithValue(
            SharedThemeModePreferences(preferences),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('theme-mode-dark')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-mode-dark')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('premium-dark-theme-dialog')),
      findsOneWidget,
    );
    expect(find.text('Descubre Constanza de noche'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/premium.png')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dark-theme-premium-preview')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dark-theme-view-premium-plans')),
      findsOneWidget,
    );
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(preferences.getString(SharedThemeModePreferences.key), isNull);
  });

  testWidgets('"Ver planes" abre los planes y al comprar aplica el oscuro', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(
        const AppearancePage(),
        overrides: [
          ...env.overrides,
          themeModePreferencesProvider.overrideWithValue(
            SharedThemeModePreferences(preferences),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    final dark = find.byKey(const ValueKey('theme-mode-dark'));
    await tester.scrollUntilVisible(
      dark,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(dark);
    await tester.pumpAndSettle();
    final viewPlans = find.byKey(
      const ValueKey('dark-theme-view-premium-plans'),
    );
    await tester.ensureVisible(viewPlans);
    await tester.pumpAndSettle();
    await tester.tap(viewPlans);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('paywall-page')), findsOneWidget);
    await buyPremiumOnPaywall(tester);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(premiumSubscribedProvider), isTrue);
    expect(
      find.byKey(const ValueKey('premium-dark-theme-dialog')),
      findsNothing,
    );
  });

  testWidgets('restaura el tema guardado y adopta el remoto', (tester) async {
    SharedPreferences.setMockInitialValues({
      SharedThemeModePreferences.key: 'dark',
    });
    final preferences = await SharedPreferences.getInstance();
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.profiles.themeModes[verifiedUser.id] = ThemeMode.light;
    await tester.pumpWidget(
      localizedApp(
        const AppearancePage(),
        overrides: [
          ...env.overrides,
          themeModePreferencesProvider.overrideWithValue(
            SharedThemeModePreferences(preferences),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    // El perfil remoto manda sobre la copia local y la actualiza.
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(preferences.getString(SharedThemeModePreferences.key), 'light');
  });

  testWidgets('una cuenta gratuita no conserva un tema oscuro anterior', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      SharedThemeModePreferences.key: 'dark',
    });
    final preferences = await SharedPreferences.getInstance();
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.profiles.themeModes[verifiedUser.id] = ThemeMode.dark;
    await tester.pumpWidget(
      localizedApp(
        const AppearancePage(),
        overrides: [
          ...env.overrides,
          themeModePreferencesProvider.overrideWithValue(
            SharedThemeModePreferences(preferences),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(preferences.getString(SharedThemeModePreferences.key), 'light');
    expect(env.profiles.themeModes[verifiedUser.id], ThemeMode.light);
  });

  testWidgets('se pinta sin errores en modo oscuro', (tester) async {
    await tester.pumpWidget(
      localizedApp(const AppearancePage(), themeMode: ThemeMode.dark),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(AppearancePage));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Tus frases'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite añadir y eliminar una frase propia', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(const AppearancePage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('add-motivation-message')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-motivation-message')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('motivation-message-field')),
      'Paso a paso también es avanzar',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-motivation-message')));
    await tester.pumpAndSettle();

    // La lista es perezosa: la frase nueva queda por encima del viewport
    // tras el scroll que hizo visible el botón, así que se vuelve arriba.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 800));
    await tester.pumpAndSettle();
    expect(find.text('Paso a paso también es avanzar'), findsWidgets);
    expect(env.profiles.customMotivationMessages[verifiedUser.id], [
      'Paso a paso también es avanzar',
    ]);
    await tester.ensureVisible(find.byIcon(PhosphorIconsBold.trash));
    await tester.tap(find.byIcon(PhosphorIconsBold.trash));
    await tester.pumpAndSettle();
    expect(find.text('Paso a paso también es avanzar'), findsNothing);
    expect(env.profiles.customMotivationMessages[verifiedUser.id], isEmpty);
  });

  testWidgets('muestra Premium al superar una frase en la versión gratuita', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.profiles.customMotivationMessages[verifiedUser.id] = [
      'Mi primera frase',
    ];
    await tester.pumpWidget(
      localizedApp(const AppearancePage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('add-motivation-message')),
    );
    await tester.tap(find.byKey(const ValueKey('add-motivation-message')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('premium-message-limit-dialog')),
      findsOneWidget,
    );
    expect(find.text('Desbloquea más frases con Premium'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('motivation-message-dialog')),
      findsNothing,
    );
  });

  testWidgets('Premium puede añadir más de una frase', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.profiles.customMotivationMessages[verifiedUser.id] = [
      'Mi primera frase',
    ];
    env.profiles.premium[verifiedUser.id] = true;
    await tester.pumpWidget(
      localizedApp(const AppearancePage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('add-motivation-message')),
    );
    await tester.tap(find.byKey(const ValueKey('add-motivation-message')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('motivation-message-dialog')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('premium-message-limit-dialog')),
      findsNothing,
    );
  });

  testWidgets('permite desactivar la animación de bienvenida', (tester) async {
    await tester.pumpWidget(localizedApp(const AppearancePage()));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    expect(container.read(welcomeAnimationEnabledProvider), isTrue);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('welcome-animation-switch')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('welcome-animation-switch')));
    await tester.pumpAndSettle();
    expect(container.read(welcomeAnimationEnabledProvider), isFalse);
  });

  testWidgets('restaura y guarda la preferencia de bienvenida', (tester) async {
    SharedPreferences.setMockInitialValues({
      'welcome_animation_enabled': false,
    });
    final preferences = await SharedPreferences.getInstance();
    final storage = SharedWelcomeAnimationPreferences(preferences);

    await tester.pumpWidget(
      localizedApp(
        const AppearancePage(),
        overrides: [
          welcomeAnimationPreferencesProvider.overrideWithValue(storage),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    expect(container.read(welcomeAnimationEnabledProvider), isFalse);

    await tester.ensureVisible(
      find.byKey(const ValueKey('welcome-animation-switch')),
    );
    await tester.tap(find.byKey(const ValueKey('welcome-animation-switch')));
    await tester.pumpAndSettle();

    expect(preferences.getBool('welcome_animation_enabled'), isTrue);
  });
  group('icono de la app', () {
    Future<_FakeAppIconService> pumpPage(WidgetTester tester) async {
      final service = _FakeAppIconService();
      final env = AuthTestEnv(initialUser: verifiedUser);
      await tester.pumpWidget(
        localizedApp(
          const AppearancePage(),
          overrides: [
            ...env.overrides,
            appIconServiceProvider.overrideWithValue(service),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('app-icon-crown')),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      return service;
    }

    testWidgets('los iconos Premium piden Premium y al comprar se aplican', (
      tester,
    ) async {
      final service = await pumpPage(tester);
      expect(find.text('Icono de la app'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('app-icon-crown')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('premium-app-icon-dialog')),
        findsOneWidget,
      );
      expect(service.changes, isEmpty);

      final viewPlans = find.byKey(
        const ValueKey('app-icon-view-premium-plans'),
      );
      await tester.ensureVisible(viewPlans);
      await tester.pumpAndSettle();
      await tester.tap(viewPlans);
      await tester.pumpAndSettle();
      await buyPremiumOnPaywall(tester);

      expect(service.changes, [AppIconOption.crown]);
      expect(find.text('Icono actualizado'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Ya con Premium, el resto de iconos se aplican sin pop-up.
      await tester.tap(find.byKey(const ValueKey('app-icon-yarn')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('premium-app-icon-dialog')),
        findsNothing,
      );
      expect(service.changes, [AppIconOption.crown, AppIconOption.yarn]);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('"Ahora no" deja el icono como estaba', (tester) async {
      final service = await pumpPage(tester);
      await tester.tap(find.byKey(const ValueKey('app-icon-yarn')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ahora no'));
      await tester.pumpAndSettle();
      expect(service.changes, isEmpty);
    });
  });
}

class _FakeAppIconService implements AppIconService {
  AppIconOption icon = AppIconOption.classic;
  final changes = <AppIconOption>[];

  @override
  Future<AppIconOption> current() async => icon;

  @override
  Future<void> set(AppIconOption icon) async {
    this.icon = icon;
    changes.add(icon);
  }
}
