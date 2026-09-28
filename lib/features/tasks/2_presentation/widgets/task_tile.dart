import 'package:flutter/material.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_date_label.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Fila de una tarea: casilla circular, título, línea secundaria (hora,
/// prioridad, arrastre) y caret para editar.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.today,
    required this.onToggle,
    required this.onTap,
    this.showDate = false,
  });

  final TaskItem task;
  final LogicalDate today;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  /// Muestra el día en la línea secundaria (vistas que mezclan días).
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final done = task.isCompleted;
    final overdue = !done && task.date != null && task.date!.isBefore(today);

    final details = <InlineSpan>[];
    void addDetail(String text, {Color? color, FontWeight? weight}) {
      if (details.isNotEmpty) {
        details.add(
          TextSpan(
            text: '  ·  ',
            style: TextStyle(color: palette.textHint),
          ),
        );
      }
      details.add(
        TextSpan(
          text: text,
          style: TextStyle(color: color, fontWeight: weight),
        ),
      );
    }

    if (showDate && task.date != null) {
      addDetail(taskDayLabel(l10n, locale, task.date!, today));
    }
    if (task.time != null) addDetail(task.time!);
    if (task.priority == TaskPriority.high) {
      addDetail(
        l10n.tasksPriorityHigh,
        color: AppColors.flame,
        weight: FontWeight.w800,
      );
    }
    if (overdue) {
      addDetail(
        l10n.tasksOverdueBadge,
        color: AppColors.orange,
        weight: FontWeight.w800,
      );
    }
    if (task.rolledFrom != null) {
      addDetail(l10n.tasksRolledFrom(taskShortDate(locale, task.rolledFrom!)));
    }
    if (task.note?.isNotEmpty ?? false) {
      addDetail(task.note!);
    }

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              Semantics(
                button: true,
                checked: done,
                label: done
                    ? l10n.tasksMarkUndone(task.title)
                    : l10n.tasksMarkDone(task.title),
                child: InkWell(
                  key: ValueKey('task-toggle-${task.id}'),
                  onTap: onToggle,
                  customBorder: const CircleBorder(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? palette.primary : Colors.transparent,
                      border: Border.all(
                        color: done ? palette.primary : palette.textHint,
                        width: 2,
                      ),
                    ),
                    child: done
                        ? Icon(
                            PhosphorIconsBold.check,
                            size: 16,
                            color: palette.onPrimary,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: done
                            ? palette.textSecondary
                            : palette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: palette.textSecondary,
                      ),
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text.rich(
                        TextSpan(children: details),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                PhosphorIconsBold.caretRight,
                color: palette.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
