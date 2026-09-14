import 'package:cloud_firestore/cloud_firestore.dart';
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
      _collection.add({
        'tipo': 'medicion',
        'pesoKg': kilograms,
        'recordedAt': Timestamp.fromDate(recordedAt),
        'createdAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> updateGoal(double? kilograms) => _collection.doc('config').set({
    'tipo': 'config',
    'objetivoKg': kilograms,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  @override
  Future<void> saveProfile(WeightProfile profile) =>
      _collection.doc('config').set({
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
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
