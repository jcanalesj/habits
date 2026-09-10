import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/auth/0_entity/predefined_ambito.dart';

part 'new_user_profile.freezed.dart';

/// Datos necesarios para crear el perfil de un usuario recién verificado:
/// el documento `users/{uid}` y sus ámbitos predefinidos.
@freezed
abstract class NewUserProfile with _$NewUserProfile {
  const factory NewUserProfile({
    required String userId,
    required String email,
    String? displayName,

    /// Zona horaria IANA del dispositivo (p. ej. `Europe/Madrid`).
    required String timezone,

    /// `es` o `en`, únicos valores que aceptan las Security Rules.
    required String locale,
    required List<PredefinedAmbito> ambitos,
  }) = _NewUserProfile;
}
