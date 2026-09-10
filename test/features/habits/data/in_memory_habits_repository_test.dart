import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';
import 'package:habits/features/habits/3_data/repositories/in_memory_habits_repository.dart';

void main() {
  group('InMemoryHabitsRepository', () {
    test('viene sembrado con ámbitos, hábitos y registros de la semana',
        () async {
      final repository = InMemoryHabitsRepository();

      expect(await repository.fetchAmbitos(), isNotEmpty);
      expect(await repository.fetchHabits(), isNotEmpty);

      final monday = LogicalDay.mondayOfWeek(LogicalDay.today());
      final logs = await repository.fetchLogsBetween(
        monday,
        monday.add(const Duration(days: 6)),
      );
      // Si hoy es lunes no hay días previos completados en la semana.
      if (LogicalDay.today() != monday) {
        expect(logs, isNotEmpty);
      }
    });

    test('marcar hoy añade registro, sube racha del hábito y la general',
        () async {
      final repository = InMemoryHabitsRepository();
      final today = LogicalDay.today();

      final habitBefore = (await repository.fetchHabits()).first;
      final generalBefore = await repository.fetchGeneralStreak();

      await repository.setHabitCompletion(
        habitId: habitBefore.id,
        date: today,
        completed: true,
      );

      final habitAfter = (await repository.fetchHabits())
          .firstWhere((h) => h.id == habitBefore.id);
      final generalAfter = await repository.fetchGeneralStreak();
      final todayLogs = await repository.fetchLogsBetween(today, today);

      expect(habitAfter.currentStreak, habitBefore.currentStreak + 1);
      expect(generalAfter.count, generalBefore.count + 1);
      expect(todayLogs.any((l) => l.habitId == habitBefore.id), isTrue);
    });

    test('desmarcar hoy revierte registro y rachas', () async {
      final repository = InMemoryHabitsRepository();
      final today = LogicalDay.today();
      final habit = (await repository.fetchHabits()).first;
      final generalBefore = await repository.fetchGeneralStreak();

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

      final habitAfter = (await repository.fetchHabits())
          .firstWhere((h) => h.id == habit.id);
      final generalAfter = await repository.fetchGeneralStreak();
      final todayLogs = await repository.fetchLogsBetween(today, today);

      expect(habitAfter.currentStreak, habit.currentStreak);
      expect(generalAfter.count, generalBefore.count);
      expect(todayLogs.where((l) => l.habitId == habit.id), isEmpty);
    });

    test('marcar dos veces el mismo día no duplica el registro', () async {
      final repository = InMemoryHabitsRepository();
      final today = LogicalDay.today();
      final habit = (await repository.fetchHabits()).first;

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

      final todayLogs = await repository.fetchLogsBetween(today, today);
      expect(todayLogs.where((l) => l.habitId == habit.id).length, 1);
    });
  });
}
