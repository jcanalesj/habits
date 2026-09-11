import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';

/// Estado de sesión de la app, alimentado por el stream del repositorio
/// (`authStateChanges`/`userChanges` en Firebase). Es la única fuente de
/// verdad: el router y las pantallas reaccionan a él.
class AuthController extends StreamNotifier<AppUser?> {
  @override
  Stream<AppUser?> build() => ref.watch(authRepositoryProvider).watchUser();

  /// Adelanta al stream con un usuario ya recargado (p. ej. justo después
  /// de confirmar la verificación del email) para que el router redirija
  /// sin esperar a la siguiente emisión.
  void setUser(AppUser? user) => state = AsyncData(user);

  Future<SignOutResult> signOut() async {
    final result = await ref.read(signOutUsecaseProvider).execute();
    if (!ref.mounted) return result;
    if (result is SignOutSuccess) state = const AsyncData(null);
    return result;
  }
}

final authControllerProvider = StreamNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

/// Identidad de la sesión que importa para el perfil: solo cambia si cambia
/// el usuario o su estado de verificación (no con cada refresco de token).
typedef _SessionIdentity = ({String id, bool verified});

/// Garantiza el perfil en backend (`users/{uid}` + ámbitos) del usuario
/// verificado. Se observa desde la zona autenticada de la app y se
/// re-ejecuta solo cuando cambia la identidad de sesión.
final ensureUserProfileProvider = FutureProvider.autoDispose
    .family<EnsureUserProfileResult?, String>((ref, locale) async {
      final identity = ref.watch(
        authControllerProvider.select<_SessionIdentity?>((auth) {
          final user = auth.value;
          if (user == null) return null;
          return (id: user.id, verified: user.emailVerified);
        }),
      );
      // Con la verificación desactivada basta con tener sesión; las reglas
      // tampoco exigen `email_verified` en ese caso.
      final requiresVerification = ref.watch(requireEmailVerificationProvider);
      if (identity == null) return null;
      if (requiresVerification && !identity.verified) return null;

      final user = ref.read(authControllerProvider).value;
      if (user == null) return null;
      return ref
          .read(ensureUserProfileUsecaseProvider)
          .execute(user: user, locale: locale);
    });
