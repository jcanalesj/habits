import 'package:habits/features/auth/0_entity/entity.dart';

/// Perfil del usuario en el backend (`users/{uid}` y sus ámbitos
/// predefinidos). Solo puede usarse con el email verificado: las Security
/// Rules rechazan cualquier acceso anterior.
abstract class UserProfileRepository {
  Future<bool> exists(String userId);

  /// Crea el documento de perfil y siembra los ámbitos en una sola
  /// operación atómica.
  Future<void> create(NewUserProfile profile);

  /// Zona horaria IANA guardada en el perfil (p. ej. `Europe/Madrid`).
  ///
  /// Es la que define el "día lógico" de todo el motor de rachas y de
  /// objetivos (§12). Emite los cambios: si el usuario viaja y actualiza su
  /// perfil, el concepto de "hoy" se recalcula, pero los registros
  /// históricos NO se reinterpretan (§13).
  ///
  /// Emite null mientras el perfil no existe o no tiene zona.
  Stream<String?> watchTimezone(String userId);

  Stream<String?> watchAvatarId(String userId);

  Stream<bool> watchTimezoneAutomatic(String userId);

  Future<void> updateDisplayName(String userId, String displayName);

  Future<void> updateTimezone(String userId, String timezone);

  Future<void> updateTimezoneSettings(
    String userId, {
    required String timezone,
    required bool automatic,
  });

  Future<void> updateAvatarId(String userId, String avatarId);
}
