import 'package:flutter/material.dart';
import 'package:habits/components/periodicity_label.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Para qué sirve la fila en cada pantalla.
enum HabitTileMode {
  /// Inicio: sirve para REGISTRAR. No navega a ningún sitio y la única
  /// acción es marcar o desmarcar el hábito de hoy, con un botón grande.
  /// La semana se muestra solo como historial, sin ser pulsable.
  track,

  /// Pestaña Hábitos: sirve para GESTIONAR. La fila navega a la edición.
  manage,
}

/// Fila de un hábito: emoji, nombre, objetivo, progreso del periodo y la
/// semana en curso con un punto por día.
///
/// No muestra racha por hábito: solo existe la racha general (§1). Lo que
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
    this.mode = HabitTileMode.manage,
  });

  final Habit habit;
  final List<HabitLog> weekLogs;
  final LogicalDate today;

  /// Progreso del objetivo en el periodo actual; null si aún no se conoce.
  final GoalProgress? progress;
  final VoidCallback onToggleToday;

  /// Solo se usa en [HabitTileMode.manage].
  final VoidCallback? onTap;
  final HabitTileMode mode;

  bool get _isTracking => mode == HabitTileMode.track;

  bool _isCompletedToday() => weekLogs.any(
    (log) => log.habitId == habit.id && log.isActivity && log.date == today,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final color = Color(habit.colorValue);
    final goal = progress;

    // Diseño en dos líneas para que quepa en pantallas de móvil:
    // arriba nombre + progreso, debajo la semana a ancho completo.
    return InkWell(
      // En Inicio no se edita: desde ahí solo se registra.
      onTap: _isTracking ? null : onTap,
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
                const SizedBox(width: 8),
                if (_isTracking)
                  _TrackToggle(
                    // Clave estable para localizar el control de registro
                    // sin depender del tipo de widget.
                    key: ValueKey('habit-track-${habit.id}'),
                    habitName: habit.name,
                    completed: _isCompletedToday(),
                    color: color,
                    onPressed: onToggleToday,
                  )
                else
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
                // En Inicio la semana es solo historial: la única forma de
                // registrar es el botón, para que no haya dos controles
                // haciendo lo mismo en la misma fila.
                onToggleToday: _isTracking ? null : onToggleToday,
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

  /// Null cuando la semana es solo historial y no admite interacción.
  final VoidCallback? onToggleToday;

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
          // Solo el día de hoy puede ser interactivo: no existen registros
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

/// Botón de registro de hoy. Es la única acción de la fila en Inicio, así
/// que se diseña grande y con estado claro: vacío = pendiente, relleno con
/// check = ya registrado hoy.
class _TrackToggle extends StatelessWidget {
  const _TrackToggle({
    super.key,
    required this.habitName,
    required this.completed,
    required this.color,
    required this.onPressed,
  });

  final String habitName;
  final bool completed;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      button: true,
      checked: completed,
      label: completed
          ? l10n.markHabitUndone(habitName)
          : l10n.markHabitDone(habitName),
      child: InkResponse(
        onTap: onPressed,
        radius: 28,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: completed ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: completed ? color : color.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 22,
            color: completed ? Colors.white : color.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
