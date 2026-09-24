import 'package:flutter/material.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Pie del splash: icono de loto, "Cargando tu mejor versión..." y barra
/// de progreso. [progress] va de 0 a 1.
class SplashLoadingIndicator extends StatelessWidget {
  const SplashLoadingIndicator({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.spa_outlined, size: 28, color: palette.primary),
        const SizedBox(height: 12),
        Text(
          context.l10n.loadingYourBestVersion,
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: palette.primary.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation(palette.primary),
            ),
          ),
        ),
      ],
    );
  }
}
