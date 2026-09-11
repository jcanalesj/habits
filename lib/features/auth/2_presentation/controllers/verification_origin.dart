import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Por qué se está mostrando la pantalla de verificación.
enum VerificationOrigin {
  /// Sesión de una cuenta que ya existía y sigue sin verificar (login o
  /// sesión restaurada). Es el valor por defecto, el más conservador.
  existingAccount,

  /// La cuenta se acaba de crear en este dispositivo y el enlace ya se ha
  /// enviado como parte del alta.
  justRegistered,
}

/// Lo fijan los controladores de registro y login ANTES de navegar, no la
/// navegación: así el mensaje es correcto aunque el `redirect` del router
/// llegue a la pantalla de verificación antes que la propia página.
class VerificationOriginController extends Notifier<VerificationOrigin> {
  @override
  VerificationOrigin build() => VerificationOrigin.existingAccount;

  void set(VerificationOrigin origin) => state = origin;
}

final verificationOriginProvider =
    NotifierProvider<VerificationOriginController, VerificationOrigin>(
      VerificationOriginController.new,
    );
