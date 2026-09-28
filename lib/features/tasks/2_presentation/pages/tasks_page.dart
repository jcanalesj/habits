import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/2_presentation/notifications/reminder_permission.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/tasks/0_entity/entity.dart';
import 'package:habits/features/tasks/2_presentation/providers/tasks_providers.dart';
import 'package:habits/features/tasks/2_presentation/pages/task_form_page.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_date_label.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_form_dialog.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_rollover_sheet.dart';
import 'package:habits/features/tasks/2_presentation/widgets/task_tile.dart';
import 'package:habits/local_preferences.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';
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
    final result = await showTaskRolloverSheet(
      context,
      overdue: overdue,
      today: today,
    );
    if (result == null || result.tasks.isEmpty || !mounted) return;
    final repository = ref.read(tasksRepositoryProvider);
    if (result.action == TaskRolloverAction.delete) {
      for (final task in result.tasks) {
        await repository.delete(task.id);
      }
      if (!mounted) return;
      AppNotice.show(
        context,
        message: context.l10n.tasksRolloverDeleted(result.tasks.length),
        type: AppNoticeType.success,
      );
      return;
    }
    await repository.moveToDay(result.tasks, today);
    if (!mounted) return;
    AppNotice.show(
      context,
      message: context.l10n.tasksRolloverDone(result.tasks.length),
      type: AppNoticeType.success,
    );
  }

  Future<void> _create() async {
    final today = ref.read(todayProvider);
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TaskFormPage(
          today: today,
          defaultDate: _view == _TasksView.undated ? null : _day,
        ),
      ),
    );
    if (created != true || !mounted) return;
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

  String _plannerDateLabel(
    BuildContext context,
    LogicalDate day,
    LogicalDate today,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final date = DateTime.utc(day.year, day.month, day.day);
    final shortDate = DateFormat("d 'de' MMMM", locale).format(date);
    if (day == today) return '${context.l10n.tasksToday}, $shortDate';
    return DateFormat("EEEE, d 'de' MMMM", locale).format(date);
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
    final selectedPending = (pending.value ?? const <TaskItem>[])
        .where((task) => task.date == day)
        .length;

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
        _ => Column(
          children: [
            Expanded(
              child: ListView(
                key: const ValueKey('tasks-page'),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _PlannerCard(
                    dateLabel: _plannerDateLabel(context, day, today),
                    summary: l10n.tasksPendingWithCount(selectedPending),
                    day: day,
                    today: today,
                    markers: markers,
                    onSelected: (date) => setState(() {
                      _selectedDay = date;
                      _view = _TasksView.day;
                    }),
                  ),
                  const SizedBox(height: 16),
                  SegmentedPill<_TasksView>(
                    options: _TasksView.values,
                    selected: _view,
                    expand: true,
                    keyOf: (view) => ValueKey('tasks-view-${view.name}'),
                    labelOf: (view) => switch (view) {
                      _TasksView.day => l10n.tasksViewDay,
                      _TasksView.upcoming => l10n.tasksViewUpcoming,
                      _TasksView.undated => l10n.tasksViewUndated,
                    },
                    onSelected: (view) => setState(() => _view = view),
                  ),
                  const SizedBox(height: 24),
                  if (_view == _TasksView.day)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        taskDayLabel(
                          l10n,
                          Localizations.localeOf(context).toString(),
                          day,
                          today,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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
                  if (pending.isLoading) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: CircularProgressIndicator(color: palette.primary),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: GradientButton(
                  key: const ValueKey('tasks-new'),
                  label: l10n.tasksNewTask,
                  onPressed: _create,
                  trailingArrow: false,
                ),
              ),
            ),
          ],
        ),
      },
    );
  }
}

class _PlannerCard extends StatelessWidget {
  const _PlannerCard({
    required this.dateLabel,
    required this.summary,
    required this.day,
    required this.today,
    required this.markers,
    required this.onSelected,
  });

  final String dateLabel;
  final String summary;
  final LogicalDate day;
  final LogicalDate today;
  final Set<LogicalDate> markers;
  final ValueChanged<LogicalDate> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final compactViewport = MediaQuery.sizeOf(context).height < 700;
      final height = compactViewport
          ? 170.0
          : (width / 1.96).clamp(205.0, 460.0);
      final large = width >= 560 && !compactViewport;
      final calendarHeight = compactViewport ? 76.0 : (large ? 92.0 : 82.0);
      final outerInset = large ? 15.0 : 9.0;

      return Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.gradientEnd.withValues(alpha: .20),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // El PNG lleva aire transparente alrededor. Se compensa en cada
            // eje para eliminarlo sin aplicar un zoom que corte al gato o la
            // estantería en pantallas estrechas.
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(1.08, 1.24, 1),
              child: Image.asset(
                'assets/images/cards/tareas.png',
                fit: BoxFit.fill,
                alignment: Alignment.center,
              ),
            ),
            // Aclara únicamente la zona del título para conservar el paisaje
            // y asegurar contraste sobre cualquier recorte de pantalla.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, .48, .78],
                  colors: [
                    Color(0xD9FFF6EF),
                    Color(0x38FFF6EF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: large ? 40 : 22,
              top: compactViewport ? 16 : (large ? 40 : 22),
              right: large ? 220 : 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF211B1A),
                      fontSize: large ? 29 : 19,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: large ? 7 : 4),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF746E7D),
                      fontSize: large ? 20 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: outerInset,
              right: outerInset,
              bottom: outerInset,
              height: calendarHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF8F6).withValues(alpha: .88),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .72),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: large ? 12 : 6,
                        vertical: compactViewport ? 0 : (large ? 4 : 2),
                      ),
                      child: DayStrip(
                        selected: day,
                        today: today,
                        markers: markers,
                        inverted: true,
                        onSelected: onSelected,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
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
    super.key,
    required this.tasks,
    required this.today,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    this.initiallyExpanded = false,
  });

  final List<TaskItem> tasks;
  final LogicalDate today;
  final _TaskAction onToggle;
  final _TaskAction onTap;
  final _TaskAction onDelete;
  final bool initiallyExpanded;

  @override
  State<_CompletedSection> createState() => _CompletedSectionState();
}

class _CompletedSectionState extends State<_CompletedSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  void didUpdateWidget(covariant _CompletedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.initiallyExpanded && widget.initiallyExpanded) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    if (widget.tasks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: palette.tint(palette.primary, .06),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            key: const ValueKey('tasks-completed-toggle'),
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsFill.checkCircle,
                    size: 24,
                    color: palette.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${l10n.tasksCompletedSection} · ${widget.tasks.length}',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
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
        if (pending.isEmpty && completed.isEmpty)
          _TasksEmptyState(
            icon: PhosphorIconsFill.checkCircle,
            text: l10n.tasksEmptyDay,
            color: AppColors.green,
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
          key: ValueKey('tasks-completed-$day'),
          tasks: completed,
          today: today,
          onToggle: onToggle,
          onTap: onTap,
          onDelete: onDelete,
          initiallyExpanded: day.isBefore(today),
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
      return _TasksEmptyState(
        icon: PhosphorIconsFill.calendarBlank,
        text: l10n.tasksEmptyUpcoming,
        color: AppColors.orange,
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
          _TasksEmptyState(
            icon: PhosphorIconsFill.tray,
            text: l10n.tasksEmptyUndated,
            color: AppColors.lilac,
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

class _TasksEmptyState extends StatelessWidget {
  const _TasksEmptyState({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final surface = Color.alphaBlend(
      color.withValues(alpha: palette.isDark ? .14 : .055),
      palette.surface,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 22, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surface, palette.surface],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: .16)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: .18),
                  color.withValues(alpha: .08),
                ],
              ),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(icon, color: color, size: 29),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                height: 1.28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            PhosphorIconsFill.sparkle,
            size: 18,
            color: color.withValues(alpha: .68),
          ),
        ],
      ),
    );
  }
}
