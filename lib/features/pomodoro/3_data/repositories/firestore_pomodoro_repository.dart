import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/pomodoro/0_entity/entity.dart';
import 'package:habits/features/pomodoro/1_domain/domain.dart';
import 'package:habits/firestore_write.dart';

/// `users/{uid}/pomodoro/config` y `users/{uid}/pomodoro/sesiones/items/{id}`.
class FirestorePomodoroRepository implements PomodoroRepository {
  FirestorePomodoroRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _db;

  static const collection = 'pomodoro';
  static const configDoc = 'config';
  static const sessionsDoc = 'sesiones';
  static const itemsCollection = 'items';

  DocumentReference<Map<String, dynamic>> get _root =>
      _db.collection('users').doc(userId);
  DocumentReference<Map<String, dynamic>> get _config =>
      _root.collection(collection).doc(configDoc);
  CollectionReference<Map<String, dynamic>> get _sessions =>
      _root.collection(collection).doc(sessionsDoc).collection(itemsCollection);

  @override
  Stream<PomodoroConfig> watchConfig() =>
      _config.snapshots().map((snapshot) => configFromData(snapshot.data()));

  static PomodoroConfig configFromData(Map<String, dynamic>? data) {
    const defaults = PomodoroConfig();
    if (data == null) return defaults;
    int minutes(String key, int fallback) =>
        (data[key] as num?)?.toInt() ?? fallback;
    bool flag(String key, bool fallback) => data[key] as bool? ?? fallback;
    final config = PomodoroConfig(
      workMinutes: minutes('trabajoMin', defaults.workMinutes),
      shortBreakMinutes: minutes(
        'descansoCortoMin',
        defaults.shortBreakMinutes,
      ),
      longBreakMinutes: minutes('descansoLargoMin', defaults.longBreakMinutes),
      pomodorosPerCycle: minutes(
        'pomodorosPorCiclo',
        defaults.pomodorosPerCycle,
      ),
      autoStartBreaks: flag('autoDescanso', defaults.autoStartBreaks),
      autoStartWork: flag('autoTrabajo', defaults.autoStartWork),
      sound: flag('sonido', defaults.sound),
      vibration: flag('vibracion', defaults.vibration),
    );
    return config.isValid ? config : defaults;
  }

  @override
  Future<void> saveConfig(PomodoroConfig config) => awaitWrite(
    _config.set({
      'trabajoMin': config.workMinutes,
      'descansoCortoMin': config.shortBreakMinutes,
      'descansoLargoMin': config.longBreakMinutes,
      'pomodorosPorCiclo': config.pomodorosPerCycle,
      'autoDescanso': config.autoStartBreaks,
      'autoTrabajo': config.autoStartWork,
      'sonido': config.sound,
      'vibracion': config.vibration,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Stream<List<PomodoroSession>> watchSessionsBetween(
    LogicalDate from,
    LogicalDate to,
  ) => _sessions
      .where('dia', isGreaterThanOrEqualTo: from.key)
      .where('dia', isLessThanOrEqualTo: to.key)
      .snapshots()
      .map((snapshot) {
        final sessions = <PomodoroSession>[
          for (final document in snapshot.docs)
            ?sessionFromData(document.id, document.data()),
        ];
        sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
        return sessions;
      });

  static PomodoroSession? sessionFromData(
    String id,
    Map<String, dynamic> data,
  ) {
    final day = LogicalDate.tryParse(data['dia'] as String?);
    final started = (data['inicio'] as Timestamp?)?.toDate();
    final minutes = (data['duracionMin'] as num?)?.toInt();
    if (day == null || started == null || minutes == null) return null;
    final label = data['etiqueta'] as String?;
    return PomodoroSession(
      id: id,
      day: day,
      startedAt: started,
      durationMinutes: minutes,
      label: (label?.isEmpty ?? true) ? null : label,
    );
  }

  @override
  Future<void> addSession({
    required LogicalDate day,
    required DateTime startedAt,
    required int durationMinutes,
    String? label,
  }) => awaitWrite(
    _sessions.add({
      'dia': day.key,
      'inicio': Timestamp.fromDate(startedAt),
      'duracionMin': durationMinutes,
      'etiqueta': label ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> deleteAllSessions() async {
    final documents = await _sessions.get();
    for (var offset = 0; offset < documents.docs.length; offset += 400) {
      final batch = _db.batch();
      for (final document in documents.docs.skip(offset).take(400)) {
        batch.delete(document.reference);
      }
      await awaitWrite(batch.commit());
    }
  }
}
