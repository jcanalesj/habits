import 'package:flutter/material.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';

/// Título de sección con acción opcional a la derecha ("Ver todos >").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontSize: AppDimensions.sectionTitleFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon: Text(
              actionLabel!,
              style: textTheme.labelLarge?.copyWith(
                color: palette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            label: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: palette.primary,
            ),
          ),
      ],
    );
  }
}
