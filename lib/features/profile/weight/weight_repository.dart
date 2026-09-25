import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';

abstract class WeightRepository {
  Stream<List<WeightEntry>> watchEntries();
  Stream<double?> watchGoal();
  Stream<WeightProfile?> watchProfile();
  Future<void> addEntry(double kilograms, DateTime recordedAt);
  Future<void> deleteEntry(String entryId);
  Future<void> resetAllData();
  Future<void> updateGoal(double kilograms);
  Future<void> saveProfile(WeightProfile profile);

  /// Alta del plan: perfil y primera medición en una sola escritura, para
  /// no dejar un perfil sin medición si la segunda falla.
  Future<void> completeOnboarding(WeightProfile profile, DateTime recordedAt);
}
