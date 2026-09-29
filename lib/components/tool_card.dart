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
    this.backgroundAsset,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String? value;
  final bool locked;
  final String? backgroundAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final illustrated = backgroundAsset != null;
    final panelColor = palette.isDark
        ? palette.surface
        : Color.alphaBlend(accent.withValues(alpha: .05), Colors.white);
    final panelTopOpacity = palette.isDark ? .86 : .58;
    final panelBottomOpacity = palette.isDark ? .96 : .80;
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: illustrated ? palette.tint(accent, .10) : null,
              gradient: backgroundAsset == null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.surface.withValues(
                          alpha: palette.isDark ? 1 : .92,
                        ),
                        palette.isDark
                            ? Color.alphaBlend(
                                palette.tint(accent, .10),
                                palette.surface,
                              )
                            : accent.withValues(alpha: .10),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: .18)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: .08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (backgroundAsset case final asset?) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Transform.scale(
                      scale: 1.05,
                      child: Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        // Los personajes están en la mitad inferior de estos
                        // PNG verticales. Anclar abajo los sube dentro del
                        // recorte apaisado y evita que los tape la bandeja.
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      heightFactor: .60,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(26),
                            topRight: Radius.circular(26),
                            bottomLeft: Radius.circular(19),
                            bottomRight: Radius.circular(19),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              panelColor.withValues(alpha: panelTopOpacity),
                              panelColor.withValues(alpha: panelBottomOpacity),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.all(illustrated ? 10 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: illustrated ? 32 : 36,
                            height: illustrated ? 32 : 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: illustrated && palette.isDark
                                  ? Color.alphaBlend(
                                      accent.withValues(alpha: .24),
                                      palette.surface.withValues(alpha: .92),
                                    )
                                  : palette.tint(accent, .14),
                              borderRadius: BorderRadius.circular(
                                illustrated ? 11 : 12,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: accent,
                              size: illustrated ? 19 : 21,
                            ),
                          ),
                          const Spacer(),
                          if (locked)
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: palette.tint(AppColors.orange, .14),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                PhosphorIconsFill.crown,
                                color: AppColors.orange,
                                size: 14,
                              ),
                            )
                          else if (!illustrated)
                            Icon(
                              PhosphorIconsBold.caretRight,
                              color: palette.textSecondary,
                              size: 16,
                            ),
                        ],
                      ),
                      if (backgroundAsset != null)
                        const Spacer()
                      else
                        const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (illustrated && !locked)
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: panelColor.withValues(
                                  alpha: palette.isDark ? .94 : .72,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                PhosphorIconsBold.caretRight,
                                color: palette.isDark
                                    ? palette.textPrimary
                                    : palette.textSecondary,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: illustrated ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                          height: 1.15,
                        ),
                      ),
                      if (value != null) ...[
                        SizedBox(height: illustrated ? 3 : 5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value!,
                            maxLines: 1,
                            style: TextStyle(
                              color: accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
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
