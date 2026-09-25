import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/l10n/auth_failure_l10n.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

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
    builder: (context) => _SignOutDialog(l10n: l10n),
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

class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      key: const ValueKey('sign-out-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: palette.dialogSurface,
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/gatotriste.png',
                  width: 150,
                  height: 126,
                  fit: BoxFit.contain,
                  semanticLabel: l10n.sadCatImageLabel,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.signOutConfirmTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsBold.info,
                        color: palette.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.signOutConfirmBody,
                          style: textTheme.bodyMedium?.copyWith(
                            color: palette.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('confirm-sign-out'),
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: palette.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(PhosphorIconsBold.signOut, size: 19),
                    label: Text(
                      l10n.signOut,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: palette.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
