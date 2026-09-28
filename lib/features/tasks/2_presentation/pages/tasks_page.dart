import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/2_presentation/notifications/reminder_permission.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/2_presentation/providers/tasks_providers.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_date_label.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_form_dialog.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_rollover_sheet.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_tile.dart';
import 'package:habits/local_preferences.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

enum _TasksView { day, upcoming, undated }

/// Tareas: tira de días, vistas Día / Próximas / Sin fecha, arrastre de las
/// atrasadas y formulario en diálogo.
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  _TasksView _view = _TasksView.day;
  LogicalDate? _selectedDay;
  bool _rolloverOffered = false;

  LogicalDate get _day => _selectedDay ?? ref.read(todayProvider);

  Future<void> _maybeOfferRollover(List<TaskItem> overdue) async {
    if (_rolloverOffered || overdue.isEmpty) return;
    _rolloverOffered = true;
    final today = ref.read(todayProvider);
    final userId = ref.read(authControllerProvider).value?.id ?? 'anonymous';
    final prefs = ref.read(sharedPreferencesProvider);
    final key = tasksRolloverAskedKey(userId);
    if (prefs?.getString(key) == today.key) return;
    await prefs?.setString(key, today.key);
    if (!mounted) return;
    final chosen = await showTaskRolloverSheet(
      context,
      overdue: overdue,
      today: today,
    );
    if (chosen == null || chosen.isEmpty || !mounted) return;
    await ref.read(tasksRepositoryProvider).moveToDay(chosen, today);
    if (!mounted) return;
    AppNotice.show(
      context,
      message: context.l10n.tasksRolloverDone(chosen.length),
      type: AppNoticeType.success,
    );
  }

  Future<void> _create() async {
    final today = ref.read(todayProvider);
    final draft = await showTaskFormDialog(
      context,
      today: today,
      defaultDate: _view == _TasksView.undated ? null : _day,
    );
    if (draft == null || !mounted) return;
    try {
      await ref.read(tasksRepositoryProvider).create(draft);
    } catch (_) {
      if (!mounted) return;
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
    AppNotice.show(
      context,
      message: context.l10n.tasksCreated,
      type: AppNoticeType.success,
    );
  }

  Future<void> _edit(TaskItem task) async {
    final today = ref.read(todayProvider);
    final draft = await showTaskFormDialog(
      context,
      today: today,
      initial: task,
    );
    if (draft == null || !mounted) return;
    try {
      await ref.read(tasksRepositoryProvider).update(task.id, draft);
    } catch (_) {
      if (!mounted) return;
      AppNotice.show(
        context,
        message: context.l10n.tasksSaveError,
        type: AppNoticeType.error,
      );
      return;
    }
    if (!mounted) return;
    if (draft.time != null) await ensureReminderPermission(context, ref);
  }

  Future<void> _delete(TaskItem task) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: l10n.tasksDeleteTitle,
      body: l10n.tasksDeleteBody,
    );
    if (!confirmed || !mounted) return;
    await ref.read(tasksRepositoryProvider).delete(task.id);
    if (!mounted) return;
    AppNotice.show(context, message: l10n.tasksDeleted);
  }

  void _toggle(TaskItem task) {
    ref.read(tasksRepositoryProvider).setCompleted(task.id, !task.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final today = ref.watch(todayProvider);
    final day = _selectedDay ?? today;
    final pending = ref.watch(pendingTasksProvider);

    // Recordatorios de tareas: cada cambio en las pendientes reprograma.
    ref.listen(pendingTasksProvider, (_, next) {
      final tasks = next.value;
      if (tasks == null) return;
      ref
          .read(taskReminderSyncerProvider)
          .sync(
            tasks,
            calendar: ref.read(logicalCalendarProvider),
            title: l10n.tasksReminderTitle,
          );
    });
    ref.listen(overdueTasksProvider, (_, overdue) {
      if (pending.hasValue) _maybeOfferRollover(overdue);
    });
    if (pending.hasValue && !_rolloverOffered) {
      final overdue = ref.read(overdueTasksProvider);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeOfferRollover(overdue),
      );
    }

    final markers = {
      for (final task in pending.value ?? const <TaskItem>[]) ?task.date,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tasksTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: switch (pending) {
        AsyncError(:final error) => AppErrorView(
          error: error,
          onRetry: () => ref.invalidate(pendingTasksProvider),
        ),
        _ => ListView(
          key: const ValueKey('tasks-page'),
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            40 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            DayStrip(
              selected: day,
              today: today,
              markers: markers,
              onSelected: (date) => setState(() {
                _selectedDay = date;
                _view = _TasksView.day;
              }),
            ),
            const SizedBox(height: 12),
            SegmentedPill<_TasksView>(
              options: _TasksView.values,
              selected: _view,
              expand: true,
              keyOf: (view) => ValueKey('tasks-view-${view.name}'),
              labelOf: (view) => switch (view) {
                _TasksView.day =>
                  _selectedDay == null || day == today
                      ? l10n.tasksViewDay
                      : taskDayLabel(
                          l10n,
                          Localizations.localeOf(context).toString(),
                          day,
                          today,
                        ),
                _TasksView.upcoming => l10n.tasksViewUpcoming,
                _TasksView.undated => l10n.tasksViewUndated,
              },
              onSelected: (view) => setState(() => _view = view),
            ),
            const SizedBox(height: 16),
            switch (_view) {
              _TasksView.day => _DayView(
                day: day,
                today: today,
                onToggle: _toggle,
                onTap: _edit,
                onDelete: _delete,
              ),
              _TasksView.upcoming => _UpcomingView(
                pending: pending.value ?? const [],
                today: today,
                onToggle: _toggle,
                onTap: _edit,
                onDelete: _delete,
              ),
              _TasksView.undated => _UndatedView(
                today: today,
                onToggle: _toggle,
                onTap: _edit,
                onDelete: _delete,
              ),
            },
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const ValueKey('tasks-new'),
              onPressed: _create,
              icon: const Icon(PhosphorIconsBold.plus),
              label: Text(l10n.tasksNewTask),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (pending.isLoading) ...[
              const SizedBox(height: 24),
              Center(child: CircularProgressIndicator(color: palette.primary)),
            ],
          ],
        ),
      },
    );
  }
}

typedef _TaskAction = void Function(TaskItem task);

/// Tarjeta con una lista de filas separadas por divisores.
class _TaskListCard extends StatelessWidget {
  const _TaskListCard({
    required this.tasks,
    required this.today,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final List<TaskItem> tasks;
  final LogicalDate today;
  final _TaskAction onToggle;
  final _TaskAction onTap;
  final _TaskAction onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: surfaceDecoration(palette),
      child: Column(
        children: [
          for (final (index, task) in tasks.indexed) ...[
            if (index > 0)
              Divider(height: 1, indent: 56, color: palette.divider),
            Dismissible(
              key: ValueKey('task-${task.id}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                onDelete(task);
                // El borrado real lo decide el diálogo; la fila no se
                // desliza fuera hasta que Firestore la quita de la lista.
                return false;
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                color: dangerColor.withValues(alpha: .12),
                child: const Icon(PhosphorIconsBold.trash, color: dangerColor),
              ),
              child: TaskTile(
                task: task,
                today: today,
                onToggle: () => onToggle(task),
                onTap: () => onTap(task),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompletedSection extends StatefulWidget {
  const _CompletedSection({
    required this.tasks,
    required this.today,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final List<TaskItem> tasks;
  final LogicalDate today;
  final _TaskAction onToggle;
  final _TaskAction onTap;
  final _TaskAction onDelete;

  @override
  State<_CompletedSection> createState() => _CompletedSectionState();
}

class _CompletedSectionState extends State<_CompletedSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    if (widget.tasks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        InkWell(
          key: const ValueKey('tasks-completed-toggle'),
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Text(
                  '${l10n.tasksCompletedSection} · ${widget.tasks.length}',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? PhosphorIconsBold.caretUp
                      : PhosphorIconsBold.caretDown,
                  size: 16,
                  color: palette.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 6),
          _TaskListCard(
            tasks: widget.tasks,
            today: widget.today,
            onToggle: widget.onToggle,
            onTap: widget.onTap,
            onDelete: widget.onDelete,
          ),
        ],
      ],
    );
  }
}

class _DayView extends ConsumerWidget {
  const _DayView({
    required this.day,
    required this.today,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final LogicalDate day;
  final LogicalDate today;
  final _TaskAction onToggle;
  final _TaskAction onTap;
  final _TaskAction onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tasks = ref.watch(tasksByDayProvider(day)).value ?? const [];
    final pending = tasks.where((task) => !task.isCompleted).toList();
    final completed = tasks.where((task) => task.isCompleted).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pending.isEmpty)
          EmptyStateBlock(
            icon: PhosphorIconsRegular.checkSquare,
            text: l10n.tasksEmptyDay,
            color: AppColors.pink,
          )
        else
          _TaskListCard(
            tasks: pending,
            today: today,
            onToggle: onToggle,
            onTap: onTap,
            onDelete: onDelete,
          ),
        _CompletedSection(
          tasks: completed,
          today: today,
          onToggle: onToggle,
          onTap: onTap,
          onDelete: onDelete,
        ),
      ],
    );
  }
}

class _UpcomingView extends StatelessWidget {
  const _UpcomingView({
    required this.pending,
    required this.today,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final List<TaskItem> pending;
  final LogicalDate today;
  final _TaskAction onToggle;
  final _TaskAction onTap;
  final _TaskAction onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final upcoming =
        [
          for (final task in pending)
            if (task.date case final date? when date.isAfter(today)) task,
        ]..sort((a, b) {
          final byDate = a.date!.compareTo(b.date!);
          return byDate != 0 ? byDate : compareTasks(a, b);
        });
    if (upcoming.isEmpty) {
      return EmptyStateBlock(
        icon: PhosphorIconsRegular.calendarBlank,
        text: l10n.tasksEmptyUpcoming,
        color: AppColors.pink,
      );
    }
    final groups = <LogicalDate, List<TaskItem>>{};
    for (final task in upcoming) {
      groups.putIfAbsent(task.date!, () => []).add(task);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              taskDayLabel(l10n, locale, entry.key, today),
              style: TextStyle(
                color: palette.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          _TaskListCard(
            tasks: entry.value,
            today: today,
            onToggle: onToggle,
            onTap: onTap,
            onDelete: onDelete,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _UndatedView extends ConsumerWidget {
  const _UndatedView({
    required this.today,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final LogicalDate today;
  final _TaskAction onToggle;
  final _TaskAction onTap;
  final _TaskAction onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tasks = ref.watch(undatedTasksProvider).value ?? const [];
    final pending = tasks.where((task) => !task.isCompleted).toList();
    final completed = tasks.where((task) => task.isCompleted).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pending.isEmpty)
          EmptyStateBlock(
            icon: PhosphorIconsRegular.tray,
            text: l10n.tasksEmptyUndated,
            color: AppColors.pink,
          )
        else
          _TaskListCard(
            tasks: pending,
            today: today,
            onToggle: onToggle,
            onTap: onTap,
            onDelete: onDelete,
          ),
        _CompletedSection(
          tasks: completed,
          today: today,
          onToggle: onToggle,
          onTap: onTap,
          onDelete: onDelete,
        ),
      ],
    );
  }
}
