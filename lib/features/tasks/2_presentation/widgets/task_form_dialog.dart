import 'package:flutter/material.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_date_label.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Crear o editar una tarea. Devuelve el borrador o null si se cancela.
Future<TaskDraft?> showTaskFormDialog(
  BuildContext context, {
  required LogicalDate today,
  TaskItem? initial,
  LogicalDate? defaultDate,
}) => showDialog<TaskDraft>(
  context: context,
  barrierColor: context.palette.scrim,
  builder: (_) =>
      _TaskFormDialog(today: today, initial: initial, defaultDate: defaultDate),
);

class _TaskFormDialog extends StatefulWidget {
  const _TaskFormDialog({required this.today, this.initial, this.defaultDate});

  final LogicalDate today;
  final TaskItem? initial;
  final LogicalDate? defaultDate;

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _note = TextEditingController(text: widget.initial?.note);
  late LogicalDate? _date = widget.initial == null
      ? widget.defaultDate
      : widget.initial!.date;
  late String? _time = widget.initial?.time;
  late TaskPriority _priority = widget.initial?.priority ?? TaskPriority.medium;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  TaskDraft get _draft => TaskDraft(
    title: _title.text,
    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    date: _date,
    time: _date == null ? null : _time,
    priority: _priority,
  );

  Future<void> _pickDate() async {
    final base = _date ?? widget.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(base.year, base.month, base.day),
      firstDate: DateTime(widget.today.year - 1),
      lastDate: DateTime(widget.today.year + 5, 12, 31),
    );
    if (picked == null) return;
    setState(() => _date = LogicalDate(picked.year, picked.month, picked.day));
  }

  Future<void> _pickTime() async {
    final parts = TaskItem(
      id: '',
      title: '',
      priority: _priority,
      order: 0,
      date: _date,
      time: _time,
    ).timeParts;
    final picked = await showReminderTimePicker(
      context: context,
      initialTime: parts == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: parts.$1, minute: parts.$2),
    );
    if (picked == null) return;
    setState(() {
      _time =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  void _submit() {
    final draft = _draft;
    if (!draft.isValid) return;
    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final editing = widget.initial != null;
    final tomorrow = widget.today.next;
    final isCustomDate =
        _date != null && _date != widget.today && _date != tomorrow;

    return AppFormDialog(
      key: const ValueKey('task-form-dialog'),
      hero: editing
          ? const AppDialogHero.cat(
              badge: PhosphorIconsBold.pencilSimple,
              color: AppColors.pink,
              asset: 'assets/images/edit.png',
            )
          : const AppDialogHero.icon(
              icon: PhosphorIconsFill.checkSquare,
              color: AppColors.pink,
            ),
      title: editing ? l10n.tasksEditTask : l10n.tasksNewTask,
      helper: l10n.tasksFormHelper,
      primaryLabel: l10n.tasksSave,
      primaryKey: const ValueKey('task-form-save'),
      onPrimary: _draft.isValid ? _submit : null,
      children: [
        AppTextField(
          key: const ValueKey('task-title-field'),
          controller: _title,
          label: l10n.tasksTitleLabel,
          prefixIcon: PhosphorIconsBold.textAa,
          maxLength: TaskDraft.maxTitleLength,
          autofocus: !editing,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _note,
          label: l10n.tasksNoteLabel,
          prefixIcon: PhosphorIconsBold.notePencil,
          maxLength: TaskDraft.maxNoteLength,
          maxLines: 3,
          minLines: 1,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        _FieldLabel(l10n.tasksDateLabel),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: Text(l10n.tasksToday),
              selected: _date == widget.today,
              onSelected: (_) => setState(() => _date = widget.today),
            ),
            ChoiceChip(
              label: Text(l10n.tasksTomorrow),
              selected: _date == tomorrow,
              onSelected: (_) => setState(() => _date = tomorrow),
            ),
            ChoiceChip(
              key: const ValueKey('task-pick-date'),
              avatar: const Icon(PhosphorIconsBold.calendarBlank, size: 16),
              label: Text(
                isCustomDate
                    ? taskDayLabel(l10n, locale, _date!, widget.today)
                    : l10n.tasksDatePick,
              ),
              selected: isCustomDate,
              onSelected: (_) => _pickDate(),
            ),
            ChoiceChip(
              label: Text(l10n.tasksDateNone),
              selected: _date == null,
              onSelected: (_) => setState(() {
                _date = null;
                _time = null;
              }),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _FieldLabel(l10n.tasksTimeLabel),
        if (_date == null)
          Text(
            l10n.tasksTimeNeedsDate,
            style: TextStyle(color: palette.textHint, fontSize: 12),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChoiceChip(
                key: const ValueKey('task-pick-time'),
                avatar: const Icon(PhosphorIconsBold.clock, size: 16),
                label: Text(_time ?? l10n.tasksDatePick),
                selected: _time != null,
                onSelected: (_) => _pickTime(),
              ),
              ChoiceChip(
                label: Text(l10n.tasksTimeNone),
                selected: _time == null,
                onSelected: (_) => setState(() => _time = null),
              ),
            ],
          ),
        const SizedBox(height: 14),
        _FieldLabel(l10n.tasksPriorityLabel),
        TaskPriorityPicker(
          selected: _priority,
          onSelected: (priority) => setState(() => _priority = priority),
        ),
      ],
    );
  }
}

class TaskPriorityPicker extends StatelessWidget {
  const TaskPriorityPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TaskPriority selected;
  final ValueChanged<TaskPriority> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    String label(TaskPriority priority) => switch (priority) {
      TaskPriority.low => l10n.tasksPriorityLow,
      TaskPriority.medium => l10n.tasksPriorityMedium,
      TaskPriority.high => l10n.tasksPriorityHigh,
      TaskPriority.urgent => l10n.tasksPriorityUrgent,
    };

    Color color(TaskPriority priority) => switch (priority) {
      TaskPriority.low => AppColors.green,
      TaskPriority.medium => const Color(0xFFE5B700),
      TaskPriority.high => AppColors.orange,
      TaskPriority.urgent => const Color(0xFFE5484D),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final priority in TaskPriority.values)
          ChoiceChip(
            key: ValueKey('task-priority-${priority.name}'),
            selected: selected == priority,
            onSelected: (_) => onSelected(priority),
            avatar: Icon(
              PhosphorIconsFill.flag,
              size: 15,
              color: selected == priority ? Colors.white : color(priority),
            ),
            label: Text(label(priority)),
            labelStyle: TextStyle(
              color: selected == priority ? Colors.white : color(priority),
              fontWeight: FontWeight.w800,
            ),
            backgroundColor: palette.tint(color(priority), .08),
            selectedColor: color(priority),
            side: BorderSide(color: color(priority).withValues(alpha: .22)),
          ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        color: context.palette.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    ),
  );
}
