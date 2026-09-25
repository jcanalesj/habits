import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/l10n/auth_failure_l10n.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Botón de cierre de sesión. Tras cerrarla, el router redirige a login al
/// observar el cambio de sesión.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return OutlinedButton.icon(
      onPressed: () => _confirmAndSignOut(context, ref),
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primaryDeep,
        side: BorderSide(color: palette.primary.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: Text(context.l10n.signOut),
    );
  }
}

Future<void> _confirmAndSignOut(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: context.palette.scrim,
    builder: (context) => AlertDialog(
      key: const ValueKey('sign-out-dialog'),
      title: Text(l10n.signOutConfirmTitle),
      content: Text(l10n.signOutConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('confirm-sign-out'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.signOut),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final result = await ref.read(authControllerProvider.notifier).signOut();
  if (result is SignOutFailed && context.mounted) {
    AppNotice.show(
      context,
      message: result.failure.localize(l10n),
      type: AppNoticeType.error,
    );
  }
}
