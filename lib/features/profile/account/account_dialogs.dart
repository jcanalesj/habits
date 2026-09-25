import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/l10n/auth_failure_l10n.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Cambiar contraseña: pide la actual (reautenticación) y la nueva.
Future<void> showChangePasswordDialog(BuildContext context) async {
  final changed = await showDialog<bool>(
    context: context,
    barrierColor: context.palette.scrim,
    builder: (_) => const _ChangePasswordDialog(),
  );
  if (changed == true && context.mounted) {
    AppNotice.show(context, message: context.l10n.passwordChanged);
  }
}

/// Eliminar cuenta: explica qué se borra y confirma con la contraseña.
/// Al terminar, el router lleva al login porque ya no hay sesión.
Future<void> showDeleteAccountDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierColor: context.palette.scrim,
    builder: (_) => const _DeleteAccountDialog(),
  );
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;
  bool _obscureCurrent = true;
  bool _obscureNext = true;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _current.text.isEmpty || _next.text.isEmpty) return;
    final l10n = context.l10n;
    if (_next.text.length < 6) {
      setState(() => _error = l10n.passwordTooShort);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(changePasswordUsecaseProvider)
        .execute(currentPassword: _current.text, newPassword: _next.text);
    if (!mounted) return;
    switch (result) {
      case AccountActionSuccess():
        Navigator.pop(context, true);
      case AccountActionFailed(:final failure):
        setState(() {
          _busy = false;
          _error = failure.localize(l10n);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final canSubmit =
        !_busy && _current.text.isNotEmpty && _next.text.length >= 6;

    return Dialog(
      key: const ValueKey('change-password-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Material(
          color: palette.dialogSurface,
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/cat.png',
                        width: 152,
                        height: 106,
                        fit: BoxFit.contain,
                        semanticLabel: l10n.changePasswordCatImageLabel,
                      ),
                      Positioned(
                        right: -5,
                        top: 4,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: palette.primarySoft,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: palette.surface,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            PhosphorIconsBold.lockKey,
                            color: palette.primary,
                            size: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.changePasswordTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.changePasswordHelper,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _PasswordDialogField(
                    fieldKey: const ValueKey('current-password'),
                    controller: _current,
                    label: l10n.currentPasswordLabel,
                    obscureText: _obscureCurrent,
                    autofillHints: const [AutofillHints.password],
                    enabled: !_busy,
                    onChanged: (_) => setState(() => _error = null),
                    onToggleVisibility: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  const SizedBox(height: 12),
                  _PasswordDialogField(
                    fieldKey: const ValueKey('new-password'),
                    controller: _next,
                    label: l10n.newPasswordLabel,
                    obscureText: _obscureNext,
                    autofillHints: const [AutofillHints.newPassword],
                    enabled: !_busy,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() => _error = null),
                    onSubmitted: (_) => canSubmit ? _submit() : null,
                    onToggleVisibility: () =>
                        setState(() => _obscureNext = !_obscureNext),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      key: const ValueKey('confirm-change-password'),
                      onPressed: canSubmit ? _submit : null,
                      icon: _busy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(PhosphorIconsBold.shieldCheck),
                      label: Text(l10n.savePassword),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.pop(context, false),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordDialogField extends StatelessWidget {
  const _PasswordDialogField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.autofillHints,
    required this.enabled,
    required this.onChanged,
    required this.onToggleVisibility,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Iterable<String> autofillHints;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return TextField(
      key: fieldKey,
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(PhosphorIconsBold.lock, color: palette.primary),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggleVisibility : null,
          tooltip: obscureText ? l10n.showPassword : l10n.hidePassword,
          icon: Icon(
            obscureText ? PhosphorIconsBold.eye : PhosphorIconsBold.eyeSlash,
          ),
        ),
        filled: true,
        fillColor: palette.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _password.text.isEmpty) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(authControllerProvider.notifier)
        .deleteAccount(_password.text);
    switch (result) {
      case AccountActionSuccess():
        if (!mounted) return;
        // El aviso va al overlay raíz, que sobrevive a la redirección al
        // login que provoca quedarse sin sesión.
        AppNotice.show(context, message: l10n.accountDeleted);
        Navigator.pop(context);
      case AccountActionFailed(:final failure):
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = failure.localize(l10n);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    const danger = Color(0xFFFF5A67);

    return Dialog(
      key: const ValueKey('delete-account-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
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
                  l10n.deleteAccountTitle,
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
                    color: danger.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: danger.withValues(alpha: .18)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        PhosphorIconsBold.warningCircle,
                        color: danger,
                        size: 23,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.deleteAccountBody,
                          style: textTheme.bodyMedium?.copyWith(
                            color: palette.textPrimary,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsBold.crown,
                        color: palette.primary,
                        size: 21,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          l10n.deleteAccountSubscriptionNote,
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  key: const ValueKey('delete-account-password'),
                  controller: _password,
                  enabled: !_busy,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.deleteAccountPasswordHint,
                    prefixIcon: const Icon(PhosphorIconsBold.lockKey),
                    suffixIcon: IconButton(
                      onPressed: _busy
                          ? null
                          : () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                      icon: Icon(
                        _obscurePassword
                            ? PhosphorIconsBold.eye
                            : PhosphorIconsBold.eyeSlash,
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: danger.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('confirm-delete-account'),
                    style: FilledButton.styleFrom(
                      backgroundColor: danger,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: danger.withValues(alpha: .35),
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _busy || _password.text.isEmpty ? null : _submit,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(PhosphorIconsBold.trash, size: 19),
                    label: Text(
                      l10n.deleteAccountConfirm,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
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
