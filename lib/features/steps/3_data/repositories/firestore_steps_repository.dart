import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';
import 'package:habits/firestore_write.dart';

/// `users/{uid}/pasos/config` y `users/{uid}/pasos/{YYYY-MM-DD}`.
class FirestoreStepsRepository implements StepsRepository {
  FirestoreStepsRepository({required this.userId, FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _db;

  static const collection = 'pasos';
  static const configDoc = 'config';

  CollectionReference<Map<String, dynamic>> get _days =>
      _db.collection('users').doc(userId).collection(collection);

  @override
  Stream<StepsConfig> watchConfig() => _days.doc(configDoc).snapshots().map((
    snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) return const StepsConfig();
    final config = StepsConfig(
      goal: (data['objetivo'] as num?)?.toInt() ?? StepsConfig.defaultGoal,
      consented: data['consentimientoSalud'] as bool? ?? false,
    );
    return config.isValid ? config : StepsConfig(consented: config.consented);
  });

  @override
  Future<void> saveConfig(StepsConfig config) => awaitWrite(
    _days.doc(configDoc).set({
      'objetivo': config.goal,
      'consentimientoSalud': config.consented,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Stream<List<StepsDay>> watchDaysBetween(LogicalDate from, LogicalDate to) =>
      _days
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: from.key)
          .where(FieldPath.documentId, isLessThanOrEqualTo: to.key)
          .snapshots()
          .map(
            (snapshot) => [
              for (final document in snapshot.docs)
                if (document.id != configDoc)
                  ?dayFromData(document.id, document.data()),
            ],
          );

  static StepsDay? dayFromData(String id, Map<String, dynamic> data) {
    final day = LogicalDate.tryParse(id);
    final steps = (data['pasos'] as num?)?.toInt();
    if (day == null || steps == null) return null;
    return StepsDay(
      day: day,
      steps: steps,
      distanceMeters: (data['distanciaM'] as num?)?.toInt(),
    );
  }

  @override
  Future<void> upsertDay(StepsDay day) => awaitWrite(
    _days.doc(day.day.key).set({
      'pasos': day.steps,
      'distanciaM': day.distanceMeters,
      'fuente': 'pedometer',
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );
}
