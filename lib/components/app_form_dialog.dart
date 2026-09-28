import 'package:flutter/material.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Héroe de un diálogo: la mascota con una insignia, o un icono grande en
/// un cuadrado tintado. Son las dos cabeceras que usan todos los diálogos
/// de la app (contraseña, peso, borrado…).
class AppDialogHero extends StatelessWidget {
  const AppDialogHero.icon({super.key, required IconData this.icon, this.color})
    : badge = null,
      asset = null;

  const AppDialogHero.cat({
    super.key,
    required IconData this.badge,
    this.color,
    this.asset = 'assets/images/cat.png',
  }) : icon = null;

  final IconData? icon;
  final IconData? badge;
  final Color? color;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = color ?? palette.primary;
    if (icon != null) {
      return Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.tint(accent),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, color: accent, size: 36),
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Image.asset(
          asset!,
          width: 152,
          height: 106,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
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
              border: Border.all(color: palette.surface, width: 3),
            ),
            child: Icon(badge, color: accent, size: 21),
          ),
        ),
      ],
    );
  }
}

/// Andamio de los diálogos de formulario de Constanza: héroe, título,
/// texto de ayuda, campos, caja de error, CTA principal a ancho completo y
/// botón de cancelar. Las pantallas solo aportan los campos.
class AppFormDialog extends StatelessWidget {
  const AppFormDialog({
    super.key,
    required this.title,
    required this.primaryLabel,
    required this.onPrimary,
    this.hero,
    this.helper,
    this.children = const [],
    this.primaryIcon,
    this.primaryColor,
    this.isBusy = false,
    this.error,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryKey,
    this.maxWidth = 430,
  });

  final Widget? hero;
  final String title;
  final String? helper;
  final List<Widget> children;
  final String primaryLabel;
  final IconData? primaryIcon;

  /// Color del CTA (rojo en acciones destructivas). Por defecto el primario.
  final Color? primaryColor;
  final VoidCallback? onPrimary;
  final bool isBusy;
  final String? error;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Key? primaryKey;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: palette.dialogSurface,
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hero != null) ...[
                  Center(child: hero),
                  const SizedBox(height: 14),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (helper != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    helper!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                if (children.isNotEmpty) const SizedBox(height: 20),
                ...children,
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      error!,
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
                  height: 54,
                  child: FilledButton.icon(
                    key: primaryKey,
                    onPressed: isBusy ? null : onPrimary,
                    icon: isBusy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(primaryIcon ?? PhosphorIconsBold.check),
                    label: Text(primaryLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: primaryColor == null
                          ? null
                          : Colors.white,
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
                  onPressed: isBusy
                      ? null
                      : (onSecondary ?? () => Navigator.pop(context)),
                  child: Text(secondaryLabel ?? l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
