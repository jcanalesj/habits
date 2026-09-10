// Flujo real de autenticación contra la Firebase Emulator Suite.
//
// Requiere los emuladores levantados (`firebase emulators:start --only
// auth,firestore`) y ejecutarse con el flag de emulador:
//
//   flutter test integration_test/auth_flow_emulator_test.dart \
//     -d <device> --dart-define=USE_FIREBASE_EMULATOR=true
//
// Los tests son secuenciales y comparten estado (la cuenta creada).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/env.dart';
import 'package:habits/features/splash/2_presentation/pages/splash_page.dart';
import 'package:habits/firebase_setup.dart';
import 'package:habits/main.dart';
import 'package:integration_test/integration_test.dart';

import 'emulator_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final email = 'it-${DateTime.now().millisecondsSinceEpoch}@constanza.test';
  const password = 'secreta12';
  const newPassword = 'nuevaClave34';
  late String uid;

  setUpAll(() async {
    expect(
      Env.useFirebaseEmulator,
      isTrue,
      reason: 'Ejecuta con --dart-define=USE_FIREBASE_EMULATOR=true',
    );
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeFirebase();
    await FirebaseAuth.instance.signOut();
    await EmulatorHelpers.clearAll();
  });

  /// pumpAndSettle acotado: en dispositivo real puede haber animaciones
  /// continuas (cursor, indicadores); si no se estabiliza en 15 s seguimos y
  /// dejan que decidan las aserciones.
  Future<void> settle(WidgetTester tester) async {
    try {
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 15),
      );
    } on FlutterError {
      await tester.pump();
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('es');
    tester.platformDispatcher.localesTestValue = const [Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: HabitsApp()));
    await tester.pump(SplashPage.duration + const Duration(milliseconds: 300));
    await settle(tester);
  }

  Future<void> login(WidgetTester tester, String pwd) async {
    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), pwd);
    await tester.tap(find.text('Continuar'));
    await settle(tester);
  }

  Future<void> signOutFromProfile(WidgetTester tester) async {
    await tester.tap(find.text('Perfil'));
    await settle(tester);
    await tester.tap(find.text('Cerrar sesión'));
    await settle(tester);
    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(FirebaseAuth.instance.currentUser, isNull);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> serverGet(String path) =>
      FirebaseFirestore.instance
          .doc(path)
          .get(const GetOptions(source: Source.server));

  testWidgets('1. registro → verificación → perfil → logout → login', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Inicia sesión'), findsOneWidget);

    // Registro.
    await tester.tap(find.text('Regístrate'));
    await settle(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Alex');
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), password);
    await tester.enterText(fields.at(3), password);
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Registrarme'));
    await settle(tester);

    expect(find.text('Verifica tu cuenta'), findsOneWidget);
    expect(find.text(email), findsOneWidget);
    final user = FirebaseAuth.instance.currentUser!;
    uid = user.uid;
    expect(user.emailVerified, isFalse);
    expect(user.displayName, 'Alex');

    // Firebase ha emitido el correo de verificación.
    final verifyCode = await EmulatorHelpers.latestOobCode(
      email,
      requestType: 'VERIFY_EMAIL',
    );
    expect(verifyCode, isNotNull, reason: 'no se envió el enlace');

    // Sin verificar, las reglas niegan el acceso a sus propios datos.
    await expectLater(
      serverGet('users/$uid'),
      throwsA(
        isA<FirebaseException>().having(
          (e) => e.code,
          'code',
          'permission-denied',
        ),
      ),
    );

    // Comprobar antes de abrir el enlace: sigue pendiente.
    await tester.tap(find.text('Ya he verificado mi correo'));
    await settle(tester);
    expect(find.textContaining('Todavía no consta'), findsOneWidget);

    // El usuario abre el enlace del correo y vuelve a la app.
    await EmulatorHelpers.openLink(verifyCode!['oobLink'] as String);
    await tester.tap(find.text('Ya he verificado mi correo'));
    await settle(tester);

    expect(find.text('Racha general'), findsOneWidget);
    expect(FirebaseAuth.instance.currentUser!.emailVerified, isTrue);

    // Perfil creado tras la verificación (users/{uid} + 5 ámbitos).
    DocumentSnapshot<Map<String, dynamic>>? profile;
    Object? lastError;
    for (var i = 0; i < 30 && (profile == null || !profile.exists); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
      try {
        profile = await tester.runAsync(() => serverGet('users/$uid'));
        lastError = null;
      } on FirebaseException catch (e) {
        lastError = e; // p. ej. permission-denied hasta refrescar el token
      }
    }
    expect(
      profile?.exists,
      isTrue,
      reason: 'no se creó users/$uid (último error: $lastError)',
    );
    final data = profile!.data()!;
    expect(data['email'], email);
    expect(data['displayName'], 'Alex');
    expect(data['locale'], 'es');
    expect(data['subscription'], {'status': 'free'});
    expect(data['timezone'], isNotEmpty);
    final ambitos = await tester.runAsync(
      () => FirebaseFirestore.instance
          .collection('users/$uid/ambitos')
          .get(const GetOptions(source: Source.server)),
    );
    expect(ambitos!.docs.map((d) => d.id).toSet(), {
      'general',
      'salud',
      'mente',
      'desarrollo',
      'energia',
    });

    // Logout y login con la contraseña original.
    await signOutFromProfile(tester);
    await login(tester, password);
    expect(find.text('Racha general'), findsOneWidget);

    // El perfil no se duplica ni se reescribe.
    final again = await tester.runAsync(() => serverGet('users/$uid'));
    expect(again!.data()!['createdAt'], data['createdAt']);
  });

  testWidgets(
    '2. la sesión persiste al reconstruir la app en el mismo proceso',
    (tester) async {
      expect(FirebaseAuth.instance.currentUser, isNotNull);

      await pumpApp(tester);

      expect(find.text('Racha general'), findsOneWidget);
      expect(find.text('Inicia sesión'), findsNothing);
    },
  );

  testWidgets('3. recuperación de contraseña por enlace', (tester) async {
    await pumpApp(tester);
    await signOutFromProfile(tester);

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), email);
    await tester.tap(find.text('Enviar enlace'));
    await settle(tester);
    expect(find.textContaining('recibirás un enlace'), findsOneWidget);

    final resetCode = await EmulatorHelpers.latestOobCode(
      email,
      requestType: 'PASSWORD_RESET',
    );
    expect(resetCode, isNotNull, reason: 'no se envió el enlace');
    await EmulatorHelpers.resetPassword(
      oobCode: resetCode!['oobCode'] as String,
      newPassword: newPassword,
    );

    await tester.tap(find.text('Volver a iniciar sesión'));
    await settle(tester);

    // La contraseña antigua ya no vale; la nueva sí.
    await login(tester, password);
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    await login(tester, newPassword);
    expect(find.text('Racha general'), findsOneWidget);
  });

  testWidgets('4. un usuario sin verificar no accede a la app ni a sus datos', (
    tester,
  ) async {
    await pumpApp(tester);
    await signOutFromProfile(tester);

    final otherEmail =
        'other-${DateTime.now().millisecondsSinceEpoch}@constanza.test';
    await tester.tap(find.text('Regístrate'));
    await settle(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Otro');
    await tester.enterText(fields.at(1), otherEmail);
    await tester.enterText(fields.at(2), password);
    await tester.enterText(fields.at(3), password);
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Registrarme'));
    await settle(tester);
    expect(find.text('Verifica tu cuenta'), findsOneWidget);

    final otherUid = FirebaseAuth.instance.currentUser!.uid;
    await expectLater(
      FirebaseFirestore.instance.doc('users/$otherUid').set({
        'email': otherEmail,
        'timezone': 'Europe/Madrid',
        'locale': 'es',
        'subscription': {'status': 'free'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }),
      throwsA(
        isA<FirebaseException>().having(
          (e) => e.code,
          'code',
          'permission-denied',
        ),
      ),
    );

    // Cerrar sesión desde la verificación ("Usar otra cuenta") y volver a
    // entrar: sigue bloqueado en la verificación.
    await tester.tap(find.text('Usar otra cuenta'));
    await settle(tester);
    expect(find.text('Inicia sesión'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), otherEmail);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.tap(find.text('Continuar'));
    await settle(tester);
    expect(find.text('Verifica tu cuenta'), findsOneWidget);

    // Dejar la sesión verificada activa para el test de persistencia entre
    // procesos (session_persistence_test.dart).
    await tester.tap(find.text('Usar otra cuenta'));
    await settle(tester);
    await login(tester, newPassword);
    expect(find.text('Racha general'), findsOneWidget);
    expect(FirebaseAuth.instance.currentUser?.emailVerified, isTrue);
  });
}
