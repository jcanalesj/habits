import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';

/// Texto localizado para cada fallo de autenticación.
extension AuthFailureL10n on AuthFailure {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      AuthFailure.invalidCredentials => l10n.authErrorInvalidCredentials,
      AuthFailure.emailAlreadyInUse => l10n.authErrorEmailAlreadyInUse,
      AuthFailure.weakPassword => l10n.authErrorWeakPassword,
      AuthFailure.invalidEmail => l10n.authErrorInvalidEmail,
      AuthFailure.userDisabled => l10n.authErrorUserDisabled,
      AuthFailure.tooManyRequests => l10n.authErrorTooManyRequests,
      AuthFailure.network => l10n.authErrorNetwork,
      AuthFailure.requiresRecentLogin => l10n.authErrorRequiresRecentLogin,
      AuthFailure.noSession => l10n.authErrorNoSession,
      AuthFailure.unknown => l10n.authErrorUnknown,
    };
  }
}
