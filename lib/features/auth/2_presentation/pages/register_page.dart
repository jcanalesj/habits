import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final List<FocusNode> _focusNodes;

  bool _acceptedTerms = false;
  bool _submitted = false;
  int _focusedField = 0;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(4, (index) {
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus && mounted) {
          setState(() => _focusedField = index);
        }
      });
      return node;
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _emailIsValid => RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  ).hasMatch(_emailController.text.trim());

  bool get _formIsValid =>
      _nicknameController.text.trim().isNotEmpty &&
      _emailIsValid &&
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmPasswordController.text &&
      _acceptedTerms;

  void _register() {
    setState(() => _submitted = true);
    if (!_formIsValid) return;

    final email = _emailController.text.trim();
    context.push(
      Uri(
        path: '/verify-email',
        queryParameters: {
          'email': email,
          'nickname': _nicknameController.text.trim(),
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final keyboardOffset = keyboardVisible
        ? switch (_focusedField) {
            0 => const Offset(0, -0.02),
            1 => const Offset(0, -0.05),
            2 => const Offset(0, -0.12),
            _ => const Offset(0, -0.2),
          }
        : Offset.zero;

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
                      offset: keyboardOffset,
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
                                child: _BackButton(
                                  onPressed: () => context.pop(),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const _RegisterBrand(),
                              const SizedBox(height: 26),
                              Text(
                                l10n.registerTitle,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineLarge?.copyWith(
                                  color: AppColors.authHeading,
                                  fontSize: AppDimensions.authTitleFontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.registerSubtitle,
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.authSecondary,
                                  fontSize: AppDimensions.authSubtitleFontSize,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _RegisterField(
                                controller: _nicknameController,
                                focusNode: _focusNodes[0],
                                icon: Icons.person_outline_rounded,
                                label: l10n.nicknameLabel,
                                hint: l10n.nicknameHint,
                                textInputAction: TextInputAction.next,
                                errorText:
                                    _submitted &&
                                        _nicknameController.text.trim().isEmpty
                                    ? l10n.nicknameRequired
                                    : null,
                              ),
                              const SizedBox(height: AppDimensions.authFormGap),
                              _RegisterField(
                                controller: _emailController,
                                focusNode: _focusNodes[1],
                                icon: Icons.mail_outline_rounded,
                                label: l10n.emailLabel,
                                hint: l10n.emailExampleHint,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                errorText: _submitted && !_emailIsValid
                                    ? l10n.registerInvalidEmail
                                    : null,
                              ),
                              const SizedBox(height: AppDimensions.authFormGap),
                              _RegisterField(
                                controller: _passwordController,
                                focusNode: _focusNodes[2],
                                icon: Icons.lock_outline_rounded,
                                label: l10n.passwordLabel,
                                hint: l10n.registerPasswordHint,
                                obscurable: true,
                                textInputAction: TextInputAction.next,
                                errorText:
                                    _submitted &&
                                        _passwordController.text.length < 8
                                    ? l10n.registerPasswordTooShort
                                    : null,
                              ),
                              const SizedBox(height: AppDimensions.authFormGap),
                              _RegisterField(
                                controller: _confirmPasswordController,
                                focusNode: _focusNodes[3],
                                icon: Icons.lock_outline_rounded,
                                label: l10n.confirmPasswordLabel,
                                hint: l10n.confirmPasswordHint,
                                obscurable: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _register(),
                                errorText:
                                    _submitted &&
                                        _passwordController.text !=
                                            _confirmPasswordController.text
                                    ? l10n.passwordsDoNotMatch
                                    : null,
                              ),
                              const SizedBox(height: 22),
                              _TermsRow(
                                value: _acceptedTerms,
                                onChanged: (value) =>
                                    setState(() => _acceptedTerms = value),
                                errorText: _submitted && !_acceptedTerms
                                    ? l10n.acceptTermsError
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              GradientButton(
                                label: l10n.registerButton,
                                trailingArrow: false,
                                onPressed: _register,
                              ),
                              const SizedBox(height: 24),
                              _LoginPrompt(
                                onPressed: () => context.go('/login'),
                              ),
                              const SizedBox(height: 20),
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      shape: const CircleBorder(),
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

class _RegisterBrand extends StatelessWidget {
  const _RegisterBrand();

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

class _RegisterField extends StatefulWidget {
  const _RegisterField({
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.label,
    required this.hint,
    this.obscurable = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.errorText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final String label;
  final String hint;
  final bool obscurable;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;

  @override
  State<_RegisterField> createState() => _RegisterFieldState();
}

class _RegisterFieldState extends State<_RegisterField> {
  late bool _obscured = widget.obscurable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor = widget.errorText == null
        ? AppColors.primary.withValues(alpha: 0.2)
        : Colors.redAccent.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.authFieldMinHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(AppDimensions.authFieldRadius),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimensions.authFieldIconSize,
                height: AppDimensions.authFieldIconSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: _obscured,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  autocorrect: !widget.obscurable,
                  decoration: InputDecoration(
                    labelText: widget.errorText ?? widget.label,
                    hintText: widget.hint,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: textTheme.bodyMedium?.copyWith(
                      color: widget.errorText == null
                          ? AppColors.authFieldLabel
                          : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: AppColors.authFieldHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 12, bottom: 3),
                  ),
                ),
              ),
              if (widget.obscurable)
                IconButton(
                  onPressed: () => setState(() => _obscured = !_obscured),
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.authLegalText,
      height: 1.45,
    );
    final linkStyle = baseStyle?.copyWith(color: AppColors.primaryDeep);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: (next) => onChanged(next ?? false),
          activeColor: AppColors.primaryDeep,
          side: const BorderSide(color: AppColors.primaryDeep, width: 1.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: errorText != null
                ? Text(
                    errorText!,
                    style: baseStyle?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Text.rich(
                    TextSpan(
                      style: baseStyle,
                      children: [
                        TextSpan(text: l10n.acceptTermsPrefix),
                        TextSpan(
                          text: l10n.termsAndConditions,
                          style: linkStyle,
                        ),
                        TextSpan(text: l10n.privacyJoiner),
                        TextSpan(text: l10n.privacyPolicy, style: linkStyle),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final line = Expanded(
      child: Divider(color: AppColors.primary.withValues(alpha: 0.18)),
    );

    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: 280,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.alreadyHaveAccount,
                    style: textTheme.bodySmall?.copyWith(
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
                    child: Text(context.l10n.signInAction),
                  ),
                ],
              ),
            ),
          ),
        ),
        line,
      ],
    );
  }
}
