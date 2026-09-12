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
    required this.today,
    required this.onToggleToday,
    this.progressOf,
    this.onSeeAll,
    this.onHabitTap,
    this.mode = HabitTileMode.manage,
    this.emptyMessage,
  });

  final List<Habit> habits;
  final List<HabitLog> weekLogs;
  final LogicalDate today;

  /// Progreso del objetivo por hábito. Es progreso, no racha (§37).
  final GoalProgress? Function(String habitId)? progressOf;
  final ValueChanged<String> onToggleToday;
  final VoidCallback? onSeeAll;
  final ValueChanged<Habit>? onHabitTap;
  final HabitTileMode mode;

  /// Texto cuando no hay hábitos que mostrar en esta tarjeta.
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        if (habits.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Text(
              emptyMessage ?? context.l10n.noHabitsYet,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        for (final habit in habits)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: HabitListTile(
              habit: habit,
              weekLogs: weekLogs,
              today: today,
              progress: progressOf?.call(habit.id),
              mode: mode,
              onToggleToday: () => onToggleToday(habit.id),
              onTap: onHabitTap == null ? null : () => onHabitTap!(habit),
            ),
          ),
        // Texto flexible en vez de TextButton.icon: la etiqueta larga
        // desbordaba por la derecha en anchos de móvil.
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    context.l10n.seeAllMyHabits,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
