import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/appearance/appearance_page.dart';
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
    expect(find.text('Oscuro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite añadir y eliminar una frase propia', (tester) async {
    await tester.pumpWidget(localizedApp(const AppearancePage()));
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

    expect(find.text('Paso a paso también es avanzar'), findsWidgets);
    await tester.ensureVisible(find.byIcon(PhosphorIconsBold.trash));
    await tester.tap(find.byIcon(PhosphorIconsBold.trash));
    await tester.pumpAndSettle();
    expect(find.text('Paso a paso también es avanzar'), findsNothing);
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
}
