import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/streak_calculator.dart';
import 'package:habits/features/habits/1_domain/usecases/rebuild_streak_usecase.dart';
import 'package:habits/features/habits/3_data/repositories/in_memory_habits_repository.dart';
import 'package:habits/features/habits/3_data/repositories/in_memory_wildcards_repository.dart';

LogicalDate d(String key) => LogicalDate.parse(key);

/// La caché es una PROYECCIÓN: se puede borrar entera y reconstruir desde los
/// registros y los días protegidos, sin perder nada (§31).
void main() {
  late InMemoryHabitsRepository habits;
  late InMemoryWildcardsRepository wildcards;
  late RebuildStreakUsecase usecase;
  late Habit habit;

  const today = LogicalDate(2026, 9, 11);

  setUp(() async {
    habits = InMemoryHabitsRepository(seeded: false);
    wildcards = InMemoryWildcardsRepository();
    usecase = RebuildStreakUsecase(habits, wildcards);
    final ambito = await habits.createAmbito(
      const AmbitoDraft(name: 'General', emoji: '✨', colorValue: 1),
    );
    habit = await habits.createHabit(
      HabitDraft(
        name: 'Leer',
        ambitoId: ambito.id,
        colorValue: 0xFF000000,
        emoji: '📖',
      ),
      today: today,
    );
  });

  tearDown(() async {
    await habits.dispose();
    await wildcards.dispose();
  });

  Future<void> logDays(List<String> keys) async {
    for (final key in keys) {
      await habits.setHabitCompletion(
        habitId: habit.id,
        date: d(key),
        completed: true,
      );
    }
  }

  test('sin registros la reconstrucción da racha 0', () async {
    final state = await usecase.execute(today);

    expect(state.currentStreak, 0);
    expect(state.status, StreakStatus.none);
  });

  test('reconstruye la racha desde los registros', () async {
    await logDays(['2026-09-09', '2026-09-10', '2026-09-11']);

    final state = await usecase.execute(today);

    expect(state.currentStreak, 3);
    expect(state.bestStreak, 3);
  });

  test('escribe la proyección en cache/rachas', () async {
    await logDays(['2026-09-10', '2026-09-11']);

    await usecase.execute(today);

    final cache = await habits.fetchStreakCache();
    expect(cache!.currentStreak, 2);
    expect(cache.bestStreak, 2);
    expect(cache.lastActivityDay, today);
    expect(cache.calculatedThrough, today);
    expect(cache.algorithmVersion, StreakCalculator.algorithmVersion);
  });

  test('borrar la caché entera y reconstruir da el mismo resultado', () async {
    await logDays(['2026-09-08', '2026-09-09', '2026-09-10', '2026-09-11']);
    final antes = await usecase.execute(today);
    final cacheAntes = await habits.fetchStreakCache();

    await habits.clearStreakCache();
    expect(await habits.fetchStreakCache(), isNull);

    final despues = await usecase.execute(today);

    expect(despues, antes);
    expect(await habits.fetchStreakCache(), cacheAntes);
  });

  test('la reconstrucción incluye los días protegidos', () async {
    await logDays(['2026-09-09', '2026-09-11']);
    await wildcards.ensureGranted(const LogicalDate(2026, 9, 1).yearMonth);
    await wildcards.consumeForDay(d('2026-09-10'));

    final state = await usecase.execute(today);

    expect(state.currentStreak, 2, reason: 'protege pero no suma');
    expect(state.status, StreakStatus.completedToday);
  });

  test('es idempotente: dos ejecuciones no cambian nada', () async {
    await logDays(['2026-09-10', '2026-09-11']);

    final first = await usecase.execute(today);
    final cacheAfterFirst = await habits.fetchStreakCache();
    final second = await usecase.execute(today);

    expect(second, first);
    expect(await habits.fetchStreakCache(), cacheAfterFirst);
  });

  test('los registros de un hábito eliminado siguen contando', () async {
    await logDays(['2026-09-09', '2026-09-10', '2026-09-11']);
    await habits.softDeleteHabit(habit.id);

    final state = await usecase.execute(today);

    expect(
      state.currentStreak,
      3,
      reason: 'borrar un hábito no reescribe la racha histórica',
    );
  });

  test('un fallo al escribir la caché no rompe el cálculo', () async {
    await logDays(['2026-09-11']);

    final state = await RebuildStreakUsecase(
      _FailingCacheRepository(habits),
      wildcards,
    ).execute(today);

    expect(state.currentStreak, 1);
  });
}

/// Repositorio que falla al escribir la caché, para comprobar que la racha se
/// sigue calculando: la caché es prescindible.
class _FailingCacheRepository implements HabitsRepository {
  _FailingCacheRepository(this._delegate);

  final HabitsRepository _delegate;

  @override
  Future<void> saveStreakCache(StreakCacheEntry entry) async =>
      throw StateError('sin conexión');

  @override
  Future<StreakCacheEntry?> fetchStreakCache() async =>
      throw StateError('sin conexión');

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Function.apply(
        (_delegate as dynamic).noSuchMethod,
        [invocation],
      );

  @override
  Future<Set<LogicalDate>> fetchActivityDays() => _delegate.fetchActivityDays();
}
