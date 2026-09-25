import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/3_data/data.dart';

import '../../../helpers/habits_test_helpers.dart';

void main() {
  group('FirestoreHabitsRepository', () {
    const uid = 'uid-1';
    final today = day(2026, 9, 10);
    final nowInstant = DateTime.utc(2026, 9, 10, 12);
    late FakeFirebaseFirestore db;
    late FirestoreHabitsRepository repository;

    CollectionReference<Map<String, dynamic>> col(String name) =>
        db.collection('users').doc(uid).collection(name);

    Future<void> seedAmbito(String id, {int order = 0}) =>
        col('ambitos').doc(id).set({
          'nombre': id,
          'emoji': '✨',
          'colorValue': 1,
          'esPredefinido': id == Ambito.generalId,
          'orden': order,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    setUp(() async {
      db = FakeFirebaseFirestore();
      repository = FirestoreHabitsRepository(
        userId: uid,
        firestore: db,
        timezone: 'Europe/Madrid',
        now: () => nowInstant,
      );
      await seedAmbito(Ambito.generalId, order: 0);
      await seedAmbito('salud', order: 1);
    });

    test('createHabit escribe exactamente los campos de las reglas', () async {
      final habit = await repository.createHabit(
        habitDraft(reminderTime: '18:00'),
        today: today,
      );

      final doc = await col('habitos').doc(habit.id).get();
      final data = doc.data()!;
      expect(data.keys.toSet(), {
        'nombre',
        'emoji',
        'iconId',
        'colorValue',
        'ambitoId',
        'periodicidad',
        'cambiosPeriodicidad',
        'recordatorioHora',
        'recordatorioMensaje',
        'orden',
        'trackingType',
        'targetCount',
        'unit',
        'displayGoal',
        'progressIconId',
        'deletedAt',
        'createdAt',
        'updatedAt',
      });
      expect(data['nombre'], 'Beber agua');
      expect(data['iconId'], 'water_drop');
      expect(data['periodicidad'], {'tipo': 'daily', 'veces': 1});
      expect(data['cambiosPeriodicidad'], isEmpty);
      expect(data['deletedAt'], isNull);
      expect(data['recordatorioHora'], '18:00');
      expect(data['orden'], nowInstant.millisecondsSinceEpoch);
      expect(data['createdAt'], isA<Timestamp>());
    });

    test('watchActiveHabits emite al crear y excluye los eliminados', () async {
      final emissions = <List<String>>[];
      final sub = repository.watchActiveHabits().listen(
        (habits) => emissions.add(habits.map((h) => h.name).toList()),
      );
      await Future<void>.delayed(Duration.zero);

      final a = await repository.createHabit(
        habitDraft(name: 'A'),
        today: today,
      );
      await repository.createHabit(habitDraft(name: 'B'), today: today);
      await repository.softDeleteHabit(a.id);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emissions.first, isEmpty);
      expect(emissions.last, ['B']);
      final deleted = await repository.getHabit(a.id);
      expect(deleted!.isDeleted, isTrue);
      final raw = await col('habitos').doc(a.id).get();
      expect(raw.exists, isTrue, reason: 'nunca hard delete');
    });

    test('updateHabit guarda los campos editables y el historial', () async {
      final habit = await repository.createHabit(habitDraft(), today: today);
      final updated = habit.copyWith(
        name: 'Beber 2L',
        periodicityTimeline: [
          ...habit.periodicityTimeline,
          PeriodicityEntry(
            periodicity: const Periodicity(
              type: PeriodicityType.weekly,
              timesPerPeriod: 3,
            ),
            since: day(2026, 9, 14),
          ),
        ],
        reminderTime: '09:30',
      );

      await repository.updateHabit(updated);

      final data = (await col('habitos').doc(habit.id).get()).data()!;
      expect(data['nombre'], 'Beber 2L');
      expect(data['periodicidad'], {'tipo': 'daily', 'veces': 1});
      expect(data['cambiosPeriodicidad'], [
        {'tipo': 'weekly', 'veces': 3, 'desde': '2026-09-14'},
      ]);
      expect(data['recordatorioHora'], '09:30');
      final reloaded = await repository.getHabit(habit.id);
      expect(reloaded!.periodicityTimeline, hasLength(2));
      // El cambio es diferido: hasta el 14 sigue vigente el objetivo viejo.
      expect(
        reloaded.periodicityOn(day(2026, 9, 13)).type,
        PeriodicityType.daily,
      );
      expect(
        reloaded.periodicityOn(day(2026, 9, 14)).type,
        PeriodicityType.weekly,
      );
    });

    test('los registros sobreviven al soft delete', () async {
      final habit = await repository.createHabit(habitDraft(), today: today);
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );

      await repository.softDeleteHabit(habit.id);

      expect(await repository.fetchHabitLogs(habit.id), hasLength(1));
      final week = await repository
          .watchLogsBetween(day(2026, 9, 7), day(2026, 9, 13))
          .first;
      expect(week.single.habitId, habit.id);
    });

    test('marcar usa id determinista y es idempotente', () async {
      final habit = await repository.createHabit(habitDraft(), today: today);

      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );
      final first = (await col(
        'registros',
      ).doc('${habit.id}_2026-09-10').get()).data()!;
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );

      final all = await col('registros').get();
      expect(all.docs, hasLength(1));
      final second = all.docs.single.data();
      expect(second['createdAt'], first['createdAt']);
      expect(second.keys.toSet(), {
        'habitoId',
        'dia',
        'tipo',
        'completedCount',
        'targetCount',
        'tz',
        'createdAt',
      });
      expect(second['dia'], '2026-09-10');
      expect(second['tipo'], 'completed');
      expect(second['tz'], 'Europe/Madrid');
    });

    test('un registro existente nunca se reescribe', () async {
      final habit = await repository.createHabit(habitDraft(), today: today);
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );
      final original = (await col('registros').get()).docs.single.data();

      // Marcar de nuevo no genera ninguna escritura: marcar es create,
      // desmarcar es delete, y no hay update posible (las reglas lo
      // prohíben, así el histórico es inmutable por construcción).
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );

      final all = await col('registros').get();
      expect(all.docs, hasLength(1));
      expect(all.docs.single.data(), original);
    });

    test('desmarcar borra el registro y es idempotente', () async {
      final habit = await repository.createHabit(habitDraft(), today: today);
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );

      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: false,
      );
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: false,
      );

      expect((await col('registros').get()).docs, isEmpty);
    });

    test('consulta por rango de fechas y por hábito', () async {
      final a = await repository.createHabit(
        habitDraft(name: 'A'),
        today: today,
      );
      final b = await repository.createHabit(
        habitDraft(name: 'B'),
        today: today,
      );
      for (final d in [day(2026, 8, 31), day(2026, 9, 5), day(2026, 9, 10)]) {
        await repository.setHabitCompletion(
          habitId: a.id,
          date: d,
          completed: true,
        );
      }
      await repository.setHabitCompletion(
        habitId: b.id,
        date: day(2026, 9, 5),
        completed: true,
      );

      final range = await repository
          .watchLogsBetween(day(2026, 9, 1), day(2026, 9, 9))
          .first;
      expect(range.map((l) => '${l.habitId}:${l.date.day}').toSet(), {
        '${a.id}:5',
        '${b.id}:5',
      });
      final onlyA = await repository.fetchHabitLogs(
        a.id,
        from: day(2026, 9, 1),
        to: day(2026, 9, 30),
      );
      expect(onlyA.map((l) => l.date.day), [5, 10]);
      expect(await repository.fetchHabitLogs(a.id), hasLength(3));
    });

    test('watchLogsBetween reacciona a marcar y desmarcar', () async {
      final habit = await repository.createHabit(habitDraft(), today: today);
      final emissions = <int>[];
      final sub = repository
          .watchLogsBetween(day(2026, 9, 7), day(2026, 9, 13))
          .listen((logs) => emissions.add(logs.length));
      await Future<void>.delayed(Duration.zero);

      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );
      await Future<void>.delayed(Duration.zero);
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: false,
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emissions, [0, 1, 0]);
    });

    test('crea y edita ámbitos personalizados', () async {
      final ambito = await repository.createAmbito(ambitoDraft);
      var data = (await col('ambitos').doc(ambito.id).get()).data()!;
      expect(data['esPredefinido'], isFalse);
      expect(data['nombre'], 'Música');

      await repository.updateAmbito(
        ambito.copyWith(name: 'Guitarra', emoji: '🎵'),
      );

      data = (await col('ambitos').doc(ambito.id).get()).data()!;
      expect(data['nombre'], 'Guitarra');
      expect(data['emoji'], '🎵');
      expect(data['esPredefinido'], isFalse);
      final ambitos = await repository.watchAmbitos().first;
      expect(ambitos.map((a) => a.id), [Ambito.generalId, 'salud', ambito.id]);
    });

    test('eliminar un ámbito reasigna todos sus hábitos a General', () async {
      final custom = await repository.createAmbito(ambitoDraft);
      final active = await repository.createHabit(
        habitDraft(name: 'Activo', ambitoId: custom.id),
        today: today,
      );
      final deleted = await repository.createHabit(
        habitDraft(name: 'Borrado', ambitoId: custom.id),
        today: today,
      );
      final other = await repository.createHabit(
        habitDraft(name: 'Otro'),
        today: today,
      );
      await repository.setHabitCompletion(
        habitId: active.id,
        date: today,
        completed: true,
      );
      await repository.softDeleteHabit(deleted.id);

      await repository.deleteAmbito(custom.id);

      expect((await col('ambitos').doc(custom.id).get()).exists, isFalse);
      expect(
        (await repository.getHabit(active.id))!.ambitoId,
        Ambito.generalId,
      );
      expect(
        (await repository.getHabit(deleted.id))!.ambitoId,
        Ambito.generalId,
      );
      expect((await repository.getHabit(other.id))!.ambitoId, 'salud');
      expect(await repository.fetchHabitLogs(active.id), hasLength(1));
    });

    test('General no se puede eliminar', () async {
      await expectLater(
        repository.deleteAmbito(Ambito.generalId),
        throwsA(
          isA<HabitsException>().having(
            (e) => e.failure,
            'failure',
            HabitsFailure.generalAmbitoProtected,
          ),
        ),
      );
      expect((await col('ambitos').doc(Ambito.generalId).get()).exists, true);
    });

    test(
      'sin cache/rachas la app funciona: la caché es prescindible',
      () async {
        expect(await repository.watchStreakCache().first, isNull);
        expect(await repository.fetchStreakCache(), isNull);
      },
    );

    test('cache/rachas se mapea cuando existe', () async {
      await col('cache').doc('rachas').set({
        'rachaActual': 12,
        'mejorRacha': 20,
        'ultimoDiaActividad': '2026-09-09',
        'calculadoHasta': '2026-09-09',
        'version': 2,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final cache = await repository.watchStreakCache().first;

      expect(cache!.currentStreak, 12);
      expect(cache.bestStreak, 20);
      expect(cache.lastActivityDay, day(2026, 9, 9));
      expect(cache.calculatedThrough, day(2026, 9, 9));
      expect(cache.algorithmVersion, 2);
    });

    test(
      'saveStreakCache escribe exactamente los campos de las reglas',
      () async {
        await repository.saveStreakCache(
          StreakCacheEntry(
            currentStreak: 4,
            bestStreak: 9,
            lastActivityDay: today,
            calculatedThrough: today,
            algorithmVersion: 2,
          ),
        );

        final data = (await col('cache').doc('rachas').get()).data()!;
        expect(data.keys.toSet(), {
          'rachaActual',
          'mejorRacha',
          'ultimoDiaActividad',
          'calculadoHasta',
          'version',
          'updatedAt',
        });
        expect(data['rachaActual'], 4);
        expect(data['calculadoHasta'], '2026-09-10');
      },
    );

    test('la caché se puede borrar entera', () async {
      await repository.saveStreakCache(
        StreakCacheEntry(
          currentStreak: 4,
          bestStreak: 9,
          lastActivityDay: today,
          calculatedThrough: today,
          algorithmVersion: 2,
        ),
      );

      await repository.clearStreakCache();

      expect((await col('cache').doc('rachas').get()).exists, isFalse);
      expect(await repository.fetchStreakCache(), isNull);
    });

    test('activityDays solo cuenta la actividad real', () async {
      final habit = await repository.createHabit(habitDraft(), today: today);
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );
      // Registro legacy escrito directamente, como los que puedan existir de
      // antes de la fase 5: se conserva pero NO cuenta como actividad.
      await col('registros').doc('${habit.id}_2026-09-09').set({
        'habitoId': habit.id,
        'dia': '2026-09-09',
        'tipo': 'plannedRest',
        'createdAt': FieldValue.serverTimestamp(),
      });

      expect(await repository.fetchActivityDays(), {today});
      final logs = await repository.fetchHabitLogs(habit.id);
      expect(logs, hasLength(2), reason: 'el histórico se conserva entero');
      expect(logs.where((l) => l.isActivity), hasLength(1));
    });

    test('updateHabit borra los campos legacy del modelo antiguo', () async {
      // Migración perezosa: un hábito creado antes de la fase 5 se limpia
      // solo la primera vez que se edita, sin migración masiva.
      await col('habitos').doc('viejo').set({
        'nombre': 'Antiguo',
        'emoji': '📖',
        'colorValue': 1,
        'ambitoId': 'salud',
        'periodicidad': 'weekly',
        'historialPeriodicidad': [],
        'descansosPermitidos': 2,
        'tareaRecuperacion': '5 páginas',
        'recuperacionCooldownDias': 7,
        'orden': 0,
        'deletedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final habit = (await repository.getHabit('viejo'))!;
      // El string suelto se interpreta como 1 vez por semana.
      expect(habit.periodicityOn(today).type, PeriodicityType.weekly);
      expect(habit.periodicityOn(today).timesPerPeriod, 1);

      await repository.updateHabit(habit.copyWith(name: 'Migrado'));

      final data = (await col('habitos').doc('viejo').get()).data()!;
      expect(data['nombre'], 'Migrado');
      expect(data['periodicidad'], {'tipo': 'weekly', 'veces': 1});
      expect(data.containsKey('descansosPermitidos'), isFalse);
      expect(data.containsKey('tareaRecuperacion'), isFalse);
      expect(data.containsKey('recuperacionCooldownDias'), isFalse);
      expect(data.containsKey('historialPeriodicidad'), isFalse);
    });
  });
}
