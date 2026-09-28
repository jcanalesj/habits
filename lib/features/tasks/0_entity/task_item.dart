import 'package:habits/features/habits/0_entity/logical_date.dart';

enum TaskPriority { low, normal, high }

/// Una tarea: título, nota, día lógico opcional, hora opcional y prioridad.
///
/// A diferencia de los hábitos admite fechas pasadas y futuras: no hay
/// racha que falsear. Nunca escribe en `registros`.
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.order,
    this.note,
    this.date,
    this.time,
    this.completedAt,
    this.rolledFrom,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? note;

  /// Día lógico. Null = "sin fecha".
  final LogicalDate? date;

  /// "HH:mm". Solo tiene sentido con [date].
  final String? time;
  final TaskPriority priority;

  /// Orden dentro del día (se asigna al crear).
  final int order;
  final DateTime? completedAt;

  /// Día original si la tarea se arrastró desde un día anterior.
  final LogicalDate? rolledFrom;
  final DateTime? createdAt;

  bool get isCompleted => completedAt != null;
  bool get hasTime => date != null && time != null;

  (int hour, int minute)? get timeParts {
    final value = time;
    if (value == null) return null;
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value);
    if (match == null) return null;
    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }

  TaskItem copyWith({
    String? title,
    String? note,
    LogicalDate? date,
    bool clearDate = false,
    String? time,
    bool clearTime = false,
    TaskPriority? priority,
    int? order,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    LogicalDate? rolledFrom,
  }) => TaskItem(
    id: id,
    title: title ?? this.title,
    note: note ?? this.note,
    date: clearDate ? null : (date ?? this.date),
    time: clearTime ? null : (time ?? this.time),
    priority: priority ?? this.priority,
    order: order ?? this.order,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    rolledFrom: rolledFrom ?? this.rolledFrom,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is TaskItem &&
      other.id == id &&
      other.title == title &&
      other.note == note &&
      other.date == date &&
      other.time == time &&
      other.priority == priority &&
      other.order == order &&
      other.completedAt == completedAt &&
      other.rolledFrom == rolledFrom;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    note,
    date,
    time,
    priority,
    order,
    completedAt,
    rolledFrom,
  );
}

/// Datos de creación o edición de una tarea.
class TaskDraft {
  const TaskDraft({
    required this.title,
    this.note,
    this.date,
    this.time,
    this.priority = TaskPriority.normal,
  });

  final String title;
  final String? note;
  final LogicalDate? date;
  final String? time;
  final TaskPriority priority;

  static const maxTitleLength = 120;
  static const maxNoteLength = 500;

  bool get isValid =>
      title.trim().isNotEmpty &&
      title.trim().length <= maxTitleLength &&
      (note == null || note!.length <= maxNoteLength) &&
      (time == null || date != null);
}

/// Orden de una lista de tareas: pendientes primero, luego por hora (las que
/// tienen hora antes), prioridad alta antes y finalmente por [TaskItem.order].
int compareTasks(TaskItem a, TaskItem b) {
  if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
  final at = a.time;
  final bt = b.time;
  if (at != null || bt != null) {
    if (at == null) return 1;
    if (bt == null) return -1;
    final byTime = at.compareTo(bt);
    if (byTime != 0) return byTime;
  }
  final byPriority = b.priority.index.compareTo(a.priority.index);
  if (byPriority != 0) return byPriority;
  return a.order.compareTo(b.order);
}
