import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/2_presentation/controllers/forgot_password_controller.dart';
import 'package:habits/features/auth/2_presentation/l10n/auth_failure_l10n.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';

/// Recuperación de contraseña: Firebase envía un enlace con el que el
/// usuario define una nueva contraseña desde el navegador.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail});

  /// Correo con el que llegar precargado.
  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail ?? '';
  }

  /// go_router reutiliza esta página cuando solo cambia el `?email=`, así
  /// que el State sobrevive y hay que resincronizar el campo a mano.
  @override
  void didUpdateWidget(ForgotPasswordPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final email = widget.initialEmail;
    if (email != null && email != oldWidget.initialEmail) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    return ref
        .read(forgotPasswordControllerProvider.notifier)
        .submit(email: _emailController.text);
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(forgotPasswordControllerProvider);
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgrounds/login_background.png',
            fit: BoxFit.cover,
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
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    alignment: keyboardVisible
                        ? Alignment.topCenter
                        : Alignment.center,
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
                              child: Material(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  onPressed: _back,
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  color: AppColors.primaryDeep,
                                  iconSize: 28,
                                  padding: const EdgeInsets.all(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SurfaceCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    l10n.forgotPasswordTitle,
                                    textAlign: TextAlign.center,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontSize: AppDimensions.authTitleFontSize,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.sent
                                        ? l10n.resetLinkSent
                                        : l10n.forgotPasswordSubtitle,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize:
                                          AppDimensions.authSubtitleFontSize,
                                      color: state.sent
                                          ? AppColors.green
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (state.sent)
                                    GradientButton(
                                      label: l10n.backToSignIn,
                                      trailingArrow: false,
                                      onPressed: () => context.go('/login'),
                                    )
                                  else ...[
                                    AuthTextField(
                                      controller: _emailController,
                                      hint: l10n.emailHint,
                                      icon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _submit(),
                                      errorText: state.invalidEmail
                                          ? l10n.invalidEmail
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    if (state.failure != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          state.failure!.localize(l10n),
                                          textAlign: TextAlign.center,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    GradientButton(
                                      label: l10n.sendResetLink,
                                      isLoading: state.isSubmitting,
                                      onPressed: _submit,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const BrandFooter(),
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
