import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/2_presentation/notifications/reminder_permission.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/2_presentation/providers/tasks_providers.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_date_label.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_form_dialog.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Alta de una tarea en pantalla completa, siguiendo el patrón de
/// `HabitFormPage`. La edición permanece en diálogo porque es una acción
/// contextual sobre una tarea existente.
class TaskFormPage extends ConsumerStatefulWidget {
  const TaskFormPage({super.key, required this.today, this.defaultDate});

  final LogicalDate today;
  final LogicalDate? defaultDate;

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  late LogicalDate? _date = widget.defaultDate;
  String? _time;
  TaskPriority _priority = TaskPriority.medium;
  bool _saving = false;

  TaskDraft get _draft => TaskDraft(
    title: _title.text,
    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    date: _date,
    time: _date == null ? null : _time,
    priority: _priority,
  );

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

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

  Future<void> _save() async {
    final draft = _draft;
    if (!draft.isValid || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(tasksRepositoryProvider).create(draft);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppNotice.show(
        context,
        message: context.l10n.tasksSaveError,
        type: AppNoticeType.error,
      );
      return;
    }
    if (!mounted) return;
    if (draft.time != null) await ensureReminderPermission(context, ref);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final tomorrow = widget.today.next;
    final isCustomDate =
        _date != null && _date != widget.today && _date != tomorrow;

    return Scaffold(
      key: const ValueKey('task-form-page'),
      appBar: AppBar(
        title: Text(l10n.tasksNewTask),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            40 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(l10n.tasksTitleLabel),
                  AuthTextField(
                    key: const ValueKey('task-title-field'),
                    controller: _title,
                    hint: l10n.tasksTitleLabel,
                    icon: PhosphorIconsBold.textAa,
                    maxLength: TaskDraft.maxTitleLength,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _Label(l10n.tasksNoteLabel),
                  AuthTextField(
                    controller: _note,
                    hint: l10n.tasksNoteLabel,
                    icon: PhosphorIconsBold.notePencil,
                    maxLength: TaskDraft.maxNoteLength,
                    maxLines: 3,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(l10n.tasksDateLabel),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                        avatar: const Icon(
                          PhosphorIconsBold.calendarBlank,
                          size: 16,
                        ),
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
                  const SizedBox(height: 20),
                  _Label(l10n.tasksTimeLabel),
                  if (_date == null)
                    Text(
                      l10n.tasksTimeNeedsDate,
                      style: TextStyle(color: palette.textHint, fontSize: 12),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(l10n.tasksPriorityLabel),
                  TaskPriorityPicker(
                    selected: _priority,
                    onSelected: (value) => setState(() => _priority = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              key: const ValueKey('task-form-save'),
              label: l10n.tasksSave,
              isLoading: _saving,
              trailingArrow: false,
              onPressed: _draft.isValid ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: context.palette.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
