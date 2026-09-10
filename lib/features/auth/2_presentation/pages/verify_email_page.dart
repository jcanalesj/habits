import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/0_entity/entity.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key, required this.email, this.displayName});

  final String email;
  final String? displayName;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  static const _codeLength = 6;
  static const _expirationSeconds = 5 * 60;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _timer;
  int _secondsRemaining = _expirationSeconds;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onCodeChanged(int index, String value) {
    if (_showError) setState(() => _showError = false);
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == _codeLength - 1) {
      FocusScope.of(context).unfocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verify() {
    if (_code.length != _codeLength) {
      setState(() => _showError = true);
      _focusNodes.first.requestFocus();
      return;
    }

    ref
        .read(authControllerProvider.notifier)
        .setUser(
          AppUser(
            id: 'mock-${widget.email.hashCode}',
            email: widget.email,
            displayName: widget.displayName,
            emailVerified: true,
          ),
        );
    context.go('/home');
  }

  void _resendCode() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _secondsRemaining = _expirationSeconds;
      _showError = false;
    });
    _startTimer();
    _focusNodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgrounds/registro_background.png',
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
                  child: Center(
                    child: AnimatedSlide(
                      offset: keyboardVisible
                          ? const Offset(0, -0.12)
                          : Offset.zero,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
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
                                  onPressed: () => context.pop(),
                                ),
                              ),
                              const SizedBox(height: 48),
                              const _VerificationBrand(),
                              const SizedBox(height: 38),
                              Text(
                                l10n.verifyAccountTitle,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineLarge?.copyWith(
                                  color: AppColors.authHeading,
                                  fontSize: AppDimensions.authTitleFontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.7,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.verificationCodeSent,
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.authSecondary,
                                  fontSize: AppDimensions.authSubtitleFontSize,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.email,
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.primaryDeep,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 52),
                              _PinCodeInput(
                                controllers: _controllers,
                                focusNodes: _focusNodes,
                                showError: _showError,
                                onChanged: _onCodeChanged,
                              ),
                              const SizedBox(height: 18),
                              if (_showError)
                                Text(
                                  l10n.invalidVerificationCode,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                _ExpirationLabel(time: _formattedTime),
                              const SizedBox(height: 52),
                              GradientButton(
                                label: l10n.verifyButton,
                                trailingArrow: false,
                                onPressed: _verify,
                              ),
                              const SizedBox(height: 24),
                              _ResendPrompt(onPressed: _resendCode),
                              const SizedBox(height: 96),
                              const Icon(
                                Icons.spa_outlined,
                                size: 34,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
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

class _VerificationBackButton extends StatelessWidget {
  const _VerificationBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.16),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded),
        color: AppColors.primaryDeep,
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

class _PinCodeInput extends StatelessWidget {
  const _PinCodeInput({
    required this.controllers,
    required this.focusNodes,
    required this.showError,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool showError;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(controllers.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 5,
              right: index == controllers.length - 1 ? 0 : 5,
            ),
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              maxLength: 1,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textInputAction: index == controllers.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  1,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
              ],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryDeep,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '—',
                hintStyle: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.78),
                contentPadding: const EdgeInsets.symmetric(vertical: 22),
                enabledBorder: _border(showError ? Colors.redAccent : null),
                focusedBorder: _border(
                  showError ? Colors.redAccent : AppColors.primaryDeep,
                  width: 1.8,
                ),
              ),
              onChanged: (value) => onChanged(index, value),
              onSubmitted: (_) {
                if (index == controllers.length - 1) {
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }

  OutlineInputBorder _border(Color? color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color ?? AppColors.primary.withValues(alpha: 0.2),
        width: width,
      ),
    );
  }
}

class _ExpirationLabel extends StatelessWidget {
  const _ExpirationLabel({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.codeExpiresIn(time),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.authSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResendPrompt extends StatelessWidget {
  const _ResendPrompt({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.codeNotReceived,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.authPromptText,
                ),
              ),
              TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.only(left: 4),
                ),
                child: Text(context.l10n.resendCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
