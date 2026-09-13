import 'package:flutter/material.dart';
import 'package:habits/components/habit_icon_catalog.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Tarjeta "Próximo recordatorio" con acción rápida de marcado.
class NextReminderCard extends StatelessWidget {
  const NextReminderCard({
    super.key,
    required this.habit,
    required this.onMarkNow,
  });

  final Habit habit;
  final VoidCallback onMarkNow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final color = Color(habit.colorValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.nextReminder,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIconsRegular.bell, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: HabitIcon(
                  iconId: habit.iconId,
                  legacyEmoji: habit.emoji,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.todayAt(habit.reminderTime ?? ''),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: onMarkNow,
                style: FilledButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.12),
                  foregroundColor: color,
                  textStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(l10n.markNow),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
