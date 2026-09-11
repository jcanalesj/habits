import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/3_data/data.dart';

import '../../../helpers/habits_test_helpers.dart';

void main() {
  group('InMemoryHabitsRepository', () {
    late InMemoryHabitsRepository repository;
    final today = day(2026, 9, 10); // jueves
    final nowInstant = DateTime.utc(2026, 9, 10, 12);

    setUp(() {
      repository = InMemoryHabitsRepository(
        seeded: false,
        now: () => nowInstant,
        today: today,
      );
      repository.createAmbito(
        const AmbitoDraft(name: 'x', emoji: 'x', colorValue: 1),
      );
    });

    test(
      'la versión sembrada trae ámbitos, hábitos y registros de la semana',
      () async {
        final seeded = InMemoryHabitsRepository(
          now: () => nowInstant,
          today: today,
        );

        expect(await seeded.watchAmbitos().first, hasLength(5));
        expect((await seeded.watchAmbitos().first).first.id, Ambito.generalId);
        expect(await seeded.watchActiveHabits().first, hasLength(5));
        final logs = await seeded
            .watchLogsBetween(day(2026, 9, 7), day(2026, 9, 13))
            .first;
        expect(logs, isNotEmpty);
        // La caché de rachas no existe hasta que alguien la calcula: la
        // app tiene que funcionar sin ella.
        expect(await seeded.watchStreakCache().first, isNull);
        expect(await seeded.fetchActivityDays(), isNotEmpty);
      },
    );

    test('crea un hábito y lo emite en el stream de activos', () async {
      final emissions = <List<Habit>>[];
      final sub = repository.watchActiveHabits().listen(emissions.add);
      await Future<void>.delayed(Duration.zero);

      final ambitoId = (await repository.watchAmbitos().first).first.id;
      final habit = await repository.createHabit(
        habitDraft(ambitoId: ambitoId),
        today: today,
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emissions.first, isEmpty);
      expect(emissions.last.map((h) => h.id), [habit.id]);
      expect(habit.createdAt, nowInstant);
    });

    test('soft delete oculta el hábito y conserva sus registros', () async {
      final ambitoId = (await repository.watchAmbitos().first).first.id;
      final habit = await repository.createHabit(
        habitDraft(ambitoId: ambitoId),
        today: today,
      );
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );

      await repository.softDeleteHabit(habit.id);

      expect(await repository.watchActiveHabits().first, isEmpty);
      expect((await repository.getHabit(habit.id))!.isDeleted, isTrue);
      expect(await repository.fetchHabitLogs(habit.id), hasLength(1));
      // Un registro NUEVO en un hábito eliminado se rechaza, igual que lo
      // hacen las Security Rules.
      await expectLater(
        repository.setHabitCompletion(
          habitId: habit.id,
          date: day(2026, 9, 11),
          completed: true,
        ),
        throwsA(
          isA<HabitsException>().having(
            (e) => e.failure,
            'failure',
            HabitsFailure.habitDeleted,
          ),
        ),
      );
      // Y su histórico es inmutable: tampoco se puede borrar.
      await expectLater(
        repository.setHabitCompletion(
          habitId: habit.id,
          date: today,
          completed: false,
        ),
        throwsA(isA<HabitsException>()),
      );
      expect(await repository.fetchHabitLogs(habit.id), hasLength(1));
    });

    test('marcar es idempotente y desmarcar borra el registro', () async {
      final ambitoId = (await repository.watchAmbitos().first).first.id;
      final habit = await repository.createHabit(
        habitDraft(ambitoId: ambitoId),
        today: today,
      );

      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );
      var logs = await repository.fetchHabitLogs(habit.id);
      expect(logs, hasLength(1));
      expect(logs.single.id, '${habit.id}_2026-09-10');

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
      logs = await repository.fetchHabitLogs(habit.id);
      expect(logs, isEmpty);
    });

    test('consulta registros por rango de fechas y por hábito', () async {
      final ambitoId = (await repository.watchAmbitos().first).first.id;
      final a = await repository.createHabit(
        habitDraft(ambitoId: ambitoId),
        today: today,
      );
      final b = await repository.createHabit(
        habitDraft(ambitoId: ambitoId),
        today: today,
      );
      for (final d in [day(2026, 9, 1), day(2026, 9, 5), day(2026, 9, 10)]) {
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
          .watchLogsBetween(day(2026, 9, 2), day(2026, 9, 9))
          .first;
      expect(range.map((l) => l.habitId), [a.id, b.id]);

      final onlyA = await repository.fetchHabitLogs(
        a.id,
        from: day(2026, 9, 5),
      );
      expect(onlyA.map((l) => l.date), [day(2026, 9, 5), day(2026, 9, 10)]);
    });

    test('eliminar un ámbito reasigna sus hábitos a General', () async {
      final general = await repository.createAmbito(
        const AmbitoDraft(name: 'General', emoji: '✨', colorValue: 1),
      );
      // El id fijo de General lo impone el modelo; simulamos su presencia.
      await repository.updateAmbito(general.copyWith(name: 'General'));
      final custom = await repository.createAmbito(ambitoDraft);
      final habit = await repository.createHabit(
        habitDraft(ambitoId: custom.id),
        today: today,
      );
      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );

      await repository.deleteAmbito(custom.id);

      final ambitos = await repository.watchAmbitos().first;
      expect(ambitos.map((a) => a.id), isNot(contains(custom.id)));
      final moved = (await repository.watchActiveHabits().first).single;
      expect(moved.ambitoId, Ambito.generalId);
      expect(await repository.fetchHabitLogs(habit.id), hasLength(1));
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
    });
  });
}
