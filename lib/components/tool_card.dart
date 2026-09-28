import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Tarjeta del panel de Herramientas: icono tintado, título, subtítulo y un
/// dato vivo ("3 pendientes hoy"). Con [locked] muestra una corona en vez
/// del caret: la herramienta es Premium y el usuario aún no tiene acceso.
class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.value,
    this.locked = false,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String? value;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.surface.withValues(alpha: palette.isDark ? 1 : .92),
                  palette.isDark
                      ? Color.alphaBlend(
                          palette.tint(accent, .10),
                          palette.surface,
                        )
                      : accent.withValues(alpha: .10),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent.withValues(alpha: .18)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: .08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: palette.tint(accent, .14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: accent, size: 24),
                      ),
                      const Spacer(),
                      if (locked)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: palette.tint(AppColors.orange, .14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            PhosphorIconsFill.crown,
                            color: AppColors.orange,
                            size: 16,
                          ),
                        )
                      else
                        Icon(
                          PhosphorIconsBold.caretRight,
                          color: palette.textSecondary,
                          size: 16,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value!,
                        maxLines: 1,
                        style: TextStyle(
                          color: accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
