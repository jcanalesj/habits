import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/repositories/user_profile_repository.dart';

/// [UserProfileRepository] en memoria para tests y arranques simulados.
class InMemoryUserProfileRepository implements UserProfileRepository {
  final Map<String, NewUserProfile> profiles = {};
  final Map<String, String> avatarIds = {};
  final Map<String, bool> timezoneAutomatic = {};

  @override
  Future<bool> exists(String userId) async => profiles.containsKey(userId);

  @override
  Future<void> create(NewUserProfile profile) async {
    profiles[profile.userId] = profile;
  }

  @override
  Stream<String?> watchTimezone(String userId) =>
      Stream.value(profiles[userId]?.timezone);

  @override
  Stream<String?> watchAvatarId(String userId) =>
      Stream.value(avatarIds[userId]);

  @override
  Stream<bool> watchTimezoneAutomatic(String userId) =>
      Stream.value(timezoneAutomatic[userId] ?? true);

  @override
  Future<void> updateDisplayName(String userId, String displayName) async {
    final profile = profiles[userId];
    if (profile != null) {
      profiles[userId] = profile.copyWith(displayName: displayName);
    }
  }

  @override
  Future<void> updateTimezone(String userId, String timezone) async {
    final profile = profiles[userId];
    if (profile != null) {
      profiles[userId] = profile.copyWith(timezone: timezone);
    }
  }

  @override
  Future<void> updateTimezoneSettings(
    String userId, {
    required String timezone,
    required bool automatic,
  }) async {
    await updateTimezone(userId, timezone);
    timezoneAutomatic[userId] = automatic;
  }

  @override
  Future<void> updateAvatarId(String userId, String avatarId) async {
    avatarIds[userId] = avatarId;
  }
}
