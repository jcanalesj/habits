import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';

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

  /// Intenta iniciar sesión. Devuelve true si tuvo éxito; los errores se
  /// reflejan en el estado. La sesión la publica el AuthController al
  /// recibir el cambio del repositorio; la navegación queda en la página.
  Future<bool> submit({required String email, required String password}) async {
    state = state.copyWith(
      isSubmitting: true,
      validationErrors: {},
      clearFailure: true,
    );

    final result = await ref
        .read(signInUsecaseProvider)
        .execute(email: email, password: password);
    if (!ref.mounted) return false;

    switch (result) {
      case SignInSuccess():
        state = state.copyWith(isSubmitting: false);
        return true;
      case SignInValidationFailed(:final errors):
        state = state.copyWith(isSubmitting: false, validationErrors: errors);
        return false;
      case SignInFailed(:final failure):
        state = state.copyWith(isSubmitting: false, failure: failure);
        return false;
    }
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
