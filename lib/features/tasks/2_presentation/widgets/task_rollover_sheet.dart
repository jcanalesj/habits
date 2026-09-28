import 'package:flutter/material.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_date_label.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Ofrece pasar a hoy las tareas atrasadas: todas o una selección.
/// También permite descartar definitivamente las seleccionadas.
enum TaskRolloverAction { move, delete }

typedef TaskRolloverResult = ({
  TaskRolloverAction action,
  List<TaskItem> tasks,
});

Future<TaskRolloverResult?> showTaskRolloverSheet(
  BuildContext context, {
  required List<TaskItem> overdue,
  required LogicalDate today,
}) => showModalBottomSheet<TaskRolloverResult>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  backgroundColor: context.palette.surfaceElevated,
  builder: (_) => _RolloverSheet(overdue: overdue, today: today),
);

class _RolloverSheet extends StatefulWidget {
  const _RolloverSheet({required this.overdue, required this.today});

  final List<TaskItem> overdue;
  final LogicalDate today;

  @override
  State<_RolloverSheet> createState() => _RolloverSheetState();
}

class _RolloverSheetState extends State<_RolloverSheet> {
  late final Set<String> _selected = {
    for (final task in widget.overdue) task.id,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final partial = _selected.length < widget.overdue.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              PhosphorIconsFill.clockCounterClockwise,
              color: AppColors.pink,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tasksRolloverTitle(widget.overdue.length),
              style: textTheme.titleLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tasksRolloverBody,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final task in widget.overdue)
                    CheckboxListTile(
                      key: ValueKey('rollover-${task.id}'),
                      value: _selected.contains(task.id),
                      onChanged: (checked) => setState(() {
                        if (checked ?? false) {
                          _selected.add(task.id);
                        } else {
                          _selected.remove(task.id);
                        }
                      }),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        taskDayLabel(l10n, locale, task.date!, widget.today),
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('rollover-all'),
              onPressed: () => Navigator.pop(context, (
                action: TaskRolloverAction.move,
                tasks: widget.overdue,
              )),
              child: Text(l10n.tasksRolloverAll),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const ValueKey('rollover-selected'),
              onPressed: partial && _selected.isNotEmpty
                  ? () => Navigator.pop(context, (
                      action: TaskRolloverAction.move,
                      tasks: [
                        for (final task in widget.overdue)
                          if (_selected.contains(task.id)) task,
                      ],
                    ))
                  : null,
              child: Text(l10n.tasksRolloverSelected),
            ),
            TextButton.icon(
              key: const ValueKey('rollover-delete-selected'),
              onPressed: _selected.isEmpty
                  ? null
                  : () => _confirmDelete(context),
              icon: const Icon(PhosphorIconsBold.trash),
              label: Text(l10n.tasksRolloverDeleteSelected),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
            TextButton(
              key: const ValueKey('rollover-not-now'),
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.tasksRolloverNotNow),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.tasksRolloverDeleteTitle),
        content: Text(l10n.tasksRolloverDeleteBody(_selected.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('rollover-confirm-delete'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.tasksRolloverDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    Navigator.pop(context, (
      action: TaskRolloverAction.delete,
      tasks: [
        for (final task in widget.overdue)
          if (_selected.contains(task.id)) task,
      ],
    ));
  }
}
