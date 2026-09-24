import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/controllers/verification_origin.dart';
import 'package:habits/features/auth/2_presentation/controllers/verify_email_controller.dart';
import 'package:habits/features/auth/2_presentation/l10n/auth_failure_l10n.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';

/// Verificación del email mediante el enlace que envía Firebase Auth.
///
/// El usuario abre el enlace desde su correo y vuelve a la app; la pantalla
/// comprueba el estado real contra el proveedor al pulsar el botón y,
/// además, lo sondea automáticamente cada pocos segundos. Al confirmarse,
/// la sesión se actualiza y el router lleva a la home.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  /// Intervalo del sondeo automático de verificación.
  static const pollInterval = Duration(seconds: 5);

  /// Espera mínima entre reenvíos del correo.
  static const resendCooldown = Duration(seconds: 30);

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  Timer? _ticker;
  int _elapsedSeconds = 0;
  int _resendCooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    // El alta ya envía el enlace; al llegar desde el login o con la sesión
    // restaurada lo enviamos aquí, para que el usuario tenga siempre un
    // correo reciente sin tener que pedirlo. En ambos casos se arranca la
    // espera del reenvío manual para no duplicar correos.
    _resendCooldownSeconds = VerifyEmailPage.resendCooldown.inSeconds;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSent());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  /// Envío automático al abrir la pantalla, una sola vez por sesión.
  Future<void> _ensureSent() async {
    final alreadySent =
        ref.read(verificationOriginProvider) ==
        VerificationOrigin.justRegistered;
    await ref
        .read(verifyEmailControllerProvider.notifier)
        .ensureVerificationSent(alreadySent: alreadySent);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    _elapsedSeconds++;
    if (_resendCooldownSeconds > 0) {
      setState(() => _resendCooldownSeconds--);
    }
    if (_elapsedSeconds % VerifyEmailPage.pollInterval.inSeconds == 0) {
      _check(silent: true);
    }
  }

  Future<void> _check({bool silent = false}) async {
    final verified = await ref
        .read(verifyEmailControllerProvider.notifier)
        .checkVerified(silent: silent);
    if (verified && mounted) context.go('/home');
  }

  Future<void> _resend() async {
    final sent = await ref
        .read(verifyEmailControllerProvider.notifier)
        .resend();
    if (sent && mounted) {
      setState(
        () => _resendCooldownSeconds = VerifyEmailPage.resendCooldown.inSeconds,
      );
    }
  }

  Future<void> _useAnotherAccount() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final state = ref.watch(verifyEmailControllerProvider);
    final email = ref.watch(authControllerProvider).value?.email ?? '';
    // La cuenta ya existía (login o sesión restaurada): se explica que solo
    // falta este paso, en lugar de dar por hecho que acabamos de enviarlo.
    final pendingAccount =
        ref.watch(verificationOriginProvider) ==
        VerificationOrigin.existingAccount;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(
            asset: 'assets/backgrounds/registro_background.png',
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = (constraints.maxWidth - 32)
                    .clamp(0.0, AppDimensions.authContentMaxWidth)
                    .toDouble();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _VerificationBackButton(
                                onPressed: _useAnotherAccount,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const _VerificationBrand(),
                            const SizedBox(height: 34),
                            Text(
                              l10n.verifyAccountTitle,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineLarge?.copyWith(
                                color: palette.authHeading,
                                fontSize: AppDimensions.authTitleFontSize,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.7,
                              ),
                            ),
                            const SizedBox(height: 28),
                            const _MailIllustration(),
                            const SizedBox(height: 24),
                            Text(
                              l10n.verifyLinkSent,
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: palette.authSecondary,
                                fontSize: AppDimensions.authSubtitleFontSize,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: context.palette.primaryDeep,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.verifyLinkInstructions,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: palette.authSecondary,
                              ),
                            ),
                            if (pendingAccount) ...[
                              const SizedBox(height: 16),
                              const _PendingVerificationNotice(),
                            ],
                            const SizedBox(height: 28),
                            _StatusMessage(state: state),
                            const SizedBox(height: 12),
                            GradientButton(
                              label: l10n.iHaveVerified,
                              trailingArrow: false,
                              isLoading: state.isChecking,
                              onPressed: _check,
                            ),
                            const SizedBox(height: 20),
                            _ResendPrompt(
                              cooldownSeconds: _resendCooldownSeconds,
                              isResending: state.isResending,
                              onPressed: _resend,
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: TextButton(
                                onPressed: _useAnotherAccount,
                                child: Text(
                                  l10n.useAnotherAccount,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: palette.authPromptText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 56),
                            Icon(
                              Icons.spa_outlined,
                              size: 34,
                              color: palette.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso para una cuenta que ya existía y sigue pendiente de verificar.
class _PendingVerificationNotice extends StatelessWidget {
  const _PendingVerificationNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: palette.tint(palette.primary, 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: context.palette.primaryDeep,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pendingVerificationTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.authHeading,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.pendingVerificationBody,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.authSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.state});

  final VerifyEmailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final (String? text, Color color) = switch (state) {
      VerifyEmailState(:final failure?) => (
        failure.localize(l10n),
        Colors.redAccent,
      ),
      VerifyEmailState(pendingAfterCheck: true) => (
        l10n.notVerifiedYet,
        AppColors.flame,
      ),
      VerifyEmailState(resent: true) => (l10n.emailResent, AppColors.green),
      _ => (null, Colors.transparent),
    };

    // Altura fija para que el layout no salte al aparecer el mensaje.
    return SizedBox(
      height: 44,
      child: text == null
          ? null
          : Text(
              text,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class _MailIllustration extends StatelessWidget {
  const _MailIllustration();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: palette.isDark ? 1 : 0.82),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.mark_email_unread_outlined,
          size: 46,
          color: context.palette.primaryDeep,
        ),
      ),
    );
  }
}

class _VerificationBackButton extends StatelessWidget {
  const _VerificationBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface.withValues(alpha: palette.isDark ? 1 : 0.82),
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: palette.shadow,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded),
        color: context.palette.primaryDeep,
        iconSize: 28,
        padding: const EdgeInsets.all(14),
      ),
    );
  }
}

class _VerificationBrand extends StatelessWidget {
  const _VerificationBrand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstanzaLogo(size: AppDimensions.authCompactLogoSize),
        SizedBox(width: 6),
        ConstanzaWordmark(fontSize: AppDimensions.authCompactWordmarkSize),
      ],
    );
  }
}

class _ResendPrompt extends StatelessWidget {
  const _ResendPrompt({
    required this.cooldownSeconds,
    required this.isResending,
    required this.onPressed,
  });

  final int cooldownSeconds;
  final bool isResending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = cooldownSeconds == 0 && !isResending;

    return Center(
      child: SizedBox(
        width: 300,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.emailNotReceived,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.palette.authPromptText,
                ),
              ),
              TextButton(
                onPressed: enabled ? onPressed : null,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.only(left: 4),
                ),
                child: Text(
                  cooldownSeconds > 0
                      ? l10n.resendEmailIn(cooldownSeconds)
                      : l10n.resendEmail,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
