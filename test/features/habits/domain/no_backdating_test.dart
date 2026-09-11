import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/usecases/toggle_habit_completion_usecase.dart';
import 'package:habits/features/habits/3_data/repositories/in_memory_habits_repository.dart';

LogicalDate d(String key) => LogicalDate.parse(key);

/// No se admiten registros retroactivos (§14).
///
/// Esta es la capa de DOMINIO, que es la única que puede aplicar el "solo hoy"
/// exacto, porque conoce la zona horaria IANA del perfil. Las Security Rules
/// solo acotan la fecha a una ventana de ±1 día aproximadamente y NO pueden
/// garantizar esto: ver la limitación conocida documentada en firestore.rules
/// y en documentation/PHASE5_STREAK_ENGINE.md.
void main() {
  late InMemoryHabitsRepository repo;
  late ToggleHabitCompletionUsecase usecase;
  late Habit habit;

  const today = LogicalDate(2026, 9, 11);

  setUp(() async {
    repo = InMemoryHabitsRepository(seeded: false);
    usecase = ToggleHabitCompletionUsecase(repo);
    final ambito = await repo.createAmbito(
      const AmbitoDraft(name: 'General', emoji: '✨', colorValue: 1),
    );
    habit = await repo.createHabit(
      HabitDraft(
        name: 'Leer',
        ambitoId: ambito.id,
        colorValue: 0xFF000000,
        emoji: '📖',
      ),
      today: today,
    );
  });

  tearDown(() => repo.dispose());

  Future<ToggleHabitCompletionResult> mark(LogicalDate date) => usecase.execute(
    habitId: habit.id,
    date: date,
    completed: true,
    today: today,
  );

  test('hoy: permitido', () async {
    expect(await mark(today), isA<ToggleHabitCompletionSuccess>());
    expect(await repo.fetchActivityDays(), {today});
  });

  test('ayer: rechazado', () async {
    final result = await mark(d('2026-09-10'));

    expect(result, isA<ToggleHabitCompletionNotToday>());
    expect(await repo.fetchActivityDays(), isEmpty);
  });

  test('anteayer: rechazado', () async {
    expect(await mark(d('2026-09-09')), isA<ToggleHabitCompletionNotToday>());
    expect(await repo.fetchActivityDays(), isEmpty);
  });

  test('mañana: rechazado', () async {
    expect(await mark(d('2026-09-12')), isA<ToggleHabitCompletionNotToday>());
    expect(await repo.fetchActivityDays(), isEmpty);
  });

  test('fecha arbitraria antigua: rechazada', () async {
    expect(await mark(d('2020-01-01')), isA<ToggleHabitCompletionNotToday>());
    expect(await repo.fetchActivityDays(), isEmpty);
  });

  test('desmarcar también está limitado a hoy', () async {
    await mark(today);

    final result = await usecase.execute(
      habitId: habit.id,
      date: d('2026-09-10'),
      completed: false,
      today: today,
    );

    expect(result, isA<ToggleHabitCompletionNotToday>());
  });

  test('marcar dos veces el mismo día es idempotente', () async {
    await mark(today);
    await mark(today);

    expect(await repo.fetchActivityDays(), {today});
  });

  test('no se puede registrar en un hábito eliminado', () async {
    await repo.softDeleteHabit(habit.id);

    final result = await mark(today);

    expect(
      (result as ToggleHabitCompletionFailed).failure.name,
      'habitDeleted',
    );
  });
}
