import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/profile/weight/firestore_weight_repository.dart';
import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_repository.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';

final weightRepositoryProvider = Provider.autoDispose<WeightRepository>((ref) {
  final userId = ref.watch(authControllerProvider).value?.id ?? 'anonymous';
  return FirestoreWeightRepository(userId: userId);
});

final weightEntriesProvider = StreamProvider.autoDispose<List<WeightEntry>>((
  ref,
) {
  return ref.watch(weightRepositoryProvider).watchEntries();
});

final weightGoalProvider = StreamProvider.autoDispose<double?>((ref) {
  return ref.watch(weightRepositoryProvider).watchGoal();
});

final weightProfileProvider = StreamProvider.autoDispose<WeightProfile?>((ref) {
  return ref.watch(weightRepositoryProvider).watchProfile();
});
