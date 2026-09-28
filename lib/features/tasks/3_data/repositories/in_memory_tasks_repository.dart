import 'dart:async';

import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/1_domain/domain.dart';

/// [TasksRepository] en memoria para tests y previsualizaciones.
class InMemoryTasksRepository implements TasksRepository {
  InMemoryTasksRepository({
    Iterable<TaskItem> seeded = const [],
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    for (final task in seeded) {
      _tasks[task.id] = task;
    }
  }

  final DateTime Function() _now;
  final _tasks = <String, TaskItem>{};
  final _controller = StreamController<void>.broadcast();
  int _sequence = 0;

  List<TaskItem> get all => _tasks.values.toList(growable: false);

  Stream<List<TaskItem>> _watch(bool Function(TaskItem task) test) async* {
    List<TaskItem> select() =>
        (_tasks.values.where(test).toList()..sort(compareTasks));
    yield select();
    yield* _controller.stream.map((_) => select());
  }

  @override
  Stream<List<TaskItem>> watchPending() => _watch((task) => !task.isCompleted);

  @override
  Stream<List<TaskItem>> watchByDay(LogicalDate day) =>
      _watch((task) => task.date == day);

  @override
  Stream<List<TaskItem>> watchUndated() => _watch((task) => task.date == null);

  @override
  Future<String> create(TaskDraft draft) async {
    final id = 'task-${++_sequence}';
    _tasks[id] = TaskItem(
      id: id,
      title: draft.title.trim(),
      note: draft.note,
      date: draft.date,
      time: draft.date == null ? null : draft.time,
      priority: draft.priority,
      order: _sequence,
      createdAt: _now(),
    );
    _controller.add(null);
    return id;
  }

  @override
  Future<void> update(String id, TaskDraft draft) async {
    final current = _tasks[id];
    if (current == null) return;
    _tasks[id] = TaskItem(
      id: id,
      title: draft.title.trim(),
      note: draft.note,
      date: draft.date,
      time: draft.date == null ? null : draft.time,
      priority: draft.priority,
      order: current.order,
      completedAt: current.completedAt,
      rolledFrom: current.rolledFrom,
      createdAt: current.createdAt,
    );
    _controller.add(null);
  }

  @override
  Future<void> setCompleted(String id, bool completed) async {
    final current = _tasks[id];
    if (current == null) return;
    _tasks[id] = completed
        ? current.copyWith(completedAt: _now())
        : current.copyWith(clearCompletedAt: true);
    _controller.add(null);
  }

  @override
  Future<void> delete(String id) async {
    _tasks.remove(id);
    _controller.add(null);
  }

  @override
  Future<void> moveToDay(List<TaskItem> tasks, LogicalDate day) async {
    for (final task in tasks) {
      final current = _tasks[task.id];
      if (current == null) continue;
      _tasks[task.id] = current.copyWith(
        date: day,
        rolledFrom: current.rolledFrom ?? current.date,
      );
    }
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
