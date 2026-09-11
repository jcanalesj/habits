import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/controllers/verification_origin.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';

/// Resultado del login desde el punto de vista de la navegación.
enum LoginOutcome {
  /// Sesión iniciada con el correo verificado: a la home.
  verified,

  /// Credenciales correctas pero el correo sigue sin verificar: a la
  /// pantalla de verificación. Aquí sí conocemos legítimamente el estado de
  /// la cuenta porque el usuario ha demostrado saber su contraseña.
  needsVerification,

  /// No se pudo iniciar sesión; el motivo está en el estado.
  failed,
}

/// Estado de la pantalla de login.
class LoginState {
  const LoginState({
    this.isSubmitting = false,
    this.validationErrors = const {},
    this.failure,
  });

  final bool isSubmitting;
  final Set<SignInValidationError> validationErrors;

  /// Fallo del proveedor en el último intento, ya traducido a dominio.
  final AuthFailure? failure;

  LoginState copyWith({
    bool? isSubmitting,
    Set<SignInValidationError>? validationErrors,
    AuthFailure? failure,
    bool clearFailure = false,
  }) {
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      validationErrors: validationErrors ?? this.validationErrors,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  /// Intenta iniciar sesión. La sesión la publica el AuthController al
  /// recibir el cambio del repositorio; la navegación queda en la página.
  Future<LoginOutcome> submit({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      validationErrors: {},
      clearFailure: true,
    );

    final result = await ref
        .read(signInUsecaseProvider)
        .execute(email: email, password: password);
    if (!ref.mounted) return LoginOutcome.failed;

    switch (result) {
      case SignInSuccess(:final user):
        state = state.copyWith(isSubmitting: false);
        if (user.emailVerified) return LoginOutcome.verified;
        ref
            .read(verificationOriginProvider.notifier)
            .set(VerificationOrigin.existingAccount);
        return LoginOutcome.needsVerification;
      case SignInValidationFailed(:final errors):
        state = state.copyWith(isSubmitting: false, validationErrors: errors);
        return LoginOutcome.failed;
      case SignInFailed(:final failure):
        state = state.copyWith(isSubmitting: false, failure: failure);
        return LoginOutcome.failed;
    }
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
