import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/3_data/data.dart';

import '../../../helpers/habits_test_helpers.dart';

/// Escrituras del repositorio que tocan documentos ya existentes: borrar y
/// reasignar hábitos con el formato anterior a la fase 5, y reordenar.
void main() {
  const uid = 'uid-1';
  final today = day(2026, 9, 10);
  final nowInstant = DateTime.utc(2026, 9, 10, 12);
  late FakeFirebaseFirestore db;
  late FirestoreHabitsRepository repository;

  CollectionReference<Map<String, dynamic>> col(String name) =>
      db.collection('users').doc(uid).collection(name);

  /// Hábito tal y como lo guardaba la fase 4: periodicidad como texto,
  /// historial con el nombre antiguo y campos de descansos/recuperación.
  Future<void> seedLegacyHabit(String id, {String ambitoId = 'general'}) =>
      col('habitos').doc(id).set({
        'nombre': 'Antiguo $id',
        'emoji': '🕰️',
        'colorValue': 1,
        'ambitoId': ambitoId,
        'periodicidad': 'weekly',
        'historialPeriodicidad': [
          {'periodicidad': 'daily', 'desde': '2026-08-01'},
        ],
        'descansosPermitidos': 2,
        'tareaRecuperacion': 'x',
        'recuperacionCooldownDias': 7,
        'orden': 0,
        'deletedAt': null,
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 7, 1)),
        'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 7, 1)),
      });

  Future<void> seedAmbito(String id) => col('ambitos').doc(id).set({
    'nombre': id,
    'emoji': '✨',
    'colorValue': 1,
    'esPredefinido': id == Ambito.generalId,
    'orden': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  setUp(() async {
    db = FakeFirebaseFirestore();
    repository = FirestoreHabitsRepository(
      userId: uid,
      firestore: db,
      timezone: 'Europe/Madrid',
      now: () => nowInstant,
    );
    await seedAmbito(Ambito.generalId);
    await seedAmbito('salud');
  });

  void expectMigrated(Map<String, dynamic> data) {
    expect(data['periodicidad'], {'tipo': 'weekly', 'veces': 1});
    expect(data['cambiosPeriodicidad'], [
      {'tipo': 'daily', 'veces': 1, 'desde': '2026-08-01'},
    ]);
    expect(data.containsKey('historialPeriodicidad'), isFalse);
    expect(data.containsKey('descansosPermitidos'), isFalse);
    expect(data.containsKey('tareaRecuperacion'), isFalse);
    expect(data.containsKey('recuperacionCooldownDias'), isFalse);
  }

  test('borrar un hábito antiguo lo deja en el formato actual', () async {
    await seedLegacyHabit('viejo');

    await repository.softDeleteHabit('viejo');

    final data = (await col('habitos').doc('viejo').get()).data()!;
    expect(data['deletedAt'], isNotNull);
    expectMigrated(data);
  });

  test('borrar un ámbito migra sus hábitos antiguos al moverlos', () async {
    await seedLegacyHabit('viejo', ambitoId: 'salud');

    await repository.deleteAmbito('salud');

    final data = (await col('habitos').doc('viejo').get()).data()!;
    expect(data['ambitoId'], Ambito.generalId);
    expectMigrated(data);
    expect((await col('ambitos').doc('salud').get()).exists, isFalse);
  });

  test('un hábito ya migrado no se toca al borrarlo', () async {
    final habit = await repository.createHabit(
      const HabitDraft(
        name: 'Nuevo',
        ambitoId: 'general',
        periodicity: Periodicity.daily,
        colorValue: 1,
        emoji: '✅',
      ),
      today: today,
    );

    await repository.softDeleteHabit(habit.id);

    final data = (await col('habitos').doc(habit.id).get()).data()!;
    expect(data['periodicidad'], {'tipo': 'daily', 'veces': 1});
    expect(data['cambiosPeriodicidad'], isEmpty);
    expect(data['deletedAt'], isNotNull);
  });

  test('reordenar cambia solo el orden y en una sola operación', () async {
    final a = await repository.createHabit(
      const HabitDraft(
        name: 'A',
        ambitoId: 'general',
        periodicity: Periodicity.daily,
        colorValue: 1,
        emoji: 'a',
      ),
      today: today,
    );
    final b = await repository.createHabit(
      const HabitDraft(
        name: 'B',
        ambitoId: 'general',
        periodicity: Periodicity.daily,
        colorValue: 1,
        emoji: 'b',
      ),
      today: today,
    );

    await repository.reorderHabits({a.id: 20, b.id: 10});

    final active = await repository.watchActiveHabits().first;
    expect(active.map((h) => h.name), ['B', 'A']);
    expect((await col('habitos').doc(a.id).get()).data()?['nombre'], 'A');
  });
}
