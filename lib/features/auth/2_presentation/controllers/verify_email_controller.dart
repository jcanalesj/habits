import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';

/// Estado de la pantalla de verificación por enlace.
class VerifyEmailState {
  const VerifyEmailState({
    this.isChecking = false,
    this.isResending = false,
    this.pendingAfterCheck = false,
    this.resent = false,
    this.verificationSent = false,
    this.failure,
  });

  final bool isChecking;
  final bool isResending;

  /// El usuario pulsó "ya he verificado" pero el proveedor sigue sin
  /// reflejarlo.
  final bool pendingAfterCheck;

  /// El último reenvío se completó.
  final bool resent;

  /// Ya se ha garantizado un envío en esta sesión, sea por el alta o por el
  /// envío automático al abrir la pantalla. Evita duplicar correos si el
  /// usuario entra y sale de la verificación.
  final bool verificationSent;
  final AuthFailure? failure;

  VerifyEmailState copyWith({
    bool? isChecking,
    bool? isResending,
    bool? pendingAfterCheck,
    bool? resent,
    bool? verificationSent,
    AuthFailure? failure,
    bool clearFailure = false,
  }) {
    return VerifyEmailState(
      isChecking: isChecking ?? this.isChecking,
      isResending: isResending ?? this.isResending,
      pendingAfterCheck: pendingAfterCheck ?? this.pendingAfterCheck,
      resent: resent ?? this.resent,
      verificationSent: verificationSent ?? this.verificationSent,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class VerifyEmailController extends Notifier<VerifyEmailState> {
  @override
  VerifyEmailState build() => const VerifyEmailState();

  /// Comprueba contra el proveedor si el email ya está verificado. Si lo
  /// está, publica el usuario recargado en la sesión y devuelve true.
  /// Con [silent] (sondeo automático) no se muestran mensajes de pendiente.
  Future<bool> checkVerified({bool silent = false}) async {
    if (state.isChecking) return false;
    if (!silent) {
      state = state.copyWith(
        isChecking: true,
        pendingAfterCheck: false,
        resent: false,
        clearFailure: true,
      );
    }

    final result = await ref.read(checkEmailVerifiedUsecaseProvider).execute();
    if (!ref.mounted) return false;

    switch (result) {
      case CheckEmailVerifiedConfirmed(:final user):
        ref.read(authControllerProvider.notifier).setUser(user);
        state = state.copyWith(isChecking: false, pendingAfterCheck: false);
        return true;
      case CheckEmailVerifiedPending():
        state = state.copyWith(
          isChecking: false,
          pendingAfterCheck: silent ? state.pendingAfterCheck : true,
        );
        return false;
      case CheckEmailVerifiedFailed(:final failure):
        state = silent
            ? state.copyWith(isChecking: false)
            : state.copyWith(isChecking: false, failure: failure);
        return false;
    }
  }

  /// Garantiza que el usuario tiene un enlace reciente al abrir la
  /// pantalla. Si [alreadySent] (el alta acaba de enviarlo) solo marca el
  /// envío como hecho. Devuelve true si ha enviado un correo ahora.
  Future<bool> ensureVerificationSent({required bool alreadySent}) async {
    if (state.verificationSent) return false;
    state = state.copyWith(verificationSent: true);
    if (alreadySent) return false;
    return resend();
  }

  /// Reenvía el enlace de verificación. Devuelve true si se envió.
  Future<bool> resend() async {
    if (state.isResending) return false;
    state = state.copyWith(
      isResending: true,
      resent: false,
      pendingAfterCheck: false,
      verificationSent: true,
      clearFailure: true,
    );

    final result = await ref
        .read(sendEmailVerificationUsecaseProvider)
        .execute();
    if (!ref.mounted) return false;

    switch (result) {
      case SendEmailVerificationSuccess():
        state = state.copyWith(isResending: false, resent: true);
        return true;
      case SendEmailVerificationFailed(:final failure):
        state = state.copyWith(isResending: false, failure: failure);
        return false;
    }
  }
}

final verifyEmailControllerProvider =
    NotifierProvider<VerifyEmailController, VerifyEmailState>(
      VerifyEmailController.new,
    );
