import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
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
      case SignUpSuccess():
        state = state.copyWith(isSubmitting: false);
        return true;
      case SignUpValidationFailed(:final errors):
        state = state.copyWith(isSubmitting: false, validationErrors: errors);
        return false;
      case SignUpFailed(:final failure):
        state = state.copyWith(isSubmitting: false, failure: failure);
        return false;
    }
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);
