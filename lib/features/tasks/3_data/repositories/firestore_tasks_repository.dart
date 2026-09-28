import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/1_domain/domain.dart';
import 'package:habits/firestore_write.dart';

/// `users/{uid}/tareas/{taskId}`. Nombres de campo en español como el resto
/// del esquema (ver firestore.rules).
class FirestoreTasksRepository implements TasksRepository {
  FirestoreTasksRepository({required this.userId, FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _db;

  static const collection = 'tareas';
  static const _titulo = 'titulo';
  static const _nota = 'nota';
  static const _fecha = 'fecha';
  static const _hora = 'hora';
  static const _prioridad = 'prioridad';
  static const _orden = 'orden';
  static const _completadaEn = 'completadaEn';
  static const _arrastradaDesde = 'arrastradaDesde';
  static const _createdAt = 'createdAt';
  static const _updatedAt = 'updatedAt';

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection('users').doc(userId).collection(collection);

  @override
  Stream<List<TaskItem>> watchPending() =>
      _tasks.where(_completadaEn, isNull: true).snapshots().map(_toList);

  @override
  Stream<List<TaskItem>> watchByDay(LogicalDate day) =>
      _tasks.where(_fecha, isEqualTo: day.key).snapshots().map(_toList);

  @override
  Stream<List<TaskItem>> watchUndated() =>
      _tasks.where(_fecha, isNull: true).snapshots().map(_toList);

  @override
  Future<String> create(TaskDraft draft) async {
    final reference = _tasks.doc();
    await awaitWrite(
      reference.set({
        ..._draftData(draft),
        _orden: DateTime.now().millisecondsSinceEpoch,
        _completadaEn: null,
        _arrastradaDesde: null,
        _createdAt: FieldValue.serverTimestamp(),
        _updatedAt: FieldValue.serverTimestamp(),
      }),
    );
    return reference.id;
  }

  @override
  Future<void> update(String id, TaskDraft draft) => awaitWrite(
    _tasks.doc(id).update({
      ..._draftData(draft),
      _updatedAt: FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> setCompleted(String id, bool completed) => awaitWrite(
    _tasks.doc(id).update({
      _completadaEn: completed ? FieldValue.serverTimestamp() : null,
      _updatedAt: FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> delete(String id) => awaitWrite(_tasks.doc(id).delete());

  @override
  Future<void> moveToDay(List<TaskItem> tasks, LogicalDate day) {
    if (tasks.isEmpty) return Future.value();
    final batch = _db.batch();
    for (final task in tasks) {
      batch.update(_tasks.doc(task.id), {
        _fecha: day.key,
        _arrastradaDesde: (task.rolledFrom ?? task.date)?.key,
        _updatedAt: FieldValue.serverTimestamp(),
      });
    }
    return awaitWrite(batch.commit());
  }

  static Map<String, dynamic> _draftData(TaskDraft draft) => {
    _titulo: draft.title.trim(),
    _nota: (draft.note?.trim().isEmpty ?? true) ? null : draft.note!.trim(),
    _fecha: draft.date?.key,
    _hora: draft.date == null ? null : draft.time,
    _prioridad: draft.priority.name,
  };

  static List<TaskItem> _toList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final tasks = <TaskItem>[
      for (final document in snapshot.docs)
        ?fromData(document.id, document.data()),
    ];
    tasks.sort(compareTasks);
    return tasks;
  }

  /// Null si el documento no tiene la forma esperada: se ignora en vez de
  /// romper toda la lista.
  static TaskItem? fromData(String id, Map<String, dynamic> data) {
    final title = data[_titulo];
    if (title is! String) return null;
    return TaskItem(
      id: id,
      title: title,
      note: data[_nota] as String?,
      date: LogicalDate.tryParse(data[_fecha] as String?),
      time: data[_hora] as String?,
      priority: switch (data[_prioridad]) {
        'low' => TaskPriority.low,
        'medium' || 'normal' => TaskPriority.medium,
        'high' => TaskPriority.high,
        'urgent' => TaskPriority.urgent,
        _ => TaskPriority.medium,
      },
      order: (data[_orden] as num?)?.toInt() ?? 0,
      completedAt: (data[_completadaEn] as Timestamp?)?.toDate(),
      rolledFrom: LogicalDate.tryParse(data[_arrastradaDesde] as String?),
      createdAt: (data[_createdAt] as Timestamp?)?.toDate(),
    );
  }
}
