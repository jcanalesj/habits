import 'package:flutter/material.dart';
import 'package:habits/components/habit_icon_catalog.dart';
import 'package:habits/components/periodicity_label.dart';
import 'package:habits/components/progress_icon_picker.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Para qué sirve la fila en cada pantalla.
enum HabitTileMode {
  /// Inicio: sirve para REGISTRAR. No navega a ningún sitio y la única
  /// acción es marcar o desmarcar el hábito de hoy, con un botón grande.
  /// La semana se muestra solo como historial, sin ser pulsable.
  track,

  /// Inicio compacto: registra igual que [track], pero sin calendario.
  trackCompact,

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
    this.onSetDailyCount,
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
  final ValueChanged<int>? onSetDailyCount;

  bool get _isTracking => mode != HabitTileMode.manage;
  bool get _isCompact => mode == HabitTileMode.trackCompact;

  bool _isCompletedToday() => weekLogs.any(
    (log) => log.habitId == habit.id && log.isActivity && log.date == today,
  );

  int _completedCountToday() {
    for (final log in weekLogs) {
      if (log.habitId == habit.id &&
          log.date == today &&
          log.type == HabitLogType.completed) {
        return log.completedCount;
      }
    }
    return 0;
  }

  int _targetCountToday() {
    for (final log in weekLogs) {
      if (log.habitId == habit.id &&
          log.date == today &&
          log.type == HabitLogType.completed) {
        return log.targetCount;
      }
    }
    return habit.targetCount;
  }

  Widget _buildCompact(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final color = Color(habit.colorValue);
    final completedToday = _isCompletedToday();
    final repetitions = habit.hasRepetitions;
    final goal = progress;

    return Semantics(
      button: onTap != null,
      label: onTap == null ? null : l10n.editHabitTitle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withValues(alpha: 0.10),
              color.withValues(alpha: completedToday ? 0.22 : 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: color.withValues(alpha: 0.14),
            highlightColor: color.withValues(alpha: 0.07),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: HabitIcon(
                      iconId: habit.iconId,
                      legacyEmoji: habit.emoji,
                      size: 46,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: AppDimensions.cardTitleFontSize,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          PeriodicityLabel.of(l10n, habit.periodicityOn(today)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (repetitions)
                    _CompactRepetitionAction(
                      habit: habit.copyWith(targetCount: _targetCountToday()),
                      count: _completedCountToday(),
                      onChanged: onSetDailyCount,
                    )
                  else ...[
                    Text(
                      goal == null
                          ? (completedToday ? '1 / 1' : '0 / 1')
                          : '${goal.completed} / ${goal.goal}',
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: AppDimensions.cardTitleFontSize,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _TrackToggle(
                      key: ValueKey('habit-track-${habit.id}'),
                      habitName: habit.name,
                      completed: completedToday,
                      color: color,
                      compact: true,
                      onPressed: onToggleToday,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompact) return _buildCompact(context);

    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final color = Color(habit.colorValue);
    // Variante oscura del color asignado para conservar contraste incluso
    // cuando el usuario elige tonos pastel como amarillo, rosa o celeste.
    final actionColor = Color.lerp(color, AppColors.textPrimary, 0.42)!;
    final goal = progress;
    final completedToday = _isCompletedToday();
    final repetitions = _isTracking && habit.hasRepetitions;
    final action = _isTracking ? (repetitions ? null : onToggleToday) : onTap;
    const iconSurface = Color(0xFFF4F1FC);

    // Diseño en dos líneas para que quepa en pantallas de móvil:
    // arriba nombre + progreso, debajo la semana a ancho completo.
    return Semantics(
      button: action != null,
      checked: _isTracking ? completedToday : null,
      label: _isTracking
          ? (completedToday
                ? l10n.markHabitUndone(habit.name)
                : l10n.markHabitDone(habit.name))
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isCompact
                ? [
                    color.withValues(alpha: 0.13),
                    color.withValues(alpha: completedToday ? 0.24 : 0.19),
                  ]
                : completedToday
                ? [Colors.white, color.withValues(alpha: 0.18)]
                : [Colors.white, color.withValues(alpha: 0.09)],
          ),
          borderRadius: BorderRadius.circular(_isCompact ? 20 : 28),
          border: _isCompact || habit.hasRepetitions
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.9)),
          boxShadow: _isCompact
              ? null
              : [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // En Inicio toda la tarjeta registra; en gestión abre la edición.
            onTap: action,
            borderRadius: BorderRadius.circular(_isCompact ? 20 : 28),
            splashColor: color.withValues(alpha: 0.14),
            highlightColor: color.withValues(alpha: 0.07),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _isCompact ? 10 : 16,
                _isCompact ? 8 : 16,
                _isCompact ? 10 : 16,
                _isCompact ? 8 : 14,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: _isCompact ? 42 : 58,
                        height: _isCompact ? 42 : 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: iconSurface,
                          borderRadius: BorderRadius.circular(
                            _isCompact ? 16 : 18,
                          ),
                        ),
                        child: HabitIcon(
                          iconId: habit.iconId,
                          legacyEmoji: habit.emoji,
                          size: _isCompact ? 30 : 42,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              habit.hasRepetitions && habit.displayGoal != null
                                  ? habit.displayGoal!
                                  : _isCompact
                                  ? '${PeriodicityLabel.of(l10n, habit.periodicityOn(today))}  ·  ${completedToday ? l10n.habitCompletedEncouragement : l10n.habitPendingEncouragement}'
                                  : PeriodicityLabel.of(
                                      l10n,
                                      habit.periodicityOn(today),
                                    ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (!_isCompact) ...[
                              const SizedBox(height: 7),
                              Text(
                                completedToday
                                    ? l10n.habitCompletedEncouragement
                                    : l10n.habitPendingEncouragement,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (habit.hasRepetitions && _isTracking)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _isCompact ? 10 : 18,
                            vertical: _isCompact ? 6 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: iconSurface,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${_completedCountToday()}',
                                  style: TextStyle(
                                    color: actionColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / ${_targetCountToday()}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            style:
                                (_isCompact
                                        ? textTheme.titleMedium
                                        : textTheme.headlineSmall)
                                    ?.copyWith(height: 1),
                          ),
                        )
                      else if (goal != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.goalProgressLabel(goal.completed, goal.goal),
                              style: textTheme.titleMedium?.copyWith(
                                color: goal.isMet
                                    ? (_isCompact ? color : actionColor)
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
                      if (_isTracking && !repetitions)
                        ExcludeSemantics(
                          child: _TrackToggle(
                            // Clave estable para localizar el control de registro
                            // sin depender del tipo de widget.
                            key: ValueKey('habit-track-${habit.id}'),
                            habitName: habit.name,
                            completed: completedToday,
                            color: color,
                            compact: _isCompact,
                            onPressed: onToggleToday,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                  if (!_isCompact) const SizedBox(height: 16),
                  if (repetitions) ...[
                    if (!_isCompact) const SizedBox(height: 2),
                    _RepetitionProgress(
                      habit: habit.copyWith(targetCount: _targetCountToday()),
                      count: _completedCountToday(),
                      compact: _isCompact,
                      onChanged: onSetDailyCount,
                    ),
                    if (!_isCompact) const SizedBox(height: 14),
                  ],
                  if (_isTracking && !_isCompact)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      child: _WeekDots(
                        habitId: habit.id,
                        weekLogs: weekLogs,
                        today: today,
                        color: color,
                        // En Inicio la semana es solo historial; la card registra.
                        onToggleToday: null,
                      ),
                    )
                  else if (!_isTracking)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        key: ValueKey('habit-edit-${habit.id}'),
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: actionColor.withValues(
                            alpha: 0.45,
                          ),
                          disabledForegroundColor: Colors.white70,
                          elevation: 2,
                          shadowColor: actionColor.withValues(alpha: 0.35),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          PhosphorIconsBold.pencilSimple,
                          size: 18,
                        ),
                        label: Text(
                          l10n.editHabitTitle,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RepetitionProgress extends StatelessWidget {
  const _RepetitionProgress({
    required this.habit,
    required this.count,
    required this.compact,
    required this.onChanged,
  });
  final Habit habit;
  final int count;
  final bool compact;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final target = habit.targetCount.clamp(1, 999);
    final safeCount = count.clamp(0, target);
    final unit = habit.unit == null ? '' : ' ${habit.unit}';
    final l10n = context.l10n;
    if (target > ProgressIconCatalog.individualIconLimit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HabitProgressIcon(
                iconId: habit.progressIconId,
                completed: safeCount >= target,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.habitRepetitionProgress(safeCount, target, unit),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: safeCount > 0 && onChanged != null
                    ? () => onChanged!(safeCount - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                visualDensity: VisualDensity.compact,
                onPressed: safeCount < target && onChanged != null
                    ? () => onChanged!(safeCount + 1)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: safeCount / target,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: .12),
            ),
          ),
        ],
      );
    }
    return Wrap(
      spacing: compact ? 5 : 8,
      runSpacing: 6,
      children: List.generate(target, (index) {
        final done = index < safeCount;
        final nextCount = done ? safeCount - 1 : safeCount + 1;
        final label = done
            ? l10n.habitRepetitionItemCompleted(
                habit.unit ?? habit.name,
                index + 1,
                target,
              )
            : l10n.habitRepetitionItemPending(
                habit.unit ?? habit.name,
                index + 1,
                target,
              );
        return Semantics(
          button: onChanged != null,
          checked: done,
          label: label,
          child: InkWell(
            onTap: onChanged == null ? null : () => onChanged!(nextCount),
            borderRadius: BorderRadius.circular(15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: compact ? 42 : 52,
              height: compact ? 42 : 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1FC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: HabitProgressIcon(
                iconId: habit.progressIconId,
                completed: done,
                size: compact ? 30 : 38,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CompactRepetitionAction extends StatelessWidget {
  const _CompactRepetitionAction({
    required this.habit,
    required this.count,
    required this.onChanged,
  });

  final Habit habit;
  final int count;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final target = habit.targetCount.clamp(1, 999);
    final safeCount = count.clamp(0, target);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$safeCount / $target',
          style: textTheme.titleMedium?.copyWith(
            fontSize: AppDimensions.cardTitleFontSize,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _RepetitionProgress(
          habit: habit,
          count: safeCount,
          compact: true,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _WeekDots extends StatelessWidget {
  const _WeekDots({
    required this.habitId,
    required this.weekLogs,
    required this.today,
    required this.color,
    required this.onToggleToday,
  });

  final String habitId;
  final List<HabitLog> weekLogs;
  final LogicalDate today;
  final Color color;

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
          color: color,
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
    required this.color,
    this.onTap,
  });

  final String label;
  final bool completed;
  final bool isToday;
  final bool isFuture;
  final Color color;
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
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isFuture ? AppColors.textSecondary : color,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? color : Colors.transparent,
              border: completed
                  ? null
                  : Border.all(
                      color: isToday
                          ? color
                          : AppColors.textSecondary.withValues(alpha: 0.35),
                      width: isToday ? 2.4 : 1.5,
                    ),
            ),
            child: completed
                ? const Icon(
                    PhosphorIconsBold.check,
                    size: 17,
                    color: Colors.white,
                  )
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
    required this.compact,
    required this.onPressed,
  });

  final String habitName;
  final bool completed;
  final Color color;
  final bool compact;
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
          width: compact ? 44 : 52,
          height: compact ? 44 : 52,
          decoration: BoxDecoration(
            gradient: completed
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(color, Colors.white, 0.18)!,
                      Color.lerp(color, Colors.black, 0.08)!,
                    ],
                  )
                : null,
            color: completed ? null : color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            completed
                ? PhosphorIconsBold.check
                : compact
                ? PhosphorIconsRegular.plus
                : PhosphorIconsFill.play,
            size: compact ? 24 : 28,
            color: completed ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
