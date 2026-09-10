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
        now: () => today,
      );
      await seedAmbito(Ambito.generalId, order: 0);
      await seedAmbito('salud', order: 1);
    });

    test('createHabit escribe exactamente los campos de las reglas', () async {
      final habit = await repository.createHabit(
        habitDraft(reminderTime: '18:00'),
      );

      final doc = await col('habitos').doc(habit.id).get();
      final data = doc.data()!;
      expect(data.keys.toSet(), {
        'nombre',
        'emoji',
        'colorValue',
        'ambitoId',
        'periodicidad',
        'historialPeriodicidad',
        'descansosPermitidos',
        'tareaRecuperacion',
        'recuperacionCooldownDias',
        'recordatorioHora',
        'orden',
        'deletedAt',
        'createdAt',
        'updatedAt',
      });
      expect(data['nombre'], 'Beber agua');
      expect(data['periodicidad'], 'daily');
      expect(data['historialPeriodicidad'], isEmpty);
      expect(data['deletedAt'], isNull);
      expect(data['recordatorioHora'], '18:00');
      expect(data['orden'], today.millisecondsSinceEpoch);
      expect(data['createdAt'], isA<Timestamp>());
    });

    test('watchActiveHabits emite al crear y excluye los eliminados', () async {
      final emissions = <List<String>>[];
      final sub = repository.watchActiveHabits().listen(
        (habits) => emissions.add(habits.map((h) => h.name).toList()),
      );
      await Future<void>.delayed(Duration.zero);

      final a = await repository.createHabit(habitDraft(name: 'A'));
      await repository.createHabit(habitDraft(name: 'B'));
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
      final habit = await repository.createHabit(habitDraft());
      final updated = habit.copyWith(
        name: 'Beber 2L',
        periodicity: Periodicity.weekly,
        periodicityHistory: [
          PeriodicityChange(periodicity: Periodicity.daily, since: today),
        ],
        reminderTime: '09:30',
      );

      await repository.updateHabit(updated);

      final data = (await col('habitos').doc(habit.id).get()).data()!;
      expect(data['nombre'], 'Beber 2L');
      expect(data['periodicidad'], 'weekly');
      expect(data['historialPeriodicidad'], [
        {'periodicidad': 'daily', 'desde': '2026-09-10'},
      ]);
      expect(data['recordatorioHora'], '09:30');
      final reloaded = await repository.getHabit(habit.id);
      expect(reloaded!.periodicityHistory.single.since, today);
    });

    test('los registros sobreviven al soft delete', () async {
      final habit = await repository.createHabit(habitDraft());
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
      final habit = await repository.createHabit(habitDraft());

      await repository.setHabitCompletion(
        habitId: habit.id,
        date: DateTime(2026, 9, 10, 23, 15),
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
        'tz',
        'createdAt',
      });
      expect(second['dia'], '2026-09-10');
      expect(second['tipo'], 'completed');
      expect(second['tz'], 'Europe/Madrid');
    });

    test(
      'cambiar el tipo de un registro existente solo actualiza tipo',
      () async {
        final habit = await repository.createHabit(habitDraft());
        await repository.setHabitCompletion(
          habitId: habit.id,
          date: today,
          completed: true,
        );

        await repository.setHabitCompletion(
          habitId: habit.id,
          date: today,
          completed: true,
          type: HabitLogType.recovery,
        );

        final all = await col('registros').get();
        expect(all.docs, hasLength(1));
        expect(all.docs.single.data()['tipo'], 'recovery');
        expect(all.docs.single.data()['updatedAt'], isA<Timestamp>());
      },
    );

    test('desmarcar borra el registro y es idempotente', () async {
      final habit = await repository.createHabit(habitDraft());
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
      final a = await repository.createHabit(habitDraft(name: 'A'));
      final b = await repository.createHabit(habitDraft(name: 'B'));
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
      final habit = await repository.createHabit(habitDraft());
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
      );
      final deleted = await repository.createHabit(
        habitDraft(name: 'Borrado', ambitoId: custom.id),
      );
      final other = await repository.createHabit(habitDraft(name: 'Otro'));
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

    test('sin cache/rachas los streams funcionan con rachas vacías', () async {
      final streaks = await repository.watchStreaks().first;

      expect(streaks, StreaksSnapshot.empty);
      expect(streaks.isEmpty, isTrue);
      expect(streaks.habitStreak('x').current, 0);
    });

    test('cache/rachas se mapea cuando existe', () async {
      await col('cache').doc('rachas').set({
        'general': {
          'actual': 12,
          'mejor': 20,
          'comodinDisponible': false,
          'ultimoDiaRegistrado': '2026-09-09',
        },
        'habitos': {
          'h1': {'actual': 3, 'mejor': 5},
        },
        'ambitos': {
          'salud': {'actual': 4, 'mejor': 6, 'comodinDisponible': true},
        },
        'calculadoHasta': '2026-09-09',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final streaks = await repository.watchStreaks().first;

      expect(streaks.general.count, 12);
      expect(streaks.general.comodinDisponible, isFalse);
      expect(streaks.general.lastLogDate, day(2026, 9, 9));
      expect(streaks.habitStreak('h1'), const HabitStreak(current: 3, best: 5));
      expect(streaks.ambitoStreak('salud').best, 6);
      expect(streaks.calculatedThrough, day(2026, 9, 9));
    });
  });
}
