import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';

abstract class TasksRepository {
  /// Todas las tareas sin completar, con o sin fecha.
  Stream<List<TaskItem>> watchPending();

  /// Todas las tareas de un día (pendientes y completadas).
  Stream<List<TaskItem>> watchByDay(LogicalDate day);

  /// Todas las tareas sin fecha (pendientes y completadas).
  Stream<List<TaskItem>> watchUndated();

  Future<String> create(TaskDraft draft);
  Future<void> update(String id, TaskDraft draft);
  Future<void> setCompleted(String id, bool completed);
  Future<void> delete(String id);

  /// Arrastra [tasks] al día [day] conservando hora y prioridad y anotando
  /// el día del que vienen. Una sola escritura para todas.
  Future<void> moveToDay(List<TaskItem> tasks, LogicalDate day);
}
