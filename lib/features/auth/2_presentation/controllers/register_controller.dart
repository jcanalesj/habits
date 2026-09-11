import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/controllers/post_registration.dart';
import 'package:habits/features/auth/2_presentation/controllers/verification_origin.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';

/// Estado de la pantalla de registro.
class RegisterState {
  const RegisterState({
    this.isSubmitting = false,
    this.validationErrors = const {},
    this.failure,
  });

  final bool isSubmitting;
  final Set<SignUpValidationError> validationErrors;
  final AuthFailure? failure;

  RegisterState copyWith({
    bool? isSubmitting,
    Set<SignUpValidationError>? validationErrors,
    AuthFailure? failure,
    bool clearFailure = false,
  }) {
    return RegisterState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      validationErrors: validationErrors ?? this.validationErrors,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  /// Crea la cuenta. Devuelve true si tuvo éxito: el usuario queda con
  /// sesión sin verificar y el router lo llevará a la verificación.
  ///
  /// Si el correo ya está registrado NO se intenta iniciar sesión: el fallo
  /// queda en el estado y la página ofrece ir al login o a recuperar la
  /// contraseña.
  Future<bool> submit({
    required String nickname,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      validationErrors: {},
      clearFailure: true,
    );
    // Antes de crear la cuenta: el cambio de sesión llega DURANTE el alta y
    // el redirect no debe pasar por la home ni un solo frame. Si lo hiciera,
    // el perfil se crearía antes de tener el nombre.
    ref.read(justRegisteredProvider.notifier).markRegistered();

    final result = await ref
        .read(signUpUsecaseProvider)
        .execute(
          nickname: nickname,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          acceptedTerms: acceptedTerms,
        );
    if (!ref.mounted) return false;

    switch (result) {
      case SignUpSuccess(:final user):
        // El nombre se fija justo después de crear la cuenta y el stream de
        // sesión puede no haberlo emitido todavía; lo publicamos aquí para
        // que el perfil no se cree con el displayName vacío.
        ref.read(authControllerProvider.notifier).setUser(user);
        ref
            .read(verificationOriginProvider.notifier)
            .set(VerificationOrigin.justRegistered);
        ref.read(justRegisteredProvider.notifier).markRegistered();
        state = state.copyWith(isSubmitting: false);
        return true;
      case SignUpValidationFailed(:final errors):
        ref.read(justRegisteredProvider.notifier).clear();
        state = state.copyWith(isSubmitting: false, validationErrors: errors);
        return false;
      case SignUpFailed(:final failure):
        ref.read(justRegisteredProvider.notifier).clear();
        state = state.copyWith(isSubmitting: false, failure: failure);
        return false;
    }
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);
