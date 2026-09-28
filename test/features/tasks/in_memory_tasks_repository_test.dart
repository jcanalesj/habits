import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/3_data/data.dart';

void main() {
  const today = LogicalDate(2026, 9, 11);

  test('crea, completa y reabre una tarea', () async {
    final repository = InMemoryTasksRepository();
    addTearDown(repository.dispose);
    final id = await repository.create(
      const TaskDraft(title: '  Comprar pan ', date: today, time: '10:00'),
    );
    var pending = await repository.watchPending().first;
    expect(pending.single.title, 'Comprar pan');
    expect(pending.single.hasTime, isTrue);

    await repository.setCompleted(id, true);
    pending = await repository.watchPending().first;
    expect(pending, isEmpty);
    final byDay = await repository.watchByDay(today).first;
    expect(byDay.single.isCompleted, isTrue);

    await repository.setCompleted(id, false);
    pending = await repository.watchPending().first;
    expect(pending.single.id, id);
  });

  test('sin fecha no conserva la hora', () async {
    final repository = InMemoryTasksRepository();
    addTearDown(repository.dispose);
    await repository.create(const TaskDraft(title: 'Leer', time: '09:00'));
    final undated = await repository.watchUndated().first;
    expect(undated.single.time, isNull);
    expect(undated.single.date, isNull);
  });

  test('arrastrar a hoy conserva hora y anota el día original', () async {
    final repository = InMemoryTasksRepository();
    addTearDown(repository.dispose);
    final id = await repository.create(
      TaskDraft(title: 'Pagar luz', date: today.addDays(-3), time: '18:00'),
    );
    final task = (await repository.watchPending().first).single;
    await repository.moveToDay([task], today);
    final moved = (await repository.watchByDay(today).first).single;
    expect(moved.id, id);
    expect(moved.time, '18:00');
    expect(moved.rolledFrom, today.addDays(-3));

    // Un segundo arrastre mantiene el día ORIGINAL.
    await repository.moveToDay([moved], today.next);
    final again = (await repository.watchByDay(today.next).first).single;
    expect(again.rolledFrom, today.addDays(-3));
  });

  test('orden: hora antes que sin hora, alta antes que normal', () {
    const base = TaskItem(
      id: 'a',
      title: 'a',
      priority: TaskPriority.normal,
      order: 1,
      date: today,
    );
    final withTime = TaskItem(
      id: 'b',
      title: 'b',
      priority: TaskPriority.low,
      order: 2,
      date: today,
      time: '08:00',
    );
    const high = TaskItem(
      id: 'c',
      title: 'c',
      priority: TaskPriority.high,
      order: 3,
      date: today,
    );
    final sorted = [base, high, withTime]..sort(compareTasks);
    expect(sorted.map((task) => task.id), ['b', 'c', 'a']);
  });
}
