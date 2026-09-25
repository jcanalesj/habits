import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/firestore_write.dart';
import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_repository.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';

class FirestoreWeightRepository implements WeightRepository {
  FirestoreWeightRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('users').doc(userId).collection('peso');

  @override
  Stream<List<WeightEntry>> watchEntries() =>
      _collection.snapshots().map((snapshot) {
        final entries = <WeightEntry>[
          for (final document in snapshot.docs)
            if (document.data()['tipo'] == 'medicion')
              if (document.data()['pesoKg'] case final num kilograms)
                WeightEntry(
                  id: document.id,
                  kilograms: kilograms.toDouble(),
                  recordedAt:
                      (document.data()['recordedAt'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                ),
        ];
        entries.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        return entries;
      });

  @override
  Stream<double?> watchGoal() => _collection
      .doc('config')
      .snapshots()
      .map((snapshot) => (snapshot.data()?['objetivoKg'] as num?)?.toDouble());

  @override
  Stream<WeightProfile?> watchProfile() =>
      _collection.doc('config').snapshots().map((snapshot) {
        final data = snapshot.data();
        if (data?['onboardingCompleted'] != true) return null;
        try {
          return WeightProfile(
            currentKg: (data!['pesoActualKg'] as num).toDouble(),
            goalKg: (data['objetivoKg'] as num).toDouble(),
            age: data['edad'] as int,
            heightCm: (data['alturaCm'] as num).toDouble(),
            sex: CalorieSex.values.byName(data['sexoCalculo'] as String),
            activityLevel: ActivityLevel.values.byName(
              data['nivelActividad'] as String,
            ),
            goalType: WeightGoalType.values.byName(
              data['tipoObjetivo'] as String,
            ),
            recommendedCalories: data['caloriasEstimadas'] as int,
          );
        } catch (_) {
          return null;
        }
      });

  @override
  Future<void> addEntry(double kilograms, DateTime recordedAt) =>
      awaitWrite(_collection.add(_entryData(kilograms, recordedAt)));

  @override
  Future<void> deleteEntry(String entryId) {
    // 'config' no es una medición: nunca se borra desde aquí.
    if (entryId == _configId) return Future.value();
    return awaitWrite(_collection.doc(entryId).delete());
  }

  @override
  Future<void> updateGoal(double kilograms) => awaitWrite(
    _collection.doc(_configId).set({
      'tipo': 'config',
      'objetivoKg': kilograms,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)),
  );

  @override
  Future<void> saveProfile(WeightProfile profile) =>
      awaitWrite(_collection.doc(_configId).set(_profileData(profile)));

  @override
  Future<void> completeOnboarding(WeightProfile profile, DateTime recordedAt) {
    final batch = _db.batch()
      ..set(_collection.doc(_configId), _profileData(profile))
      ..set(_collection.doc(), _entryData(profile.currentKg, recordedAt));
    return awaitWrite(batch.commit());
  }

  static const _configId = 'config';

  static Map<String, dynamic> _entryData(
    double kilograms,
    DateTime recordedAt,
  ) => {
    'tipo': 'medicion',
    'pesoKg': kilograms,
    'recordedAt': Timestamp.fromDate(recordedAt),
    'createdAt': FieldValue.serverTimestamp(),
  };

  static Map<String, dynamic> _profileData(WeightProfile profile) => {
    'tipo': 'config',
    'pesoActualKg': profile.currentKg,
    'objetivoKg': profile.goalKg,
    'edad': profile.age,
    'alturaCm': profile.heightCm,
    'sexoCalculo': profile.sex.name,
    'nivelActividad': profile.activityLevel.name,
    'tipoObjetivo': profile.goalType.name,
    'caloriasEstimadas': profile.recommendedCalories,
    'onboardingCompleted': true,
    // Solo se llega aquí tras aceptar el consentimiento de datos de salud.
    'consentimientoSalud': true,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
