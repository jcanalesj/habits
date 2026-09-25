import 'package:flutter/material.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Estado de error de una pantalla: mensaje legible y botón de reintentar.
///
/// Nunca muestra la excepción en crudo ("[cloud_firestore/permission-denied]
/// …"): no le dice nada al usuario. El detalle va al log.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.onRetry, this.error});

  final VoidCallback onRetry;

  /// Solo para el log de depuración.
  final Object? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) debugPrint('AppErrorView: $error');
    final l10n = context.l10n;
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.cloudSlash(),
              size: 40,
              color: palette.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.errorLoadFailed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const ValueKey('error-retry'),
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
