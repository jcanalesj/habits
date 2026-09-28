import 'package:flutter/material.dart';
import 'package:habits/components/surface_decoration.dart';
import 'package:habits/theme/app_theme.dart';

/// Estado vacío de una lista o sección: icono lila y texto centrado dentro
/// de la decoración de superficie. Acepta una acción opcional.
class EmptyStateBlock extends StatelessWidget {
  const EmptyStateBlock({
    super.key,
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
    this.color = AppColors.lilac,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: surfaceDecoration(palette),
      child: Column(
        children: [
          Icon(icon, color: color, size: 38),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, height: 1.35),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 14),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
