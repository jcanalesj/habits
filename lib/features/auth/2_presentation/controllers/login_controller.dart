import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';

/// Estado de la pantalla de login.
class LoginState {
  const LoginState({
    this.isSubmitting = false,
    this.validationErrors = const {},
    this.signInFailed = false,
  });

  final bool isSubmitting;
  final Set<SignInValidationError> validationErrors;
  final bool signInFailed;

  LoginState copyWith({
    bool? isSubmitting,
    Set<SignInValidationError>? validationErrors,
    bool? signInFailed,
  }) {
    return LoginState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      validationErrors: validationErrors ?? this.validationErrors,
      signInFailed: signInFailed ?? this.signInFailed,
    );
  }
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  /// Intenta iniciar sesión. Devuelve true si tuvo éxito; los errores se
  /// reflejan en el estado y la navegación queda en manos de la página.
  Future<bool> submit({required String email, required String password}) async {
    state = state.copyWith(
      isSubmitting: true,
      validationErrors: {},
      signInFailed: false,
    );

    final result = await ref
        .read(signInUsecaseProvider)
        .execute(email: email, password: password);
    if (!ref.mounted) return false;

    switch (result) {
      case SignInSuccess(:final user):
        ref.read(authControllerProvider.notifier).setUser(user);
        state = state.copyWith(isSubmitting: false);
        return true;
      case SignInValidationFailed(:final errors):
        state = state.copyWith(isSubmitting: false, validationErrors: errors);
        return false;
      case SignInFailed():
        state = state.copyWith(isSubmitting: false, signInFailed: true);
        return false;
    }
  }
}

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);
