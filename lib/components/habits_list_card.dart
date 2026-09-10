import 'package:flutter/material.dart';
import 'package:habits/components/habit_list_tile.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Tarjeta blanca de "Mis hábitos": lista de hábitos con su semana y el
/// enlace "Ver todos mis hábitos".
class HabitsListCard extends StatelessWidget {
  const HabitsListCard({
    super.key,
    required this.habits,
    required this.weekLogs,
    required this.onToggleToday,
    this.streakOf,
    this.onSeeAll,
    this.onHabitTap,
  });

  final List<Habit> habits;
  final List<HabitLog> weekLogs;

  /// Racha actual por hábito (dato derivado); null o ausente → 0.
  final int Function(String habitId)? streakOf;
  final ValueChanged<String> onToggleToday;
  final VoidCallback? onSeeAll;
  final ValueChanged<Habit>? onHabitTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              child: Text(
                context.l10n.noHabitsYet,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          for (final habit in habits)
            HabitListTile(
              habit: habit,
              weekLogs: weekLogs,
              currentStreak: streakOf?.call(habit.id) ?? 0,
              onToggleToday: () => onToggleToday(habit.id),
              onTap: onHabitTap == null ? null : () => onHabitTap!(habit),
            ),
          TextButton.icon(
            onPressed: onSeeAll,
            icon: Text(
              context.l10n.seeAllMyHabits,
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            label: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
