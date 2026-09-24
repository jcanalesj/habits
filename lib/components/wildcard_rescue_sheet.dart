import 'package:flutter/material.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Confirmación de uso de un comodín.
///
/// Existe por dos motivos: evitar el doble tap sobre una operación que gasta
/// un recurso (§25) y dejar claro qué hace exactamente un comodín, porque
/// protege la racha pero NO suma un día ni marca ningún hábito (§15/§16).
class WildcardRescueSheet extends StatelessWidget {
  const WildcardRescueSheet({
    super.key,
    required this.rescue,
    required this.available,
  });

  final RescueOpportunity rescue;
  final int available;

  /// Devuelve true si el usuario confirma.
  static Future<bool> show(
    BuildContext context, {
    required RescueOpportunity rescue,
    required int available,
  }) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.palette.surfaceElevated,
      builder: (context) =>
          WildcardRescueSheet(rescue: rescue, available: available),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('🃏', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            l10n.wildcardConfirmTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.wildcardConfirmBody(rescue.day.key, rescue.streakAtRisk),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.wildcardProtectsNotAdds,
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.wildcardsAvailable(available),
            style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.useWildcard),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
