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
      find.text('Zona horaria'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Zona horaria'), findsOneWidget);
    expect(find.textContaining('Europe/Madrid'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cerrar sesión'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Política de privacidad'), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
    expect(find.text('Eliminar cuenta'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirma el cierre de sesión en el diálogo rediseñado', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(const ProfilePage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Cerrar sesión'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sign-out-dialog')), findsOneWidget);
    expect(find.text('¿Ya te vas?'), findsOneWidget);
    expect(find.bySemanticsLabel('Gato triste de Constanza'), findsOneWidget);
    expect(
      find.textContaining('Tus datos se quedan guardados'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('confirm-sign-out')));
    await tester.pumpAndSettle();
    expect(env.auth.currentUser, isNull);
  });

  testWidgets('eliminar cuenta pide la contraseña y borra la cuenta', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    await tester.pumpWidget(
      localizedApp(const ProfilePage(), overrides: env.overrides),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('delete-account')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('delete-account')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('delete-account-dialog')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('delete-account-password')),
      'password',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('confirm-delete-account')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-delete-account')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('delete-account-dialog')), findsNothing);
    expect(env.auth.currentUser, isNull);
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
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('save-profile-name')));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('save-profile-name')))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const ValueKey('save-profile-name')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('edit-profile-dialog')), findsNothing);
    expect(find.text('Alejandra'), findsOneWidget);
    expect(env.auth.currentUser?.displayName, 'Alejandra');
  });
}
