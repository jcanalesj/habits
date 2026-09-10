import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/repositories/user_profile_repository.dart';

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
      'timezone': profile.timezone,
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
}
