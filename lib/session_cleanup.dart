import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/login_controller.dart';
import 'package:habits/features/auth/2_presentation/controllers/post_registration.dart';
import 'package:habits/features/auth/2_presentation/controllers/register_controller.dart';
import 'package:habits/features/auth/2_presentation/controllers/verification_origin.dart';
import 'package:habits/features/auth/2_presentation/controllers/verify_email_controller.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/premium/2_presentation/premium_providers.dart';
import 'package:habits/features/profile/appearance/app_icon.dart';
import 'package:habits/features/profile/appearance/theme_mode_preferences.dart';
import 'package:habits/firebase_setup.dart';
import 'package:habits/local_preferences.dart';

/// Deja el dispositivo limpio al cerrar sesión (o borrar la cuenta).
///
/// Lo que vive fuera de Firestore no se va solo con `signOut`: los avisos
/// programados (con los nombres de los hábitos del usuario anterior), las
/// preferencias locales y el estado de los flujos de acceso. Sin esto, el
/// siguiente usuario del mismo móvil los heredaría.
final sessionCleanupProvider = Provider<SessionCleanup>(SessionCleanup.new);

class SessionCleanup {
  SessionCleanup(this._ref);

  final Ref _ref;

  /// Antes de cerrar sesión: lo que aún necesita saber quién es el usuario.
  Future<void> beforeSignOut() async {
    await _safely('cancelar avisos', () async {
      await _ref.read(notificationsRepositoryProvider).cancelAll();
    });
    await _safely('restaurar icono', () async {
      final icon = _ref.read(appIconProvider).value;
      if (icon != null && icon.isPremium) {
        await _ref.read(appIconProvider.notifier).select(AppIconOption.classic);
      }
    });
  }

  /// Después de cerrar sesión: preferencias y flujos de acceso a cero.
  Future<void> afterSignOut() async {
    await _safely('limpiar preferencias', () async {
      final preferences = _ref.read(sharedPreferencesProvider);
      // Clave del antiguo acceso de prueba Premium, por si quedó guardada.
      await preferences?.remove('premium_preview_enabled');
      // La caché offline de Firestore se vacía en el próximo arranque.
      await preferences?.setBool(clearFirestoreCacheOnStartKey, true);
      _ref.read(themeModeProvider.notifier).resetForSignOut();
    });
    await _safely('desvincular tienda', () async {
      await _ref.read(purchasesRepositoryProvider).reset();
    });
    _ref
      ..invalidate(loginControllerProvider)
      ..invalidate(registerControllerProvider)
      ..invalidate(verifyEmailControllerProvider)
      ..invalidate(justRegisteredProvider)
      ..invalidate(verificationOriginProvider);
  }

  /// Ningún paso de limpieza puede impedir cerrar sesión.
  Future<void> _safely(String step, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('Limpieza de sesión ($step) ha fallado: $error');
    }
  }
}
