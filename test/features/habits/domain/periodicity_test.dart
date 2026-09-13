import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/goal_progress_calculator.dart';
import 'package:habits/features/habits/1_domain/services/logical_calendar.dart';
import 'package:habits/features/habits/1_domain/services/periodicity_resolver.dart';
import 'package:habits/features/habits/1_domain/usecases/change_habit_periodicity_usecase.dart';
import 'package:habits/features/habits/3_data/repositories/in_memory_habits_repository.dart';

LogicalDate d(String key) => LogicalDate.parse(key);

Periodicity weekly(int times) =>
    Periodicity(type: PeriodicityType.weekly, timesPerPeriod: times);
Periodicity monthly(int times) =>
    Periodicity(type: PeriodicityType.monthly, timesPerPeriod: times);
Periodicity yearly(int times) =>
    Periodicity(type: PeriodicityType.yearly, timesPerPeriod: times);

Habit habitWith(List<PeriodicityEntry> timeline, {String id = 'h1'}) => Habit(
  id: id,
  name: 'Gimnasio',
  ambitoId: 'salud',
  periodicityTimeline: timeline,
  colorValue: 0xFF000000,
  emoji: '🏋️',
  createdAt: DateTime.utc(2026, 1, 1),
);

List<HabitLog> logsOn(List<String> keys, {String habitId = 'h1'}) => [
  for (final key in keys)
    HabitLog(id: '${habitId}_$key', habitId: habitId, date: d(key)),
];

void main() {
  setUpAll(initializeTimezones);

  late PeriodicityResolver resolver;
  late GoalProgressCalculator progress;

  setUp(() {
    resolver = PeriodicityResolver(LogicalCalendar('Europe/Madrid'));
    progress = GoalProgressCalculator(resolver);
  });

  group('fecha efectiva de un cambio de objetivo', () {
    // Regla: el nuevo objetivo empieza en el siguiente periodo natural
    // COMPLETO del tipo nuevo. Nunca hay periodos parciales ni prorrateo.

    test('semanal → el lunes siguiente (cambio hecho un jueves)', () {
      // 10 sep 2026 es jueves; su semana empieza el lunes 7.
      expect(
        resolver.effectiveDateFor(PeriodicityType.weekly, d('2026-09-10')),
        d('2026-09-14'),
      );
    });

    test('semanal → el lunes siguiente aunque hoy sea lunes', () {
      // La semana en curso ya empezó: no se toca.
      expect(
        resolver.effectiveDateFor(PeriodicityType.weekly, d('2026-09-07')),
        d('2026-09-14'),
      );
    });

    test('semanal → el lunes siguiente si hoy es domingo', () {
      expect(
        resolver.effectiveDateFor(PeriodicityType.weekly, d('2026-09-13')),
        d('2026-09-14'),
      );
    });

    test('3/semana → 12/mes empieza el día 1 del mes siguiente', () {
      expect(
        resolver.effectiveDateFor(PeriodicityType.monthly, d('2026-09-10')),
        d('2026-10-01'),
      );
    });

    test('mensual → el día 1 siguiente cruzando el cambio de año', () {
      expect(
        resolver.effectiveDateFor(PeriodicityType.monthly, d('2026-12-20')),
        d('2027-01-01'),
      );
    });

    test('anual → el próximo 1 de enero', () {
      expect(
        resolver.effectiveDateFor(PeriodicityType.yearly, d('2026-09-10')),
        d('2027-01-01'),
      );
    });

    test('diario → mañana', () {
      expect(
        resolver.effectiveDateFor(PeriodicityType.daily, d('2026-09-10')),
        d('2026-09-11'),
      );
    });

    test('3/semana → 5/semana también espera al lunes siguiente', () {
      // Cambio de cantidad dentro del mismo tipo: misma regla.
      expect(
        resolver.effectiveDateFor(PeriodicityType.weekly, d('2026-09-10')),
        d('2026-09-14'),
      );
    });
  });

  group('configAt — qué objetivo estaba vigente', () {
    test('antes de la fecha efectiva sigue el objetivo antiguo', () {
      final timeline = [
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
        PeriodicityEntry(periodicity: weekly(5), since: d('2026-09-14')),
      ];

      expect(resolver.configAt(timeline, d('2026-09-13')), weekly(3));
      expect(resolver.configAt(timeline, d('2026-09-14')), weekly(5));
    });

    test('una entrada con fecha futura no está vigente todavía', () {
      final timeline = [
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
        PeriodicityEntry(periodicity: monthly(12), since: d('2026-10-01')),
      ];

      expect(resolver.configAt(timeline, d('2026-09-20')), weekly(3));
      expect(
        resolver.pendingChange(timeline, d('2026-09-20'))!.since,
        d('2026-10-01'),
      );
      expect(resolver.pendingChange(timeline, d('2026-10-05')), isNull);
    });

    test('recupera el objetivo de cualquier fecha pasada', () {
      // Es lo que permitirá calcular los rangos por hábito más adelante.
      final timeline = [
        PeriodicityEntry(periodicity: weekly(2), since: d('2026-01-01')),
        PeriodicityEntry(periodicity: weekly(4), since: d('2026-05-04')),
        PeriodicityEntry(periodicity: monthly(20), since: d('2026-09-01')),
      ];

      expect(resolver.configAt(timeline, d('2026-03-15')), weekly(2));
      expect(resolver.configAt(timeline, d('2026-06-15')), weekly(4));
      expect(resolver.configAt(timeline, d('2026-09-15')), monthly(20));
    });
  });

  group('progreso del objetivo', () {
    test('daily: el periodo es el propio día', () {
      final habit = habitWith([
        PeriodicityEntry(
          periodicity: Periodicity.daily,
          since: d('2026-09-01'),
        ),
      ]);

      final result = progress.forHabit(
        habit: habit,
        logs: logsOn(['2026-09-11']),
        today: d('2026-09-11'),
      );

      expect(result.goal, 1);
      expect(result.completed, 1);
      expect(result.isMet, isTrue);
      expect(result.period.start, d('2026-09-11'));
      expect(result.period.end, d('2026-09-11'));
    });

    test('X/semana cuenta dentro de la semana lunes-domingo', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
      ]);

      final result = progress.forHabit(
        habit: habit,
        logs: logsOn([
          '2026-09-06', // domingo anterior: fuera
          '2026-09-07',
          '2026-09-09',
          '2026-09-14', // lunes siguiente: fuera
        ]),
        today: d('2026-09-11'),
      );

      expect(result.completed, 2);
      expect(result.goal, 3);
      expect(result.isMet, isFalse);
      expect(result.period.start, d('2026-09-07'));
      expect(result.period.end, d('2026-09-13'));
    });

    test('da igual qué días concretos: 3 de 3 es 3 de 3', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
      ]);

      final lunMieVie = progress.forHabit(
        habit: habit,
        logs: logsOn(['2026-09-07', '2026-09-09', '2026-09-11']),
        today: d('2026-09-11'),
      );
      final marJueDom = progress.forHabit(
        habit: habit,
        logs: logsOn(['2026-09-08', '2026-09-10', '2026-09-13']),
        today: d('2026-09-11'),
      );

      expect(lunMieVie.completed, 3);
      expect(marJueDom.completed, 3);
      expect(lunMieVie.isMet, isTrue);
      expect(marJueDom.isMet, isTrue);
    });

    test('progreso 0/N cuando no hay nada hecho', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
      ]);

      final result = progress.forHabit(
        habit: habit,
        logs: const [],
        today: d('2026-09-11'),
      );

      expect(result.completed, 0);
      expect(result.fraction, 0);
    });

    test('se puede superar el objetivo: 5 de 3', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
      ]);

      final result = progress.forHabit(
        habit: habit,
        logs: logsOn([
          '2026-09-07',
          '2026-09-08',
          '2026-09-09',
          '2026-09-10',
          '2026-09-11',
        ]),
        today: d('2026-09-11'),
      );

      expect(result.completed, 5);
      expect(result.goal, 3);
      expect(result.fraction, 1.0, reason: 'la barra no se desborda');
    });

    test('X/mes cuenta dentro del mes natural', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: monthly(10), since: d('2026-01-01')),
      ]);

      final result = progress.forHabit(
        habit: habit,
        logs: logsOn([
          '2026-08-31', // fuera
          '2026-09-01', '2026-09-15', '2026-09-30',
          '2026-10-01', // fuera
        ]),
        today: d('2026-09-11'),
      );

      expect(result.completed, 3);
      expect(result.goal, 10);
      expect(result.period.start, d('2026-09-01'));
      expect(result.period.end, d('2026-09-30'));
    });

    test('X/año cuenta dentro del año natural', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: yearly(4), since: d('2026-01-01')),
      ]);

      final result = progress.forHabit(
        habit: habit,
        logs: logsOn(['2025-12-31', '2026-01-01', '2026-12-31', '2027-01-01']),
        today: d('2026-09-11'),
      );

      expect(result.completed, 2);
      expect(result.period.start, d('2026-01-01'));
      expect(result.period.end, d('2026-12-31'));
    });

    test('los registros legacy no cuentan como actividad', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
      ]);

      final result = progress.forHabit(
        habit: habit,
        logs: [
          HabitLog(id: 'a', habitId: 'h1', date: d('2026-09-08')),
          HabitLog(
            id: 'b',
            habitId: 'h1',
            date: d('2026-09-09'),
            type: HabitLogType.legacy,
          ),
        ],
        today: d('2026-09-11'),
      );

      expect(result.completed, 1);
    });

    test('el periodo en curso conserva el objetivo con el que empezó', () {
      // Cambio de 3 a 5 por semana con efecto el lunes 14: la semana del 7
      // al 13 sigue teniendo objetivo 3.
      final habit = habitWith([
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
        PeriodicityEntry(periodicity: weekly(5), since: d('2026-09-14')),
      ]);

      final semanaActual = progress.forHabit(
        habit: habit,
        logs: const [],
        today: d('2026-09-11'),
      );
      final semanaSiguiente = progress.forHabit(
        habit: habit,
        logs: const [],
        today: d('2026-09-16'),
      );

      expect(semanaActual.goal, 3);
      expect(semanaSiguiente.goal, 5);
    });

    test('weekly → monthly: la semana sigue hasta que arranca el mes', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-01')),
        PeriodicityEntry(periodicity: monthly(12), since: d('2026-10-01')),
      ]);

      final enSeptiembre = progress.forHabit(
        habit: habit,
        logs: const [],
        today: d('2026-09-30'),
      );
      final enOctubre = progress.forHabit(
        habit: habit,
        logs: const [],
        today: d('2026-10-01'),
      );

      expect(enSeptiembre.period.type, PeriodicityType.weekly);
      expect(enSeptiembre.goal, 3);
      expect(enOctubre.period.type, PeriodicityType.monthly);
      expect(enOctubre.goal, 12);
      expect(
        enOctubre.period.start,
        d('2026-10-01'),
        reason: 'periodo mensual completo, sin parcialidad',
      );
    });

    test('monthly → weekly: el mes sigue hasta que arranca la semana', () {
      final habit = habitWith([
        PeriodicityEntry(periodicity: monthly(12), since: d('2026-09-01')),
        PeriodicityEntry(periodicity: weekly(3), since: d('2026-09-14')),
      ]);

      expect(
        progress
            .forHabit(habit: habit, logs: const [], today: d('2026-09-13'))
            .period
            .type,
        PeriodicityType.monthly,
      );

      final semanal = progress.forHabit(
        habit: habit,
        logs: const [],
        today: d('2026-09-14'),
      );
      expect(semanal.period.type, PeriodicityType.weekly);
      expect(
        semanal.period.start,
        d('2026-09-14'),
        reason: 'semana completa lunes-domingo',
      );
      expect(semanal.period.end, d('2026-09-20'));
    });
  });

  group('ChangeHabitPeriodicityUsecase', () {
    test('programa el cambio y conserva el historial', () async {
      final repo = InMemoryHabitsRepository(seeded: false);
      addTearDown(repo.dispose);
      await repo.createAmbito(
        const AmbitoDraft(name: 'Salud', emoji: '💜', colorValue: 1),
      );
      final habit = await repo.createHabit(
        HabitDraft(
          name: 'Gimnasio',
          ambitoId: (await repo.watchAmbitos().first).first.id,
          periodicity: weekly(3),
          colorValue: 0xFF000000,
          emoji: '🏋️',
        ),
        today: d('2026-09-01'),
      );

      final result = await ChangeHabitPeriodicityUsecase(
        repo,
        resolver,
      ).execute(habit: habit, next: monthly(12), today: d('2026-09-10'));

      final scheduled = result as ChangePeriodicityScheduled;
      expect(scheduled.effectiveFrom, d('2026-10-01'));
      expect(scheduled.habit.periodicityTimeline, hasLength(2));
      expect(
        scheduled.habit.periodicityTimeline.first.periodicity,
        weekly(3),
        reason: 'la configuración anterior se conserva',
      );
      // Hasta el 1 de octubre sigue vigente el objetivo antiguo.
      expect(scheduled.habit.periodicityOn(d('2026-09-30')), weekly(3));
      expect(scheduled.habit.periodicityOn(d('2026-10-01')), monthly(12));
    });

    test(
      'un segundo cambio antes de la fecha efectiva sustituye al primero',
      () async {
        final repo = InMemoryHabitsRepository(seeded: false);
        addTearDown(repo.dispose);
        await repo.createAmbito(
          const AmbitoDraft(name: 'Salud', emoji: '💜', colorValue: 1),
        );
        final habit = await repo.createHabit(
          HabitDraft(
            name: 'Gimnasio',
            ambitoId: (await repo.watchAmbitos().first).first.id,
            periodicity: weekly(3),
            colorValue: 0xFF000000,
            emoji: '🏋️',
          ),
          today: d('2026-09-01'),
        );
        final usecase = ChangeHabitPeriodicityUsecase(repo, resolver);

        final first =
            await usecase.execute(
                  habit: habit,
                  next: weekly(5),
                  today: d('2026-09-10'),
                )
                as ChangePeriodicityScheduled;
        final second =
            await usecase.execute(
                  habit: first.habit,
                  next: weekly(7),
                  today: d('2026-09-11'),
                )
                as ChangePeriodicityScheduled;

        expect(
          second.habit.periodicityTimeline,
          hasLength(2),
          reason: 'no se apilan entradas para la misma fecha',
        );
        expect(second.habit.periodicityOn(d('2026-09-14')), weekly(7));
      },
    );

    test('rechaza una cantidad imposible para el tipo', () async {
      final repo = InMemoryHabitsRepository(seeded: false);
      addTearDown(repo.dispose);
      await repo.createAmbito(
        const AmbitoDraft(name: 'Salud', emoji: '💜', colorValue: 1),
      );
      final habit = await repo.createHabit(
        HabitDraft(
          name: 'Gimnasio',
          ambitoId: (await repo.watchAmbitos().first).first.id,
          periodicity: weekly(3),
          colorValue: 0xFF000000,
          emoji: '🏋️',
        ),
        today: d('2026-09-01'),
      );

      // 10 veces por semana es imposible: solo cabe un registro por día.
      final result = await ChangeHabitPeriodicityUsecase(
        repo,
        resolver,
      ).execute(habit: habit, next: weekly(10), today: d('2026-09-10'));

      expect(result, isA<ChangePeriodicityInvalid>());
    });

    test('previewEffectiveDate permite avisar antes de guardar', () {
      final usecase = ChangeHabitPeriodicityUsecase(
        InMemoryHabitsRepository(seeded: false),
        resolver,
      );

      expect(
        usecase.previewEffectiveDate(monthly(12), d('2026-09-10')),
        d('2026-10-01'),
      );
    });
  });
}
