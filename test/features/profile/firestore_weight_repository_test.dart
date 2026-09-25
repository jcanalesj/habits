import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/profile/weight/firestore_weight_repository.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';

void main() {
  const uid = 'uid-1';
  late FakeFirebaseFirestore db;
  late FirestoreWeightRepository repository;

  CollectionReference<Map<String, dynamic>> peso() =>
      db.collection('users').doc(uid).collection('peso');

  const profile = WeightProfile(
    currentKg: 72.5,
    goalKg: 68,
    age: 34,
    heightCm: 172,
    sex: CalorieSex.female,
    activityLevel: ActivityLevel.moderate,
    goalType: WeightGoalType.lose,
    recommendedCalories: 1900,
  );

  setUp(() {
    db = FakeFirebaseFirestore();
    repository = FirestoreWeightRepository(userId: uid, firestore: db);
  });

  test('el alta guarda el perfil y la primera medición a la vez', () async {
    await repository.completeOnboarding(profile, DateTime(2026, 9, 24, 8));

    final config = await peso().doc('config').get();
    expect(config.data()?['onboardingCompleted'], isTrue);
    expect(config.data()?['consentimientoSalud'], isTrue);
    expect(config.data()?['objetivoKg'], 68);

    final entries = await repository.watchEntries().first;
    expect(entries, hasLength(1));
    expect(entries.single.kilograms, 72.5);
  });

  test(
    'las mediciones se ordenan de la más reciente a la más antigua',
    () async {
      await repository.addEntry(70, DateTime(2026, 9, 1));
      await repository.addEntry(69, DateTime(2026, 9, 10));

      final entries = await repository.watchEntries().first;
      expect(entries.map((e) => e.kilograms), [69, 70]);
    },
  );

  test('borrar una medición la quita del historial', () async {
    await repository.addEntry(70, DateTime(2026, 9, 1));
    await repository.addEntry(69, DateTime(2026, 9, 10));
    final wrong = (await repository.watchEntries().first).first;

    await repository.deleteEntry(wrong.id);

    final entries = await repository.watchEntries().first;
    expect(entries.map((e) => e.kilograms), [70]);
  });

  test('"config" nunca se borra como si fuera una medición', () async {
    await repository.saveProfile(profile);

    await repository.deleteEntry('config');

    expect((await peso().doc('config').get()).exists, isTrue);
  });

  test('cambiar el objetivo conserva el resto del perfil', () async {
    await repository.saveProfile(profile);

    await repository.updateGoal(65);

    final config = (await peso().doc('config').get()).data()!;
    expect(config['objetivoKg'], 65);
    expect(config['edad'], 34);
    expect(await repository.watchGoal().first, 65);
  });
}
