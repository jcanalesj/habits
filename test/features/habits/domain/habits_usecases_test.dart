import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/3_data/data.dart';

import '../../../helpers/habits_test_helpers.dart';

void main() {
  setUpAll(initializeTimezones);

  final today = day(2026, 9, 10); // jueves
  final nowInstant = DateTime.utc(2026, 9, 10, 12);
  late InMemoryHabitsRepository repository;
  late InMemoryWildcardsRepository wildcards;

  setUp(() {
    repository = InMemoryHabitsRepository(now: () => nowInstant, today: today);
    wildcards = InMemoryWildcardsRepository();
  });

  tearDown(() async {
    await repository.dispose();
    await wildcards.dispose();
  });

  WatchHomeSummaryUsecase homeSummary() {
    final calendar = LogicalCalendar('Europe/Madrid');
    return WatchHomeSummaryUsecase(
      habits: repository,
      wildcards: wildcards,
      calendar: calendar,
      goalProgress: GoalProgressCalculator(PeriodicityResolver(calendar)),
      clock: FixedClock(nowInstant),
    );
  }

  group('CreateHabitUsecase', () {
    test('valida nombre, emoji, cupos y hora', () async {
      final result = await CreateHabitUsecase(repository).execute(
        const HabitDraft(
          name: ' ',
          ambitoId: 'salud',
          // 10 veces por semana es imposible: como mucho hay un registro
          // por día.
          periodicity: Periodicity(
            type: PeriodicityType.weekly,
            timesPerPeriod: 10,
          ),
          colorValue: 1,
          emoji: '',
          reminderTime: '25:99',
        ),
        today: today,
      );

      expect(result, isA<CreateHabitValidationFailed>());
      expect((result as CreateHabitValidationFailed).errors, {
        HabitValidationError.nameRequired,
        HabitValidationError.emojiRequired,
        HabitValidationError.invalidTimesPerPeriod,
        HabitValidationError.invalidReminderTime,
      });
    });

    test('crea el hábito recortando espacios', () async {
      final result = await CreateHabitUsecase(
        repository,
      ).execute(habitDraft(name: '  Correr  '), today: today);

      expect(result, isA<CreateHabitSuccess>());
      final habit = (result as CreateHabitSuccess).habit;
      expect(habit.name, 'Correr');
      expect(await repository.getHabit(habit.id), isNotNull);
    });

    test('traduce ámbito inexistente a fallo de dominio', () async {
      final result = await CreateHabitUsecase(
        repository,
      ).execute(habitDraft(ambitoId: 'nope'), today: today);

      expect(
        (result as CreateHabitFailed).failure,
        HabitsFailure.ambitoNotFound,
      );
    });
  });

  group('UpdateHabitUsecase', () {
    test('no toca la línea temporal de periodicidad', () async {
      // Cambiar la periodicidad tiene su propio usecase, porque implica
      // calcular una fecha efectiva y respetar el periodo en curso.
      final original = (await repository.watchActiveHabits().first).first;

      final result = await UpdateHabitUsecase(repository).execute(
        original: original,
        updated: original.copyWith(name: 'Agua'),
      );

      expect(result, isA<UpdateHabitSuccess>());
      final saved = (await repository.getHabit(original.id))!;
      expect(saved.name, 'Agua');
      expect(saved.periodicityTimeline, original.periodicityTimeline);
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
    test('rechaza cualquier fecha que no sea hoy', () async {
      final habit = (await repository.watchActiveHabits().first).first;
      final usecase = ToggleHabitCompletionUsecase(repository);

      for (final fecha in [today.next, today.previous, day(2020, 1, 1)]) {
        final result = await usecase.execute(
          habitId: habit.id,
          date: fecha,
          completed: true,
          today: today,
        );
        expect(result, isA<ToggleHabitCompletionNotToday>(), reason: '\$fecha');
      }

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
        today: today,
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
      'calcula la racha en vivo y decide completado por registros',
      () async {
        final first = await homeSummary().execute(today: today).first;
        final habit = first.habits.first;

        expect(first.today, today);
        expect(first.isCompletedOn(habit.id, today), isFalse);
        // La semana sembrada va de lunes a ayer, así que la racha está
        // intacta pero hoy queda pendiente.
        expect(first.isCompletedOn(habit.id, today.previous), isTrue);
        expect(first.streak.status, StreakStatus.pendingToday);
        expect(first.streak.currentStreak, greaterThan(0));
        expect(first.wildcards, WildcardBalance.empty);
      },
    );

    test('emite al marcar y la racha sube sin tocar ninguna caché', () async {
      final emissions = <HomeSummary>[];
      final sub = homeSummary().execute(today: today).listen(emissions.add);
      await Future<void>.delayed(Duration.zero);
      final habit = emissions.first.habits.first;
      final antes = emissions.first.streak.currentStreak;

      await repository.setHabitCompletion(
        habitId: habit.id,
        date: today,
        completed: true,
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emissions.last.isCompletedOn(habit.id, today), isTrue);
      expect(emissions.last.streak.currentStreak, antes + 1);
      expect(emissions.last.streak.status, StreakStatus.completedToday);
      // Nadie ha escrito la caché: la racha viene de los registros.
      expect(await repository.fetchStreakCache(), isNull);
    });

    test('incluye el progreso del objetivo de cada hábito', () async {
      final summary = await homeSummary().execute(today: today).first;

      // "Entrenar" está sembrado como 3 veces por semana.
      final entrenar = summary.habits.firstWhere((h) => h.id == 'entrenar');
      final progress = summary.progressOf(entrenar.id)!;

      expect(progress.goal, 3);
      expect(progress.period.type, PeriodicityType.weekly);
      expect(progress.period.start, day(2026, 9, 7));
      expect(progress.completed, greaterThan(0));
    });

    test('refleja el saldo de comodines y los días protegidos', () async {
      await wildcards.ensureGranted(today.yearMonth);

      final summary = await homeSummary().execute(today: today).first;

      expect(summary.wildcards.available, 1);
    });
  });
}
