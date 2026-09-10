import 'package:habits/features/auth/0_entity/entity.dart';

/// Perfil del usuario en el backend (`users/{uid}` y sus ámbitos
/// predefinidos). Solo puede usarse con el email verificado: las Security
/// Rules rechazan cualquier acceso anterior.
abstract class UserProfileRepository {
  Future<bool> exists(String userId);

  /// Crea el documento de perfil y siembra los ámbitos en una sola
  /// operación atómica.
  Future<void> create(NewUserProfile profile);
}
