import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
import 'package:habits/features/auth/2_presentation/controllers/login_controller.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref
        .read(loginControllerProvider.notifier)
        .submit(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (success && mounted) context.go('/home');
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(loginControllerProvider);
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
                          children: [
                            _AnimatedKeyboardSection(
                              visible: !keyboardVisible,
                              alignment: Alignment.bottomCenter,
                              child: const Column(
                                children: [
                                  AuthHeader(
                                    logoSize: AppDimensions.authHeroLogoSize,
                                    wordmarkSize:
                                        AppDimensions.authHeroWordmarkSize,
                                    spacing: 7,
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                            SurfaceCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    l10n.signInTitle,
                                    textAlign: TextAlign.center,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontSize: AppDimensions.authTitleFontSize,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.signInSubtitle,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize:
                                          AppDimensions.authSubtitleFontSize,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    controller: _emailController,
                                    hint: l10n.emailHint,
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    errorText:
                                        state.validationErrors.contains(
                                          SignInValidationError.invalidEmail,
                                        )
                                        ? l10n.invalidEmail
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  AuthTextField(
                                    controller: _passwordController,
                                    hint: l10n.passwordHint,
                                    icon: Icons.lock_outline_rounded,
                                    obscurable: true,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _submit(),
                                    errorText:
                                        state.validationErrors.contains(
                                          SignInValidationError
                                              .passwordTooShort,
                                        )
                                        ? l10n.passwordTooShort
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _showComingSoon,
                                      child: Text(
                                        l10n.forgotPassword,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (state.signInFailed)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        l10n.signInError,
                                        textAlign: TextAlign.center,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  GradientButton(
                                    label: l10n.continueLabel,
                                    isLoading: state.isSubmitting,
                                    onPressed: _submit,
                                  ),
                                  const SizedBox(height: 14),
                                  LabeledDivider(label: l10n.orContinueWith),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      SocialLoginButton(
                                        provider: SocialProvider.google,
                                        onPressed: _showComingSoon,
                                      ),
                                      const SizedBox(width: 16),
                                      SocialLoginButton(
                                        provider: SocialProvider.apple,
                                        onPressed: _showComingSoon,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        l10n.noAccountQuestion,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            context.push('/register'),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          minimumSize: Size.zero,
                                        ),
                                        child: Text(
                                          l10n.registerAction,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _AnimatedKeyboardSection(
                              visible: !keyboardVisible,
                              alignment: Alignment.topCenter,
                              child: const Column(
                                children: [SizedBox(height: 12), BrandFooter()],
                              ),
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

class _AnimatedKeyboardSection extends StatelessWidget {
  const _AnimatedKeyboardSection({
    required this.visible,
    required this.alignment,
    required this.child,
  });

  final bool visible;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: visible ? 1 : 0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return ClipRect(
          child: Align(
            alignment: alignment,
            heightFactor: value,
            child: Opacity(opacity: value, child: child),
          ),
        );
      },
    );
  }
}
