import 'dart:async';

import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_repository.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';

class InMemoryWeightRepository implements WeightRepository {
  final List<WeightEntry> entries = [];
  double? goal;
  WeightProfile? profile;
  final _entriesController = StreamController<List<WeightEntry>>.broadcast();
  final _goalController = StreamController<double?>.broadcast();
  final _profileController = StreamController<WeightProfile?>.broadcast();

  @override
  Stream<List<WeightEntry>> watchEntries() async* {
    yield List.unmodifiable(entries);
    yield* _entriesController.stream;
  }

  @override
  Stream<double?> watchGoal() async* {
    yield goal;
    yield* _goalController.stream;
  }

  @override
  Stream<WeightProfile?> watchProfile() async* {
    yield profile;
    yield* _profileController.stream;
  }

  @override
  Future<void> addEntry(double kilograms, DateTime recordedAt) async {
    entries.insert(
      0,
      WeightEntry(
        id: 'weight-${entries.length + 1}',
        kilograms: kilograms,
        recordedAt: recordedAt,
      ),
    );
    entries.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    _entriesController.add(List.unmodifiable(entries));
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    entries.removeWhere((entry) => entry.id == entryId);
    _entriesController.add(List.unmodifiable(entries));
  }

  @override
  Future<void> completeOnboarding(
    WeightProfile value,
    DateTime recordedAt,
  ) async {
    await saveProfile(value);
    await addEntry(value.currentKg, recordedAt);
  }

  @override
  Future<void> updateGoal(double kilograms) async {
    goal = kilograms;
    _goalController.add(goal);
  }

  @override
  Future<void> saveProfile(WeightProfile value) async {
    profile = value;
    goal = value.goalKg;
    _profileController.add(value);
    _goalController.add(goal);
  }

  Future<void> dispose() async {
    await _entriesController.close();
    await _goalController.close();
    await _profileController.close();
  }
}
