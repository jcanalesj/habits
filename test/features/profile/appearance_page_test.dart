import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/appearance/appearance_page.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  testWidgets('muestra la vista previa y opciones disponibles', (tester) async {
    await tester.pumpWidget(localizedApp(const AppearancePage()));
    await tester.pumpAndSettle();

    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Hazla un poco más tuya'), findsOneWidget);
    expect(find.text('Vista previa'), findsOneWidget);
    expect(find.text('Animación de bienvenida'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Claro'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Icono de la app'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Icono de la app'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite desactivar la animación de bienvenida', (tester) async {
    await tester.pumpWidget(localizedApp(const AppearancePage()));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    expect(container.read(welcomeAnimationEnabledProvider), isTrue);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(container.read(welcomeAnimationEnabledProvider), isFalse);
  });
}
