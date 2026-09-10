import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';

/// Estado de la pantalla de recuperación de contraseña.
class ForgotPasswordState {
  const ForgotPasswordState({
    this.isSubmitting = false,
    this.invalidEmail = false,
    this.sent = false,
    this.failure,
  });

  final bool isSubmitting;
  final bool invalidEmail;
  final bool sent;
  final AuthFailure? failure;

  ForgotPasswordState copyWith({
    bool? isSubmitting,
    bool? invalidEmail,
    bool? sent,
    AuthFailure? failure,
    bool clearFailure = false,
  }) {
    return ForgotPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      invalidEmail: invalidEmail ?? this.invalidEmail,
      sent: sent ?? this.sent,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<bool> submit({required String email}) async {
    state = state.copyWith(
      isSubmitting: true,
      invalidEmail: false,
      sent: false,
      clearFailure: true,
    );

    final result = await ref
        .read(sendPasswordResetUsecaseProvider)
        .execute(email: email);
    if (!ref.mounted) return false;

    switch (result) {
      case SendPasswordResetSuccess():
        state = state.copyWith(isSubmitting: false, sent: true);
        return true;
      case SendPasswordResetValidationFailed():
        state = state.copyWith(isSubmitting: false, invalidEmail: true);
        return false;
      case SendPasswordResetFailed(:final failure):
        state = state.copyWith(isSubmitting: false, failure: failure);
        return false;
    }
  }
}

final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, ForgotPasswordState>(
      ForgotPasswordController.new,
    );
