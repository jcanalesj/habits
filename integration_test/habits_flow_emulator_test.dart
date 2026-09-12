// Persistencia real de hábitos contra la Firebase Emulator Suite, con las
// Security Rules desplegadas en el repo. Requiere los emuladores levantados
// y el flag de emulador (ver auth_flow_emulator_test.dart).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/env.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/3_data/data.dart';
import 'package:habits/features/splash/2_presentation/pages/splash_page.dart';
import 'package:habits/firebase_setup.dart';
import 'package:habits/main.dart';
import 'package:integration_test/integration_test.dart';

import 'emulator_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final email =
      'habits-${DateTime.now().millisecondsSinceEpoch}@constanza.test';
  const password = 'secreta12';
  late String uid;
  late FirestoreHabitsRepository repository;
  // El día lógico se resuelve con la zona del perfil, igual que en la app.
  late final LogicalCalendar calendar;
  late final LogicalDate today;

  setUpAll(() async {
    expect(
      Env.useFirebaseEmulator,
      isTrue,
      reason: 'Ejecuta con --dart-define=USE_FIREBASE_EMULATOR=true',
    );
    GoogleFonts.config.allowRuntimeFetching = false;
    initializeTimezones();
    calendar = LogicalCalendar('Europe/Madrid');
    today = calendar.dateOf(DateTime.now().toUtc());
    await initializeFirebase();
    await FirebaseAuth.instance.signOut();
    await EmulatorHelpers.clearAll();
  });

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

  /// Ejecuta trabajo asíncrono real (red) fuera del reloj falso del tester.
  Future<T> run<T>(WidgetTester tester, Future<T> Function() body) async =>
      (await tester.runAsync(body)) as T;

  /// Como [run], pero devuelve la excepción lanzada (o null): dentro de
  /// runAsync una excepción no llega a `throwsA`, el framework la captura.
  Future<Object?> caught(WidgetTester tester, Future<void> Function() body) =>
      tester.runAsync<Object?>(() async {
        try {
          await body();
          return null;
        } catch (e) {
          return e;
        }
      });

  Future<void> waitForProfile(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      final exists = await run(tester, () async {
        try {
          final doc = await FirebaseFirestore.instance
              .doc('users/$uid/ambitos/${Ambito.generalId}')
              .get(const GetOptions(source: Source.server));
          return doc.exists;
        } on FirebaseException {
          return false;
        }
      });
      if (exists) return;
      await run(
        tester,
        () => Future<void>.delayed(const Duration(milliseconds: 500)),
      );
    }
    fail('el perfil de $uid no se creó');
  }

  testWidgets('1. el alta deja al usuario con ámbitos y sin hábitos', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Regístrate'));
    await settle(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Habitante');
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), password);
    await tester.enterText(fields.at(3), password);
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Registrarme'));
    await settle(tester);
    uid = FirebaseAuth.instance.currentUser!.uid;

    await tester.tap(find.text('Empezar'));
    await settle(tester);
    expect(find.text('Racha general'), findsOneWidget);
    await waitForProfile(tester);

    repository = FirestoreHabitsRepository(userId: uid);
    final ambitos = await run(tester, () => repository.watchAmbitos().first);
    expect(ambitos.map((a) => a.id).toSet(), {
      'general',
      'salud',
      'mente',
      'desarrollo',
      'energia',
    });
    expect(
      await run(tester, () => repository.watchActiveHabits().first),
      isEmpty,
    );
    // Sin registros no hay actividad: la racha aún no ha empezado (§3).
    expect(await run(tester, () => repository.fetchActivityDays()), isEmpty);
    // La caché es una PROYECCIÓN: la Home ya la ha escrito al montarse, y su
    // contenido coincide con lo que dice la fuente de verdad (racha 0).
    final cache = await run(tester, () => repository.fetchStreakCache());
    if (cache != null) {
      expect(cache.currentStreak, 0);
      expect(cache.bestStreak, 0);
      expect(cache.lastActivityDay, isNull);
    }
    // Y se puede borrar entera sin que la app deje de funcionar.
    await run(tester, () => repository.clearStreakCache());
    expect(await run(tester, () => repository.fetchStreakCache()), isNull);
    // Sin hábitos: estado vacío en la Home.
    await tester.scrollUntilVisible(
      find.textContaining('Aún no tienes hábitos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Aún no tienes hábitos'), findsOneWidget);
  });

  testWidgets('2. CRUD de hábitos y registros con las reglas reales', (
    tester,
  ) async {
    // Crear.
    final habit = await run(
      tester,
      () => repository.createHabit(
        const HabitDraft(
          name: 'Beber agua',
          ambitoId: 'salud',
          colorValue: 0xFF38BDF8,
          emoji: '💧',
          reminderTime: '18:00',
        ),
        today: today,
      ),
    );
    var active = await run(tester, () => repository.watchActiveHabits().first);
    expect(active.map((h) => h.id), [habit.id]);

    // Editar.
    final edited = await run(
      tester,
      () => UpdateHabitUsecase(repository).execute(
        original: habit,
        updated: habit.copyWith(name: 'Beber 2L'),
      ),
    );
    expect(edited, isA<UpdateHabitSuccess>());

    // Cambiar el objetivo: el cambio es DIFERIDO al siguiente periodo
    // natural completo del tipo nuevo, y queda escrito en Firestore.
    final beforeChange = await run(
      tester,
      () => repository.getHabit(habit.id),
    );
    final scheduled = await run(
      tester,
      () => ChangeHabitPeriodicityUsecase(
        repository,
        PeriodicityResolver(calendar),
      ).execute(
        habit: beforeChange!,
        next: const Periodicity(
          type: PeriodicityType.weekly,
          timesPerPeriod: 3,
        ),
        today: today,
      ),
    );
    final effectiveFrom = (scheduled as ChangePeriodicityScheduled)
        .effectiveFrom;
    expect(effectiveFrom.weekday, DateTime.monday);
    expect(effectiveFrom.isAfter(today), isTrue);

    final reloaded = await run(tester, () => repository.getHabit(habit.id));
    expect(reloaded!.name, 'Beber 2L');
    expect(reloaded.periodicityTimeline, hasLength(2));
    expect(reloaded.periodicityOn(today).type, PeriodicityType.daily,
        reason: 'el periodo en curso conserva el objetivo antiguo');
    expect(
      reloaded.periodicityOn(effectiveFrom).timesPerPeriod,
      3,
      reason: 'el nuevo objetivo arranca en la fecha efectiva',
    );

    // Marcar HOY (idempotente), consultar por rango, desmarcar y volver a
    // marcar. Todo sobre `today`: el producto no admite registros
    // retroactivos, así que el test tampoco los escribe.
    for (var i = 0; i < 2; i++) {
      await run(
        tester,
        () => repository.setHabitCompletion(
          habitId: habit.id,
          date: today,
          completed: true,
        ),
      );
    }
    var logs = await run(tester, () => repository.fetchHabitLogs(habit.id));
    expect(logs, hasLength(1), reason: 'marcar dos veces no duplica');
    expect(logs.single.id, '${habit.id}_${today.key}');
    final range = await run(
      tester,
      () => repository.watchLogsBetween(today, today).first,
    );
    expect(range.map((l) => l.habitId), [habit.id]);

    // Desmarcar borra el registro...
    await run(
      tester,
      () => repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: false,
      ),
    );
    expect(await run(tester, () => repository.fetchHabitLogs(habit.id)),
        isEmpty);

    // ...y se puede volver a marcar.
    await run(
      tester,
      () => repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      ),
    );
    expect(await run(tester, () => repository.fetchHabitLogs(habit.id)),
        hasLength(1));

    // El dominio rechaza AYER de forma determinista, sin depender de la hora
    // (las Rules solo acotan la fecha a una ventana y, según el momento del
    // día, ayer puede caer dentro: ver la limitación conocida documentada).
    final retro = await run(
      tester,
      () => ToggleHabitCompletionUsecase(repository).execute(
        habitId: habit.id,
        date: today.previous,
        completed: true,
        today: today,
      ),
    );
    expect(retro, isA<ToggleHabitCompletionNotToday>());
    expect(await run(tester, () => repository.fetchHabitLogs(habit.id)),
        hasLength(1), reason: 'no se ha creado ningún registro de ayer');

    // Un día futuro lo rechazan las reglas.
    expect(
      await caught(
        tester,
        () => repository.setHabitCompletion(
          habitId: habit.id,
          date: today.addDays(5),
          completed: true,
        ),
      ),
      isA<HabitsException>().having(
        (e) => e.failure,
        'failure',
        HabitsFailure.permissionDenied,
      ),
    );

    // Soft delete: desaparece de activos, conserva registros, no admite más.
    await run(tester, () => repository.softDeleteHabit(habit.id));
    active = await run(tester, () => repository.watchActiveHabits().first);
    expect(active, isEmpty);
    expect(
      await run(tester, () => repository.fetchHabitLogs(habit.id)),
      hasLength(1),
    );
    // Su histórico es inmutable: ni siquiera se puede desmarcar lo que ya
    // estaba registrado. (Que tampoco admita registros NUEVOS se prueba en
    // firebase/rules-tests, donde el estado del día sí es controlable: aquí
    // el registro de hoy ya existe y volver a marcarlo es un no-op
    // idempotente que no llega a evaluar ninguna regla.)
    expect(
      await caught(
        tester,
        () => repository.setHabitCompletion(
          habitId: habit.id,
          date: today,
          completed: false,
        ),
      ),
      isA<HabitsException>().having(
        (e) => e.failure,
        'failure',
        HabitsFailure.permissionDenied,
      ),
    );
    expect(
      await run(tester, () => repository.fetchHabitLogs(habit.id)),
      hasLength(1),
      reason: 'el registro sigue ahí tras el intento de borrado',
    );
    final raw = await run(
      tester,
      () => FirebaseFirestore.instance
          .doc('users/$uid/habitos/${habit.id}')
          .get(),
    );
    expect(raw.exists, isTrue);
    expect(raw.data()!['deletedAt'], isA<Timestamp>());
  });

  testWidgets(
    '3. ámbitos: crear, editar, eliminar con reasignación, General protegido',
    (tester) async {
      final custom = await run(
        tester,
        () => repository.createAmbito(
          const AmbitoDraft(
            name: 'Música',
            emoji: '🎸',
            colorValue: 0xFFF16A8F,
          ),
        ),
      );
      await run(
        tester,
        () => repository.updateAmbito(custom.copyWith(name: 'Guitarra')),
      );
      final habitInCustom = await run(
        tester,
        () => repository.createHabit(
          HabitDraft(
            name: 'Practicar',
            ambitoId: custom.id,
            colorValue: 1,
            emoji: '🎵',
          ),
          today: today,
        ),
      );
      await run(
        tester,
        () => repository.setHabitCompletion(
          habitId: habitInCustom.id,
          date: today,
          completed: true,
        ),
      );

      await run(tester, () => repository.deleteAmbito(custom.id));

      final ambitos = await run(tester, () => repository.watchAmbitos().first);
      expect(ambitos.map((a) => a.id), isNot(contains(custom.id)));
      final moved = await run(
        tester,
        () => repository.getHabit(habitInCustom.id),
      );
      expect(moved!.ambitoId, Ambito.generalId);
      expect(
        await run(tester, () => repository.fetchHabitLogs(habitInCustom.id)),
        hasLength(1),
      );

      // General: lo protegen el dominio y las reglas.
      expect(
        await caught(tester, () => repository.deleteAmbito(Ambito.generalId)),
        isA<HabitsException>(),
      );
      expect(
        await caught(
          tester,
          () => FirebaseFirestore.instance
              .doc('users/$uid/ambitos/${Ambito.generalId}')
              .delete(),
        ),
        isA<FirebaseException>().having(
          (e) => e.code,
          'code',
          'permission-denied',
        ),
      );
    },
  );

  testWidgets('4. el usuario A no accede a los hábitos del usuario B', (
    tester,
  ) async {
    final other = FirestoreHabitsRepository(userId: 'otro-usuario');
    expect(
      await caught(tester, () => other.watchActiveHabits().first),
      isA<HabitsException>().having(
        (e) => e.failure,
        'failure',
        HabitsFailure.permissionDenied,
      ),
    );
    expect(
      await caught(
        tester,
        () => other.createHabit(
          const HabitDraft(
            name: 'Intruso',
            ambitoId: 'general',
            colorValue: 1,
            emoji: '👾',
          ),
          today: today,
        ),
      ),
      isA<HabitsException>().having(
        (e) => e.failure,
        'failure',
        HabitsFailure.permissionDenied,
      ),
    );
  });

  testWidgets('5. la Home refleja Firestore en tiempo real y marca hoy', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Racha general'), findsOneWidget);
    // Sigue el hábito reasignado a General; el eliminado no aparece.
    await tester.scrollUntilVisible(
      find.text('Practicar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Practicar'), findsOneWidget);
    expect(find.text('Beber 2L'), findsNothing);

    // Un hábito creado fuera de la UI aparece por el snapshot.
    await run(
      tester,
      () => repository.createHabit(
        const HabitDraft(
          name: 'Meditar',
          ambitoId: 'mente',
          colorValue: 2,
          emoji: '🧘',
        ),
        today: today,
      ),
    );
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text('Meditar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Meditar'), findsOneWidget);

    // Registrar hoy desde la UI crea el registro en Firestore. En Inicio la
    // única acción de la fila es el botón de registro: la semana es solo
    // historial y la fila no navega a la edición.
    final habits = await run(
      tester,
      () => repository.watchActiveHabits().first,
    );
    final meditar = habits.firstWhere((h) => h.name == 'Meditar');
    final todayDot = find.byKey(ValueKey('habit-track-${meditar.id}'));
    expect(todayDot, findsOneWidget);
    expect(
      tester
          .widget<GestureDetector>(
            find.descendant(
              of: find.byKey(
                ValueKey('habit-dot-${meditar.id}-${today.key}'),
              ),
              matching: find.byType(GestureDetector),
            ),
          )
          .onTap,
      isNull,
      reason: 'la semana no es interactiva en Inicio',
    );
    // La fila de puntos puede quedar bajo la barra inferior (extendBody):
    // subimos la lista para que el punto sea pulsable.
    await tester.ensureVisible(todayDot);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await settle(tester);
    await tester.tap(todayDot);
    await settle(tester);

    List<HabitLog> logs = const [];
    for (var i = 0; i < 20 && logs.isEmpty; i++) {
      await run(
        tester,
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      logs = await run(tester, () => repository.fetchHabitLogs(meditar.id));
    }
    expect(logs.map((l) => l.date), [today]);
    // Y la Home lo refleja: el hábito pasa a "Completados hoy" y su punto de
    // hoy queda marcado.
    await settle(tester);
    expect(find.textContaining('Completados hoy'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(ValueKey('habit-dot-${meditar.id}-${today.key}')),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('6. crear un hábito desde la UI lo persiste en Firestore', (
    tester,
  ) async {
    await pumpApp(tester);

    // Botón "Nuevo hábito" de la Home -> formulario a pantalla completa.
    await tester.tap(find.text('Nuevo hábito').first);
    await settle(tester);
    expect(find.text('Nuevo hábito'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'Estirar');
    await settle(tester);

    // Objetivo: 3 veces por semana.
    await tester.tap(find.widgetWithText(ChoiceChip, 'esta semana'));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text('Crear hábito'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await settle(tester);
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await settle(tester);

    await tester.tap(find.text('Crear hábito'));
    await settle(tester);

    // Persistido en Firestore con el objetivo flexible.
    List<Habit> habits = const [];
    for (var i = 0; i < 20; i++) {
      habits = await run(tester, () => repository.watchActiveHabits().first);
      if (habits.any((h) => h.name == 'Estirar')) break;
      await run(
        tester,
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
    }
    final estirar = habits.firstWhere((h) => h.name == 'Estirar');
    expect(estirar.periodicityOn(today).type, PeriodicityType.weekly);
    expect(estirar.periodicityOn(today).timesPerPeriod, 3);

    // Y la Home lo muestra ya de vuelta.
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text('Estirar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('3 veces por semana'), findsWidgets);
  });
}
