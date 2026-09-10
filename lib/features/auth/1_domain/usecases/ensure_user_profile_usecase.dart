import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/repositories/device_info_repository.dart';
import 'package:habits/features/auth/1_domain/repositories/user_profile_repository.dart';
import 'package:habits/features/auth/1_domain/services/predefined_ambitos.dart';

sealed class EnsureUserProfileResult {}

class EnsureUserProfileCreated extends EnsureUserProfileResult {}

class EnsureUserProfileAlreadyExists extends EnsureUserProfileResult {}

/// No se intenta nada: las Security Rules exigen el email verificado.
class EnsureUserProfileNotVerified extends EnsureUserProfileResult {}

class EnsureUserProfileFailed extends EnsureUserProfileResult {
  final String message;
  EnsureUserProfileFailed(this.message);
}

/// Garantiza que el usuario verificado tiene su perfil (`users/{uid}`) y
/// los ámbitos predefinidos. Es idempotente: se puede invocar en cada inicio
/// de sesión y tras verificar el email.
class EnsureUserProfileUsecase {
  final UserProfileRepository _profiles;
  final DeviceInfoRepository _device;

  EnsureUserProfileUsecase(this._profiles, this._device);

  Future<EnsureUserProfileResult> execute({
    required AppUser user,
    required String locale,
  }) async {
    if (!user.emailVerified) return EnsureUserProfileNotVerified();

    try {
      if (await _profiles.exists(user.id)) {
        return EnsureUserProfileAlreadyExists();
      }
      final normalizedLocale = locale.toLowerCase().startsWith('en')
          ? 'en'
          : 'es';
      await _profiles.create(
        NewUserProfile(
          userId: user.id,
          email: user.email,
          displayName: user.displayName,
          timezone: await _device.currentTimezone(),
          locale: normalizedLocale,
          ambitos: PredefinedAmbitos.forLocale(normalizedLocale),
        ),
      );
      return EnsureUserProfileCreated();
    } catch (e) {
      return EnsureUserProfileFailed(e.toString());
    }
  }
}
