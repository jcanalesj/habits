import 'package:flutter/material.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Tarjeta del carrusel "Rachas por ámbito". La racha llega aparte del
/// ámbito porque es un dato derivado (caché), no configuración.
class AmbitoStreakCard extends StatelessWidget {
  const AmbitoStreakCard({
    super.key,
    required this.ambito,
    this.streak = const AmbitoStreak(),
  });

  final Ambito ambito;
  final AmbitoStreak streak;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = Color(ambito.colorValue);
    // Progreso hacia la mejor racha histórica, como refuerzo visual.
    final progress = streak.best > 0
        ? (streak.current / streak.best).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: 132,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.white, 0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(ambito.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 12),
          Text(
            ambito.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${streak.current}',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.days,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
