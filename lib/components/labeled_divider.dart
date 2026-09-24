import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

/// Separador horizontal con etiqueta central ("o continúa con").
class LabeledDivider extends StatelessWidget {
  const LabeledDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final line = Expanded(
      child: Divider(color: palette.primary.withValues(alpha: 0.15)),
    );

    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ),
        line,
      ],
    );
  }
}
