import 'package:flutter/material.dart';
import 'package:habits/components/periodicity_label.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Fila de un hábito en "Mis hábitos": emoji, nombre, objetivo, progreso del
/// periodo y la semana en curso con un punto por día.
///
/// Ya no muestra racha por hábito: solo existe la racha general (§1). Lo que
/// aparece a la derecha es el PROGRESO DEL OBJETIVO ("2/3"), que es un
/// concepto distinto (§37).
class HabitListTile extends StatelessWidget {
  const HabitListTile({
    super.key,
    required this.habit,
    required this.weekLogs,
    required this.today,
    required this.onToggleToday,
    this.progress,
    this.onTap,
  });

  final Habit habit;
  final List<HabitLog> weekLogs;
  final LogicalDate today;

  /// Progreso del objetivo en el periodo actual; null si aún no se conoce.
  final GoalProgress? progress;
  final VoidCallback onToggleToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final color = Color(habit.colorValue);
    final goal = progress;

    // Diseño en dos líneas para que quepa en pantallas de móvil:
    // arriba nombre + progreso, debajo la semana a ancho completo.
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
                        PeriodicityLabel.of(l10n, habit.periodicityOn(today)),
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
                if (goal != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.goalProgressLabel(goal.completed, goal.goal),
                        style: textTheme.titleMedium?.copyWith(
                          color: goal.isMet
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        PeriodicityLabel.periodOf(l10n, goal.period.type),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                today: today,
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
    required this.today,
    required this.onToggleToday,
  });

  final String habitId;
  final List<HabitLog> weekLogs;
  final LogicalDate today;
  final VoidCallback onToggleToday;

  @override
  Widget build(BuildContext context) {
    final monday = today.addDays(-(today.weekday - DateTime.monday));
    final dayLabels = context.l10n.weekdayInitials.split(',');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = monday.addDays(index);
        final isToday = day == today;
        final isFuture = day.isAfter(today);
        final isCompleted = weekLogs.any(
          (log) => log.habitId == habitId && log.isActivity && log.date == day,
        );

        return _DayDot(
          // Clave estable: identifica el punto de un día concreto sin tener
          // que adivinar por posición ni por tipo de widget.
          key: ValueKey('habit-dot-$habitId-${day.key}'),
          label: dayLabels[index],
          completed: isCompleted,
          isToday: isToday,
          isFuture: isFuture,
          // Solo el día de hoy es interactivo: no existen registros
          // retroactivos (§14).
          onTap: isToday ? onToggleToday : null,
        );
      }),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    super.key,
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
