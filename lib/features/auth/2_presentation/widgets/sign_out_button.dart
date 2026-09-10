import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Botón de cierre de sesión. Tras cerrarla, el router redirige a login al
/// observar el cambio de sesión.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDeep,
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: Text(context.l10n.signOut),
    );
  }
}
