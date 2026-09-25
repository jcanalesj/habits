import 'package:flutter/material.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Campo de texto de auth: icono en cuadrado lila, fondo lila suave uniforme
/// redondeado y toggle de visibilidad opcional para contraseñas.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscurable = false,
    this.keyboardType,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscurable;
  final TextInputType? keyboardType;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.obscurable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: palette.authFieldFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.errorText != null
                  ? Colors.redAccent.withValues(alpha: 0.6)
                  : palette.primary.withValues(alpha: 0.15),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.tint(palette.primary, 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 19, color: palette.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscured,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  autocorrect: !widget.obscurable,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    labelText: widget.errorText,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: textTheme.bodySmall?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                    // El tema global rellena todos los campos de lila;
                    // aquí el fondo lo pinta el contenedor exterior.
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: widget.errorText == null
                        ? const EdgeInsets.symmetric(vertical: 16)
                        : const EdgeInsets.only(top: 12, bottom: 4),
                  ),
                ),
              ),
              if (widget.obscurable)
                IconButton(
                  tooltip: _obscured
                      ? context.l10n.a11yShowPassword
                      : context.l10n.a11yHidePassword,
                  onPressed: () => setState(() => _obscured = !_obscured),
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 22,
                    color: palette.primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
