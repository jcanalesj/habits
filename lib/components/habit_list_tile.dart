import 'package:flutter/material.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Fila de un hábito en "Mis hábitos": emoji, nombre, racha y la semana
/// en curso con un punto por día. El punto de hoy es interactivo.
class HabitListTile extends StatelessWidget {
  const HabitListTile({
    super.key,
    required this.habit,
    required this.weekLogs,
    required this.onToggleToday,
    this.currentStreak = 0,
    this.onTap,
  });

  final Habit habit;
  final List<HabitLog> weekLogs;

  /// Racha actual (dato derivado de la caché de rachas; 0 si no existe).
  final int currentStreak;
  final VoidCallback onToggleToday;
  final VoidCallback? onTap;

  String _subtitle(AppLocalizations l10n) {
    final periodicity = switch (habit.periodicity) {
      Periodicity.daily => l10n.periodicityDaily,
      Periodicity.weekly => l10n.periodicityWeekly,
      Periodicity.monthly => l10n.periodicityMonthly,
      Periodicity.yearly => l10n.periodicityYearly,
    };
    if (habit.restDaysAllowed == 0) return periodicity;
    return '$periodicity · ${l10n.restDaysCount(habit.restDaysAllowed)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = Color(habit.colorValue);

    // Diseño en dos líneas para que quepa en pantallas de móvil:
    // arriba nombre + racha, debajo la semana a ancho completo.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
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
                  child: Text(
                    habit.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(context.l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('🔥', style: textTheme.bodySmall),
                const SizedBox(width: 2),
                Text(
                  '$currentStreak',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 58, right: 28),
              child: _WeekDots(
                habitId: habit.id,
                weekLogs: weekLogs,
                onToggleToday: onToggleToday,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDots extends StatelessWidget {
  const _WeekDots({
    required this.habitId,
    required this.weekLogs,
    required this.onToggleToday,
  });

  final String habitId;
  final List<HabitLog> weekLogs;
  final VoidCallback onToggleToday;

  @override
  Widget build(BuildContext context) {
    final today = LogicalDay.today();
    final monday = LogicalDay.mondayOfWeek(today);
    final dayLabels = context.l10n.weekdayInitials.split(',');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = monday.add(Duration(days: index));
        final isToday = LogicalDay.isSameDay(day, today);
        final isFuture = day.isAfter(today);
        final isCompleted = weekLogs.any(
          (log) =>
              log.habitId == habitId && LogicalDay.isSameDay(log.date, day),
        );

        return _DayDot(
          label: dayLabels[index],
          completed: isCompleted,
          isToday: isToday,
          isFuture: isFuture,
          onTap: isToday ? onToggleToday : null,
        );
      }),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.completed,
    required this.isToday,
    required this.isFuture,
    this.onTap,
  });

  final String label;
  final bool completed;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isFuture ? AppColors.textSecondary : AppColors.primary,
          ),
        ),
        const SizedBox(height: 3),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? AppColors.primary : Colors.transparent,
              border: completed
                  ? null
                  : Border.all(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.35),
                      width: isToday ? 2 : 1.4,
                    ),
            ),
            child: completed
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }
}
