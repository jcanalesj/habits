import 'package:firebase_auth/firebase_auth.dart';
import 'package:habits/features/auth/0_entity/entity.dart';

/// Convierte el usuario del SDK de Firebase a la entidad de dominio.
AppUser? appUserFromFirebase(User? user) {
  if (user == null) return null;
  return AppUser(
    id: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
    emailVerified: user.emailVerified,
  );
}
