import 'package:flutter/material.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Barra de navegación inferior: Inicio, Mis hábitos, Herramientas (en el
/// centro), Estadísticas y Perfil. El orden es el de las ramas del shell en
/// `navigation.dart`.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Espacio inferior reservado por las pantallas que quedan bajo la barra.
  static const double contentClearance = 150;

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = <_NavTab>[
    _NavTab(PhosphorIconsRegular.house, PhosphorIconsFill.house, _homeLabel),
    _NavTab(
      PhosphorIconsRegular.calendarDots,
      PhosphorIconsFill.calendarDots,
      _habitsLabel,
    ),
    _NavTab(
      PhosphorIconsRegular.squaresFour,
      PhosphorIconsFill.squaresFour,
      _toolsLabel,
    ),
    _NavTab(
      PhosphorIconsRegular.chartBar,
      PhosphorIconsFill.chartBar,
      _statsLabel,
    ),
    _NavTab(PhosphorIconsRegular.user, PhosphorIconsFill.user, _profileLabel),
  ];

  static String _homeLabel(AppLocalizations l10n) => l10n.navHome;
  static String _habitsLabel(AppLocalizations l10n) => l10n.navHabits;
  static String _toolsLabel(AppLocalizations l10n) => l10n.navTools;
  static String _statsLabel(AppLocalizations l10n) => l10n.navStats;
  static String _profileLabel(AppLocalizations l10n) => l10n.navProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final (index, tab) in _tabs.indexed)
                Expanded(
                  child: _NavItem(
                    icon: currentIndex == index ? tab.fill : tab.regular,
                    label: tab.label(l10n),
                    selected: currentIndex == index,
                    onTap: () => onTap(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab(this.regular, this.fill, this.label);
  final IconData regular;
  final IconData fill;
  final String Function(AppLocalizations l10n) label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final color = selected ? palette.primary : palette.textSecondary;

    // Align con heightFactor: el item ocupa el ancho que le da el Row
    // (Expanded) pero solo la altura de su contenido, con el "pill"
    // centrado y ajustado al contenido.
    return Align(
      heightFactor: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: selected
              ? BoxDecoration(
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                )
              : null,
          // Escala el contenido si la etiqueta no cabe en el ancho del
          // item (idiomas largos, fuentes grandes) en lugar de desbordar.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  style: textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
