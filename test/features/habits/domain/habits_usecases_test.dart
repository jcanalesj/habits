import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/3_data/data.dart';

import '../../../helpers/habits_test_helpers.dart';

void main() {
  final today = day(2026, 9, 10);
  late InMemoryHabitsRepository repository;

  setUp(() {
    repository = InMemoryHabitsRepository(now: () => today);
  });

  group('CreateHabitUsecase', () {
    test('valida nombre, emoji, cupos y hora', () async {
      final result = await CreateHabitUsecase(repository).execute(
        HabitDraft(
          name: ' ',
          ambitoId: 'salud',
          periodicity: Periodicity.daily,
          restDaysAllowed: -1,
          recoveryCooldownDays: 0,
          colorValue: 1,
          emoji: '',
          reminderTime: '25:99',
        ),
      );

      expect(result, isA<CreateHabitValidationFailed>());
      expect((result as CreateHabitValidationFailed).errors, {
        HabitValidationError.nameRequired,
        HabitValidationError.emojiRequired,
        HabitValidationError.invalidRestDays,
        HabitValidationError.invalidRecoveryCooldown,
        HabitValidationError.invalidReminderTime,
      });
    });

    test('crea el hábito recortando espacios', () async {
      final result = await CreateHabitUsecase(
        repository,
      ).execute(habitDraft(name: '  Correr  '));

      expect(result, isA<CreateHabitSuccess>());
      final habit = (result as CreateHabitSuccess).habit;
      expect(habit.name, 'Correr');
      expect(await repository.getHabit(habit.id), isNotNull);
    });

    test('traduce ámbito inexistente a fallo de dominio', () async {
      final result = await CreateHabitUsecase(
        repository,
      ).execute(habitDraft(ambitoId: 'nope'));

      expect(
        (result as CreateHabitFailed).failure,
        HabitsFailure.ambitoNotFound,
      );
    });
  });

  group('UpdateHabitUsecase', () {
    test('anota el cambio de periodicidad en el historial', () async {
      final original = (await repository.watchActiveHabits().first).first;
      final result = await UpdateHabitUsecase(repository).execute(
        original: original,
        updated: original.copyWith(periodicity: Periodicity.weekly),
        today: today,
      );

      expect(result, isA<UpdateHabitSuccess>());
      final saved = (await repository.getHabit(original.id))!;
      expect(saved.periodicity, Periodicity.weekly);
      expect(saved.periodicityHistory, [
        PeriodicityChange(periodicity: Periodicity.daily, since: today),
      ]);
    });

    test('no toca el historial si la periodicidad no cambia', () async {
      final original = (await repository.watchActiveHabits().first).first;
      await UpdateHabitUsecase(repository).execute(
        original: original,
        updated: original.copyWith(name: 'Agua'),
      );

      expect(
        (await repository.getHabit(original.id))!.periodicityHistory,
        isEmpty,
      );
    });

    test('rechaza editar un hábito eliminado', () async {
      final original = (await repository.watchActiveHabits().first).first;
      await repository.softDeleteHabit(original.id);
      final deleted = (await repository.getHabit(original.id))!;

      final result = await UpdateHabitUsecase(repository).execute(
        original: deleted,
        updated: deleted.copyWith(name: 'x'),
      );

      expect((result as UpdateHabitFailed).failure, HabitsFailure.habitDeleted);
    });
  });

  group('DeleteHabitUsecase', () {
    test('hace soft delete', () async {
      final habit = (await repository.watchActiveHabits().first).first;
      final result = await DeleteHabitUsecase(repository).execute(habit.id);

      expect(result, isA<DeleteHabitSuccess>());
      expect((await repository.getHabit(habit.id))!.isDeleted, isTrue);
    });

    test('devuelve fallo si no existe', () async {
      final result = await DeleteHabitUsecase(repository).execute('nope');
      expect(
        (result as DeleteHabitFailed).failure,
        HabitsFailure.habitNotFound,
      );
    });
  });

  group('ToggleHabitCompletionUsecase', () {
    test('rechaza fechas futuras sin tocar el repositorio', () async {
      final habit = (await repository.watchActiveHabits().first).first;
      final result = await ToggleHabitCompletionUsecase(repository).execute(
        habitId: habit.id,
        date: today.add(const Duration(days: 1)),
        completed: true,
        today: today,
      );

      expect(result, isA<ToggleHabitCompletionFutureDate>());
      expect(await repository.fetchHabitLogs(habit.id, from: today), isEmpty);
    });

    test('marca, es idempotente y desmarca', () async {
      final usecase = ToggleHabitCompletionUsecase(repository);
      final habit = (await repository.watchActiveHabits().first).first;

      await usecase.execute(
        habitId: habit.id,
        date: today,
        completed: true,
        today: today,
      );
      await usecase.execute(
        habitId: habit.id,
        date: today,
        completed: true,
        today: today,
      );
      expect(
        await repository.fetchHabitLogs(habit.id, from: today),
        hasLength(1),
      );

      final result = await usecase.execute(
        habitId: habit.id,
        date: today,
        completed: false,
        today: today,
      );
      expect(result, isA<ToggleHabitCompletionSuccess>());
      expect(await repository.fetchHabitLogs(habit.id, from: today), isEmpty);
    });

    test('rechaza hábitos eliminados o inexistentes', () async {
      final usecase = ToggleHabitCompletionUsecase(repository);
      final habit = (await repository.watchActiveHabits().first).first;
      await repository.softDeleteHabit(habit.id);

      final deleted = await usecase.execute(
        habitId: habit.id,
        date: today,
        completed: true,
        today: today,
      );
      final missing = await usecase.execute(
        habitId: 'nope',
        date: today,
        completed: true,
        today: today,
      );

      expect(
        (deleted as ToggleHabitCompletionFailed).failure,
        HabitsFailure.habitDeleted,
      );
      expect(
        (missing as ToggleHabitCompletionFailed).failure,
        HabitsFailure.habitNotFound,
      );
    });
  });

  group('Ámbitos', () {
    test('crear valida y recorta; editar conserva isPredefined', () async {
      final invalid = await CreateAmbitoUsecase(
        repository,
      ).execute(const AmbitoDraft(name: '', emoji: '', colorValue: 1));
      expect((invalid as CreateAmbitoValidationFailed).errors, {
        AmbitoValidationError.nameRequired,
        AmbitoValidationError.emojiRequired,
      });

      final created = await CreateAmbitoUsecase(repository).execute(
        const AmbitoDraft(name: '  Música ', emoji: '🎸', colorValue: 1),
      );
      final ambito = (created as CreateAmbitoSuccess).ambito;
      expect(ambito.name, 'Música');
      expect(ambito.isPredefined, isFalse);

      final general = (await repository.watchAmbitos().first).first;
      final edited = await UpdateAmbitoUsecase(
        repository,
      ).execute(general.copyWith(name: 'Todo', isPredefined: false));
      expect(edited, isA<UpdateAmbitoSuccess>());
      final saved = (await repository.watchAmbitos().first).first;
      expect(saved.name, 'Todo');
      expect(saved.isPredefined, isTrue);
    });

    test('eliminar reasigna a General y protege General', () async {
      final custom = await repository.createAmbito(ambitoDraft);
      final habit = await repository.createHabit(
        habitDraft(ambitoId: custom.id),
      );

      final protectedResult = await DeleteAmbitoUsecase(
        repository,
      ).execute(Ambito.generalId);
      expect(protectedResult, isA<DeleteAmbitoProtected>());

      final result = await DeleteAmbitoUsecase(repository).execute(custom.id);
      expect(result, isA<DeleteAmbitoSuccess>());
      expect((await repository.getHabit(habit.id))!.ambitoId, Ambito.generalId);
    });
  });

  group('WatchHomeSummaryUsecase', () {
    test(
      'funciona sin cache/rachas y decide completado por registros',
      () async {
        final usecase = WatchHomeSummaryUsecase(repository);
        final first = await usecase.execute(today: today).first;
        final habit = first.habits.first;

        expect(first.streaks.isEmpty, isTrue);
        expect(first.generalStreak.count, 0);
        expect(first.habitStreak(habit.id), 0);
        expect(first.isCompletedOn(habit.id, today), isFalse);
        // La semana sembrada va de lunes a ayer.
        expect(
          first.isCompletedOn(
            habit.id,
            today.subtract(const Duration(days: 1)),
          ),
          isTrue,
        );
      },
    );

    test('emite al marcar y refleja la caché cuando aparece', () async {
      final usecase = WatchHomeSummaryUsecase(repository);
      final emissions = <HomeSummary>[];
      final sub = usecase.execute(today: today).listen(emissions.add);
      await Future<void>.delayed(Duration.zero);
      final habit = emissions.first.habits.first;

      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last.isCompletedOn(habit.id, today), isTrue);

      repository.setStreaks(
        StreaksSnapshot(
          general: const GeneralStreak(count: 7),
          habits: {habit.id: const HabitStreak(current: 3, best: 9)},
          calculatedThrough: today,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emissions.last.generalStreak.count, 7);
      expect(emissions.last.habitStreak(habit.id), 3);
      // La caché no decide el cumplimiento: sigue viniendo de los registros.
      expect(emissions.last.isCompletedOn(habit.id, today), isTrue);
    });
  });
}
