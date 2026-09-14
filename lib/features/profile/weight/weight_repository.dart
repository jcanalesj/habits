import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';

abstract class WeightRepository {
  Stream<List<WeightEntry>> watchEntries();
  Stream<double?> watchGoal();
  Stream<WeightProfile?> watchProfile();
  Future<void> addEntry(double kilograms, DateTime recordedAt);
  Future<void> updateGoal(double? kilograms);
  Future<void> saveProfile(WeightProfile profile);
}
