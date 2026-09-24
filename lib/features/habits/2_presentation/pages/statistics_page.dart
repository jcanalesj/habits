import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/app_bottom_nav_bar.dart';
import 'package:habits/components/habit_icon_catalog.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/2_presentation/controllers/home_controller.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

enum _StatsPeriod { week, month, year }

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key, this.standalone = false});

  final bool standalone;

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  _StatsPeriod _period = _StatsPeriod.week;

  (LogicalDate, LogicalDate) _range(LogicalDate today) => switch (_period) {
    _StatsPeriod.week => (
      today.addDays(1 - today.weekday),
      today.addDays(7 - today.weekday),
    ),
    _StatsPeriod.month => (
      LogicalDate(today.year, today.month, 1),
      LogicalDate(
        today.year,
        today.month,
        DateTime.utc(today.year, today.month + 1, 0).day,
      ),
    ),
    _StatsPeriod.year => (
      LogicalDate(today.year, 1, 1),
      LogicalDate(today.year, 12, 31),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: widget.standalone
          ? AppBar(
              key: const ValueKey('standalone-stats-app-bar'),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        top: !widget.standalone,
        bottom: false,
        child: switch (summary) {
          AsyncData(:final value) => Builder(
            builder: (context) {
              final (from, to) = _range(value.today);
              return StreamBuilder<List<HabitLog>>(
                stream: ref
                    .watch(habitsRepositoryProvider)
                    .watchLogsBetween(from, to),
                initialData: _period == _StatsPeriod.week
                    ? value.weekLogs
                    : null,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _StatisticsContent(
                    summary: value,
                    logs: snapshot.data!,
                    period: _period,
                    rangeStart: from,
                    standalone: widget.standalone,
                    onPeriodChanged: (period) =>
                        setState(() => _period = period),
                  );
                },
              );
            },
          ),
          AsyncError(:final error) => Center(
            child: Text(context.l10n.somethingWentWrong('$error')),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({
    required this.summary,
    required this.logs,
    required this.period,
    required this.rangeStart,
    required this.standalone,
    required this.onPeriodChanged,
  });

  final HomeSummary summary;
  final List<HabitLog> logs;
  final _StatsPeriod period;
  final LogicalDate rangeStart;
  final bool standalone;
  final ValueChanged<_StatsPeriod> onPeriodChanged;

  int get _elapsedDays => rangeStart.differenceInDays(summary.today) + 1;

  int _targetFor(Habit habit) {
    final periodicity = habit.periodicityOn(summary.today);
    return switch (periodicity.type) {
      PeriodicityType.daily => _elapsedDays,
      PeriodicityType.weekly => (_elapsedDays / 7).ceil() * periodicity.target,
      PeriodicityType.monthly => switch (period) {
        _StatsPeriod.year => summary.today.month * periodicity.target,
        _ => periodicity.target,
      },
      PeriodicityType.yearly => periodicity.target,
    };
  }

  int _completedFor(String habitId) =>
      logs.where((log) => log.habitId == habitId && log.isActivity).length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final totalCompleted = logs.where((log) => log.isActivity).length;
    final totalTarget = summary.habits.fold<int>(
      0,
      (sum, habit) => sum + _targetFor(habit),
    );
    final compliance = totalTarget == 0
        ? 0
        : ((totalCompleted / totalTarget) * 100).clamp(0, 100).round();
    final activeDays = logs
        .where((log) => log.isActivity)
        .map((log) => log.date)
        .toSet()
        .length;

    final bottomClearance = standalone
        ? 32.0 + MediaQuery.viewPaddingOf(context).bottom
        : AppBottomNavBar.contentClearance +
              MediaQuery.viewPaddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomClearance),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.navStats,
                maxLines: 1,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: AppDimensions.screenTitleFontSize,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _PeriodPicker(value: period, onChanged: onPeriodChanged),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          l10n.statsSubtitle,
          maxLines: 1,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 108,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    l10n.habitPendingEncouragement,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.primaryDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Image.asset(
                  'assets/images/cat.png',
                  key: const ValueKey('statistics-cat'),
                  height: 108,
                  fit: BoxFit.contain,
                  semanticLabel: 'Constanza',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _StreakSummary(streak: summary.streak),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: PhosphorIconsBold.target,
                color: AppColors.lilac,
                value: '$compliance%',
                label: l10n.statsCompliance,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: PhosphorIconsBold.checkCircle,
                color: AppColors.green,
                value: '$totalCompleted',
                label: l10n.statsCompletedRecords,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: PhosphorIconsBold.chartBar,
                color: AppColors.blue,
                value: '$activeDays',
                label: l10n.statsActiveDays,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: PhosphorIconsBold.shieldCheck,
                color: AppColors.orange,
                value: '${summary.wildcards.available}',
                label: l10n.statsProtectors,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (period == _StatsPeriod.week)
          _WeeklyChart(
            summary: summary,
            onCalendar: () => context.push('/habit-calendars'),
          )
        else
          _RangeChart(
            period: period,
            today: summary.today,
            logs: logs,
            onCalendar: () => context.push('/habit-calendars'),
          ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: l10n.statsHabits,
          action: l10n.seeAll,
          onTap: () => context.go('/habits/manage'),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: palette.isDark ? 1 : .72),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              for (final habit in summary.habits)
                _HabitProgressRow(
                  habit: habit,
                  completed: _completedFor(habit.id),
                  target: _targetFor(habit),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.value, required this.onChanged});

  final _StatsPeriod value;
  final ValueChanged<_StatsPeriod> onChanged;

  String _label(BuildContext context, _StatsPeriod period) => switch (period) {
    _StatsPeriod.week => context.l10n.statsThisWeek,
    _StatsPeriod.month => context.l10n.statsThisMonth,
    _StatsPeriod.year => context.l10n.statsThisYear,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return PopupMenuButton<_StatsPeriod>(
      key: const ValueKey('stats-period-picker'),
      initialValue: value,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) => [
        for (final period in _StatsPeriod.values)
          PopupMenuItem(value: period, child: Text(_label(context, period))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsBold.calendarDots,
              color: palette.primary,
              size: 20,
            ),
            const SizedBox(width: 7),
            Text(
              _label(context, value),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 5),
            Icon(PhosphorIconsBold.caretDown, color: palette.primary, size: 15),
          ],
        ),
      ),
    );
  }
}

class _StreakSummary extends StatelessWidget {
  const _StreakSummary({required this.streak});

  final StreakState streak;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: palette.isDark ? 1 : .78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.primary.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StreakMetric(
              emoji: '🔥',
              title: l10n.statsCurrentStreak,
              value: streak.displayStreak,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: palette.primary.withValues(alpha: .14),
          ),
          Expanded(
            child: _StreakMetric(
              emoji: '🏆',
              title: l10n.statsBestStreak,
              value: streak.bestStreak,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakMetric extends StatelessWidget {
  const _StreakMetric({
    required this.emoji,
    required this.title,
    required this.value,
  });

  final String emoji;
  final String title;
  final int value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  context.l10n.statsDayCount(value),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 132,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: palette.isDark ? 1 : .75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: palette.tint(color, .13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Expanded(
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 10,
                  height: 1.05,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChart extends StatelessWidget {
  const _RangeChart({
    required this.period,
    required this.today,
    required this.logs,
    required this.onCalendar,
  });

  final _StatsPeriod period;
  final LogicalDate today;
  final List<HabitLog> logs;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    final isMonth = period == _StatsPeriod.month;
    final bucketCount = isMonth
        ? DateTime.utc(today.year, today.month + 1, 0).day
        : 12;
    final counts = List<int>.generate(bucketCount, (index) {
      return logs.where((log) {
        if (!log.isActivity) return false;
        return isMonth
            ? log.date.day == index + 1
            : log.date.month == index + 1;
      }).length;
    });
    final maximum = math.max(1, counts.reduce(math.max));
    final monthFormat = DateFormat.MMM(
      Localizations.localeOf(context).toLanguageTag(),
    );

    final palette = context.palette;

    return Container(
      key: ValueKey('stats-${isMonth ? 'month' : 'year'}-chart'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 18),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: palette.isDark ? 1 : .82),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _SectionTitle(
            title: isMonth
                ? context.l10n.statsMonthlyProgress
                : context.l10n.statsYearlyProgress,
            action: context.l10n.statsSeeCalendar,
            onTap: onCalendar,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bucketCount,
              separatorBuilder: (_, _) => const SizedBox(width: 5),
              itemBuilder: (context, index) {
                final label = isMonth
                    ? '${index + 1}'
                    : monthFormat
                          .format(DateTime(today.year, index + 1))
                          .substring(0, 1)
                          .toUpperCase();
                final future = isMonth
                    ? index + 1 > today.day
                    : index + 1 > today.month;
                return SizedBox(
                  width: 38,
                  child: _DayBar(
                    label: label,
                    count: counts[index],
                    maximum: maximum,
                    isFuture: future,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends ConsumerStatefulWidget {
  const _WeeklyChart({required this.summary, required this.onCalendar});

  final HomeSummary summary;
  final VoidCallback onCalendar;

  @override
  ConsumerState<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends ConsumerState<_WeeklyChart> {
  static const _currentWeekPage = 10000;
  late final PageController _controller = PageController(
    initialPage: _currentWeekPage,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWeekStart = widget.summary.today.addDays(
      1 - widget.summary.today.weekday,
    );
    final repository = ref.watch(habitsRepositoryProvider);
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 18),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: palette.isDark ? 1 : .82),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _SectionTitle(
            title: context.l10n.statsWeeklyProgress,
            action: context.l10n.statsSeeCalendar,
            onTap: widget.onCalendar,
          ),
          SizedBox(
            height: 170,
            child: PageView.builder(
              key: const ValueKey('weekly-history-pages'),
              controller: _controller,
              itemCount: _currentWeekPage + 1,
              itemBuilder: (context, page) {
                final weekStart = currentWeekStart.addDays(
                  (page - _currentWeekPage) * 7,
                );
                return _WeekBarsPage(
                  weekStart: weekStart,
                  today: widget.summary.today,
                  logs: repository.watchLogsBetween(
                    weekStart,
                    weekStart.addDays(6),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBarsPage extends StatelessWidget {
  const _WeekBarsPage({
    required this.weekStart,
    required this.today,
    required this.logs,
  });

  final LogicalDate weekStart;
  final LogicalDate today;
  final Stream<List<HabitLog>> logs;

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.addDays(6);
    final material = MaterialLocalizations.of(context);
    final range =
        '${material.formatShortDate(DateTime(weekStart.year, weekStart.month, weekStart.day))}'
        ' – '
        '${material.formatShortDate(DateTime(weekEnd.year, weekEnd.month, weekEnd.day))}';

    return StreamBuilder<List<HabitLog>>(
      stream: logs,
      builder: (context, snapshot) {
        final weekLogs = snapshot.data ?? const <HabitLog>[];
        final counts = List<int>.generate(7, (index) {
          final day = weekStart.addDays(index);
          return weekLogs
              .where((log) => log.isActivity && log.date == day)
              .length;
        });
        final highestCount = math.max(1, counts.reduce(math.max));
        final maximum = math.max(10, (highestCount / 5).ceil() * 5);

        return Semantics(
          key: ValueKey('week-range-${weekStart.key}'),
          label: range,
          child: _WeeklyBarChart(
            counts: counts,
            maximum: maximum,
            labels: context.l10n.weekdayInitials.split(','),
            futureDays: List<bool>.generate(
              7,
              (index) => weekStart.addDays(index).isAfter(today),
            ),
          ),
        );
      },
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({
    required this.counts,
    required this.maximum,
    required this.labels,
    required this.futureDays,
  });

  final List<int> counts;
  final int maximum;
  final List<String> labels;
  final List<bool> futureDays;

  @override
  Widget build(BuildContext context) {
    const labelWidth = 28.0;
    const dayLabelHeight = 24.0;
    final axisLabelStyle = _axisLabelStyle(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.only(bottom: dayLabelHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$maximum', style: axisLabelStyle),
                  Text('${maximum ~/ 2}', style: axisLabelStyle),
                  Text('0', style: axisLabelStyle),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  bottom: dayLabelHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _ChartGridLine(),
                      _ChartGridLine(),
                      _ChartGridLine(solid: true),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var index = 0; index < 7; index++)
                      Expanded(
                        child: _WeeklyBar(
                          label: labels[index],
                          count: counts[index],
                          maximum: maximum,
                          outlined: futureDays[index],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle _axisLabelStyle(BuildContext context) => TextStyle(
  color: context.palette.textSecondary,
  fontSize: 11,
  fontWeight: FontWeight.w600,
);

class _ChartGridLine extends StatelessWidget {
  const _ChartGridLine({this.solid = false});

  final bool solid;

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: context.palette.primary.withValues(alpha: solid ? .14 : .08),
  );
}

class _WeeklyBar extends StatelessWidget {
  const _WeeklyBar({
    required this.label,
    required this.count,
    required this.maximum,
    required this.outlined,
  });

  final String label;
  final int count;
  final int maximum;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final ratio = (count / maximum).clamp(0.0, 1.0);
    final heightFactor = outlined ? .42 : math.max(.06, ratio);

    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: outlined
                  ? CustomPaint(
                      painter: _DashedRoundedBorderPainter(
                        color: context.palette.primary.withValues(alpha: .42),
                      ),
                      child: const SizedBox(width: 26),
                    )
                  : Container(
                      width: 26,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.gradientStart, AppColors.primary],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 17,
          child: Text(label, style: _axisLabelStyle(context)),
        ),
      ],
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(7)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dashLength = 4.0;
    const gapLength = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dashLength, metric.length),
          ),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.count,
    required this.maximum,
    required this.isFuture,
  });

  final String label;
  final int count;
  final int maximum;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final ratio = count / maximum;
    final palette = context.palette;
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: .24 + .76 * ratio,
              child: Container(
                width: 24,
                decoration: BoxDecoration(
                  gradient: isFuture || count == 0
                      ? null
                      : const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.primary, AppColors.gradientStart],
                        ),
                  color: isFuture || count == 0 ? palette.divider : null,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Icon(
          count > 0 ? PhosphorIconsFill.checkCircle : PhosphorIconsFill.circle,
          color: count > 0
              ? palette.primary
              : palette.textSecondary.withValues(alpha: .20),
          size: 18,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: AppDimensions.sectionTitleFontSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(PhosphorIconsBold.caretRight, size: 16),
          label: Text(action),
          iconAlignment: IconAlignment.end,
        ),
      ],
    );
  }
}

class _HabitProgressRow extends StatelessWidget {
  const _HabitProgressRow({
    required this.habit,
    required this.completed,
    required this.target,
  });

  final Habit habit;
  final int completed;
  final int target;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = Color(habit.colorValue);
    final fraction = target == 0 ? 0.0 : (completed / target).clamp(0.0, 1.0);
    final percent = (fraction * 100).round();

    return Padding(
      key: ValueKey('habit-stat-${habit.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.tint(color, .13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: HabitIcon(
              iconId: habit.iconId,
              legacyEmoji: habit.emoji,
              size: 30,
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    key: ValueKey('habit-stat-progress-${habit.id}'),
                    value: fraction,
                    minHeight: 7,
                    color: color,
                    backgroundColor: palette.divider,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$completed/$target',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
