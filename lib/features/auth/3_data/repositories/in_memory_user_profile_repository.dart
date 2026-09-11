import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/repositories/user_profile_repository.dart';

/// [UserProfileRepository] en memoria para tests y arranques simulados.
class InMemoryUserProfileRepository implements UserProfileRepository {
  final Map<String, NewUserProfile> profiles = {};

  @override
  Future<bool> exists(String userId) async => profiles.containsKey(userId);

  @override
  Future<void> create(NewUserProfile profile) async {
    profiles[profile.userId] = profile;
  }

  @override
  Stream<String?> watchTimezone(String userId) =>
      Stream.value(profiles[userId]?.timezone);
}
