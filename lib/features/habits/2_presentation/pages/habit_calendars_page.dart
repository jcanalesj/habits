import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/2_presentation/controllers/home_controller.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Historial mensual de todos los hábitos activos.
class HabitCalendarsPage extends ConsumerStatefulWidget {
  const HabitCalendarsPage({super.key, this.isHabitsTab = false});

  static const double bottomBarClearance = 120;

  final bool isHabitsTab;

  @override
  ConsumerState<HabitCalendarsPage> createState() => _HabitCalendarsPageState();
}

class _HabitCalendarsPageState extends ConsumerState<HabitCalendarsPage> {
  LogicalDate? _selectedMonth;

  LogicalDate _monthFor(LogicalDate today) =>
      _selectedMonth ?? LogicalDate(today.year, today.month, 1);

  void _changeMonth(LogicalDate current, int delta) {
    setState(() {
      _selectedMonth = LogicalDate.normalized(
        current.year,
        current.month + delta,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: widget.isHabitsTab
          ? null
          : AppBar(
              title: Text(
                context.l10n.habitCalendarsTitle,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              backgroundColor: context.palette.background,
              surfaceTintColor: Colors.transparent,
            ),
      body: SafeArea(
        bottom: false,
        child: switch (summaryAsync) {
          AsyncData(:final value) => _buildContent(context, value),
          AsyncError(:final error) => Center(
            child: Text(context.l10n.somethingWentWrong('$error')),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeSummary summary) {
    final month = _monthFor(summary.today);
    final lastDay = DateTime.utc(month.year, month.month + 1, 0).day;
    final from = month;
    final to = LogicalDate(month.year, month.month, lastDay);
    final logs = ref.watch(habitsRepositoryProvider).watchLogsBetween(from, to);
    final palette = context.palette;

    return StreamBuilder<List<HabitLog>>(
      stream: logs,
      builder: (context, snapshot) {
        final monthLogs = snapshot.data;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            widget.isHabitsTab ? 16 : 8,
            20,
            widget.isHabitsTab ? HabitCalendarsPage.bottomBarClearance : 40,
          ),
          children: [
            if (widget.isHabitsTab) ...[
              Row(
                children: [
                  Expanded(
                    child: SectionHeader(title: context.l10n.allHabitsTitle),
                  ),
                  FilledButton.tonalIcon(
                    key: const ValueKey('edit-habits-action'),
                    onPressed: () => context.go('/habits/manage'),
                    style: FilledButton.styleFrom(
                      foregroundColor: palette.primary,
                      backgroundColor: palette.tint(palette.primary, .10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                    ),
                    icon: const Icon(PhosphorIconsBold.pencilSimple, size: 19),
                    label: Text(context.l10n.editHabitsAction),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            _MonthSelector(
              month: month,
              onPrevious: () => _changeMonth(month, -1),
              onNext: () => _changeMonth(month, 1),
            ),
            const SizedBox(height: 14),
            _CalendarLegend(
              completed: context.l10n.habitCalendarsCompleted,
              notCompleted: context.l10n.habitCalendarsNotCompleted,
            ),
            const SizedBox(height: 18),
            if (monthLogs == null)
              const Center(child: CircularProgressIndicator())
            else
              for (final habit in summary.habits) ...[
                _HabitMonthCard(
                  habit: habit,
                  month: month,
                  logs: monthLogs
                      .where((log) => log.habitId == habit.id && log.isActivity)
                      .toList(),
                ),
                const SizedBox(height: 14),
              ],
          ],
        );
      },
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final LogicalDate month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final label = MaterialLocalizations.of(
      context,
    ).formatMonthYear(DateTime(month.year, month.month));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('previous-calendar-month'),
            onPressed: onPrevious,
            icon: const Icon(PhosphorIconsBold.caretLeft),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            key: const ValueKey('next-calendar-month'),
            onPressed: onNext,
            icon: const Icon(PhosphorIconsBold.caretRight),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.completed, required this.notCompleted});

  final String completed;
  final String notCompleted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: palette.primary, label: completed),
        const SizedBox(width: 20),
        _LegendItem(
          color: palette.surfaceMuted,
          label: notCompleted,
          outlined: true,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.outlined = false,
  });

  final Color color;
  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: outlined
                ? Border.all(
                    color: context.palette.textSecondary.withValues(alpha: .35),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 7),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HabitMonthCard extends StatelessWidget {
  const _HabitMonthCard({
    required this.habit,
    required this.month,
    required this.logs,
  });

  final Habit habit;
  final LogicalDate month;
  final List<HabitLog> logs;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = Color(habit.colorValue);
    final completedDays = logs.map((log) => log.date.day).toSet();
    final dayCount = DateTime.utc(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime.utc(month.year, month.month).weekday;
    final cells = <int?>[
      ...List<int?>.filled(firstWeekday - 1, null),
      for (var day = 1; day <= dayCount; day++) day,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final weekdays = context.l10n.weekdayInitials.split(',');

    return Container(
      key: ValueKey('habit-calendar-${habit.id}'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: palette.isDark ? .22 : .10),
          palette.surface,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: palette.isDark ? 0.62 : 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: palette.isDark ? .28 : .16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: HabitIcon(
                  iconId: habit.iconId,
                  legacyEmoji: habit.emoji,
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  habit.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${completedDays.length}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 5),
              Icon(PhosphorIconsFill.checkCircle, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 7,
            crossAxisSpacing: 7,
            children: [
              for (final weekday in weekdays)
                Center(
                  child: Text(
                    weekday,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              for (final day in cells)
                if (day == null)
                  const SizedBox.shrink()
                else
                  _CalendarDay(
                    day: day,
                    completed: completedDays.contains(day),
                    color: color,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.completed,
    required this.color,
  });

  final int day;
  final bool completed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: ValueKey('calendar-day-$day-${completed ? 'done' : 'empty'}'),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: completed ? color : palette.surfaceMuted,
        shape: BoxShape.circle,
        border: completed
            ? null
            : Border.all(color: palette.textSecondary.withValues(alpha: 0.20)),
        boxShadow: completed
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: completed
          ? const Icon(PhosphorIconsBold.check, color: Colors.white, size: 15)
          : Text(
              '$day',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
