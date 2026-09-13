import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/profile/timezone/timezone_page.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  Future<AuthTestEnv> pumpPage(WidgetTester tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    // Un usuario con sesión siempre tiene perfil; sin sembrarlo, la repo en
    // memoria ignora los cambios de zona.
    await env.profiles.create(
      NewUserProfile(
        userId: verifiedUser.id,
        email: verifiedUser.email,
        displayName: verifiedUser.displayName,
        timezone: 'Europe/Madrid',
        locale: 'es',
        ambitos: const [],
      ),
    );
    await tester.pumpWidget(
      localizedApp(
        const TimezonePage(),
        overrides: [
          ...env.overrides,
          timezoneAutomaticProvider.overrideWith((ref) => Stream.value(true)),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return env;
  }

  Future<void> scrollToZones(WidgetTester tester) async {
    await tester.drag(find.byType(ListView).first, const Offset(0, -520));
    await tester.pumpAndSettle();
  }

  testWidgets('la cabecera muestra la ilustración de zona horaria', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Tu día, a tu hora'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/zona_horaria.png')),
      findsOneWidget,
    );
    // Un desbordamiento de layout lanzaría excepción: la cabecera se adapta
    // al texto en pantallas estrechas.
    expect(tester.takeException(), isNull);
  });

  testWidgets('el aviso ya no ocupa sitio fijo en la pantalla', (tester) async {
    await pumpPage(tester);
    await scrollToZones(tester);

    expect(find.textContaining('Si viajas'), findsNothing);
  });

  testWidgets('avisa antes de cambiar y guarda al confirmar', (tester) async {
    final env = await pumpPage(tester);
    expect(find.text('Europe/Madrid'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    // El aviso aparece justo antes de aplicar el cambio.
    expect(find.text('¿Cambiar tu zona horaria?'), findsOneWidget);
    expect(find.textContaining('Si viajas'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar'));
    await tester.pumpAndSettle();

    expect(env.profiles.timezoneAutomatic[verifiedUser.id], isFalse);

    await scrollToZones(tester);
    await tester.tap(find.text('Londres'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cambiar tu zona horaria?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar'));
    await tester.pumpAndSettle();

    expect(env.profiles.profiles[verifiedUser.id]?.timezone, 'Europe/London');
  });

  testWidgets('cancelar el aviso deja la zona como estaba', (tester) async {
    final env = await pumpPage(tester);
    final antes = env.profiles.profiles[verifiedUser.id]?.timezone;

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();

    expect(env.profiles.timezoneAutomatic[verifiedUser.id], isNull);
    expect(env.profiles.profiles[verifiedUser.id]?.timezone, antes);
  });

  testWidgets('elegir la zona ya activa no pregunta nada', (tester) async {
    final env = await pumpPage(tester);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar'));
    await tester.pumpAndSettle();
    await scrollToZones(tester);

    await tester.tap(find.text('Madrid'));
    await tester.pumpAndSettle();

    expect(find.text('¿Cambiar tu zona horaria?'), findsNothing);
    expect(
      env.profiles.profiles[verifiedUser.id]?.timezone,
      isNot('Europe/London'),
    );
  });
}
