import 'package:flutter/material.dart' show ThemeMode;
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/repositories/user_profile_repository.dart';

/// [UserProfileRepository] en memoria para tests y arranques simulados.
class InMemoryUserProfileRepository implements UserProfileRepository {
  final Map<String, NewUserProfile> profiles = {};
  final Map<String, String> avatarIds = {};
  final Map<String, bool> timezoneAutomatic = {};
  final Map<String, bool> welcomeAnimationEnabled = {};
  final Map<String, List<String>> customMotivationMessages = {};
  final Map<String, ThemeMode> themeModes = {};
  final Map<String, bool> premium = {};

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
  Stream<bool?> watchWelcomeAnimationEnabled(String userId) =>
      Stream.value(welcomeAnimationEnabled[userId]);

  @override
  Stream<List<String>> watchCustomMotivationMessages(String userId) =>
      Stream.value(customMotivationMessages[userId] ?? const []);

  @override
  Stream<ThemeMode?> watchThemeMode(String userId) =>
      Stream.value(themeModes[userId]);

  @override
  Stream<bool> watchIsPremium(String userId) =>
      Stream.value(premium[userId] ?? false);

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

  @override
  Future<void> updateWelcomeAnimationEnabled(
    String userId,
    bool enabled,
  ) async {
    welcomeAnimationEnabled[userId] = enabled;
  }

  @override
  Future<void> updateThemeMode(String userId, ThemeMode mode) async {
    themeModes[userId] = mode;
  }

  @override
  Future<void> updateCustomMotivationMessages(
    String userId,
    List<String> messages,
  ) async {
    customMotivationMessages[userId] = List.unmodifiable(messages);
  }
}
