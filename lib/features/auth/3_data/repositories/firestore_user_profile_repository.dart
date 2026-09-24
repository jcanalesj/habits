import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/repositories/user_profile_repository.dart';
import 'package:habits/features/profile/appearance/theme_mode_preferences.dart';

/// Perfil de usuario en Firestore. Escribe exactamente los campos que
/// aceptan las Security Rules (`users/{uid}` y `users/{uid}/ambitos/{id}`);
/// las marcas de tiempo son siempre del servidor.
class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const usersCollection = 'users';
  static const ambitosCollection = 'ambitos';

  DocumentReference<Map<String, dynamic>> _userRef(String userId) =>
      _db.collection(usersCollection).doc(userId);

  @override
  Future<bool> exists(String userId) async {
    final snapshot = await _userRef(userId).get();
    return snapshot.exists;
  }

  @override
  Future<void> create(NewUserProfile profile) async {
    final userRef = _userRef(profile.userId);
    final batch = _db.batch();

    batch.set(userRef, {
      'email': profile.email,
      'displayName': profile.displayName,
      'avatarId': 'traveler',
      'timezone': profile.timezone,
      'timezoneAutomatic': true,
      'welcomeAnimationEnabled': true,
      'customMotivationMessages': <String>[],
      'themeMode': ThemeModeCodec.light,
      'locale': profile.locale,
      // Único valor que las reglas permiten fijar desde cliente.
      'subscription': {'status': 'free'},
      'onboardingCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });

    for (final ambito in profile.ambitos) {
      batch.set(userRef.collection(ambitosCollection).doc(ambito.id), {
        'nombre': ambito.name,
        'emoji': ambito.emoji,
        'colorValue': ambito.colorValue,
        'esPredefinido': true,
        'orden': ambito.order,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  @override
  Stream<String?> watchTimezone(String userId) => _userRef(
    userId,
  ).snapshots().map((snapshot) => snapshot.data()?['timezone'] as String?);

  @override
  Stream<String?> watchAvatarId(String userId) => _userRef(
    userId,
  ).snapshots().map((snapshot) => snapshot.data()?['avatarId'] as String?);

  @override
  Stream<bool> watchTimezoneAutomatic(String userId) =>
      _userRef(userId).snapshots().map(
        (snapshot) => snapshot.data()?['timezoneAutomatic'] as bool? ?? true,
      );

  @override
  Stream<bool?> watchWelcomeAnimationEnabled(String userId) => _userRef(userId)
      .snapshots()
      .map((snapshot) => snapshot.data()?['welcomeAnimationEnabled'] as bool?);

  @override
  Stream<List<String>> watchCustomMotivationMessages(String userId) =>
      _userRef(userId).snapshots().map(
        (snapshot) =>
            (snapshot.data()?['customMotivationMessages'] as List<dynamic>?)
                ?.whereType<String>()
                .toList(growable: false) ??
            const [],
      );

  @override
  Stream<ThemeMode?> watchThemeMode(String userId) =>
      _userRef(userId).snapshots().map(
        (snapshot) =>
            ThemeModeCodec.decode(snapshot.data()?['themeMode'] as String?),
      );

  @override
  Stream<bool> watchIsPremium(String userId) =>
      _userRef(userId).snapshots().map((snapshot) {
        final subscription = snapshot.data()?['subscription'];
        if (subscription is! Map) return false;
        final status = subscription['status'];
        return status == 'premium' || status == 'active';
      });

  @override
  Future<void> updateDisplayName(String userId, String displayName) =>
      _userRef(userId).update({
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> updateTimezone(String userId, String timezone) => _userRef(
    userId,
  ).update({'timezone': timezone, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<void> updateTimezoneSettings(
    String userId, {
    required String timezone,
    required bool automatic,
  }) => _userRef(userId).update({
    'timezone': timezone,
    'timezoneAutomatic': automatic,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> updateAvatarId(String userId, String avatarId) => _userRef(
    userId,
  ).update({'avatarId': avatarId, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Future<void> updateWelcomeAnimationEnabled(String userId, bool enabled) =>
      _userRef(userId).update({
        'welcomeAnimationEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> updateThemeMode(String userId, ThemeMode mode) =>
      _userRef(userId).update({
        'themeMode': ThemeModeCodec.encode(mode),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> updateCustomMotivationMessages(
    String userId,
    List<String> messages,
  ) => _userRef(userId).update({
    'customMotivationMessages': messages,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
