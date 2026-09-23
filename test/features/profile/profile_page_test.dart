import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/services/timezone_bootstrap.dart';
import 'package:habits/features/profile/profile_page.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  testWidgets('muestra identidad, progreso, gestión y cuenta', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(const ProfilePage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.text('Cuenta verificada'), findsNothing);
    expect(find.text('Cambiar foto'), findsOneWidget);
    expect(find.text('Salud'), findsOneWidget);
    expect(find.text('Peso y objetivos'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Gestión'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Gestión'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cerrar sesión'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Zona horaria'), findsOneWidget);
    expect(find.textContaining('Europe/Madrid'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite editar el nombre del perfil', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(const ProfilePage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('profile-edit-name')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alejandra');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Alejandra'), findsOneWidget);
    expect(env.auth.currentUser?.displayName, 'Alejandra');
  });
}
