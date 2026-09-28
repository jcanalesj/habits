import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';
import 'package:habits/features/steps/2_presentation/controllers/steps_controller.dart';
import 'package:habits/features/steps/2_presentation/providers/steps_providers.dart';
import 'package:habits/features/steps/2_presentation/widgets/steps_bars_chart.dart';
import 'package:habits/features/steps/2_presentation/widgets/steps_goal_celebration.dart';
import 'package:habits/features/steps/2_presentation/widgets/steps_history.dart';
import 'package:habits/features/steps/2_presentation/widgets/steps_month_calendar.dart';
import 'package:habits/local_preferences.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Podómetro de Constanza: contador nativo en vivo, estimaciones de
/// distancia y calorías, racha de objetivo, histórico completo y
/// felicitación al cumplir el objetivo diario.
class StepsPage extends ConsumerStatefulWidget {
  const StepsPage({super.key});

  @override
  ConsumerState<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends ConsumerState<StepsPage> {
  bool _consentPrompted = false;
  bool _celebrating = false;
  StepsRange _range = StepsRange.week;

  String get _locale => Localizations.localeOf(context).toString();
  NumberFormat get _number => NumberFormat.decimalPattern(_locale);

  Future<void> _askConsent() async {
    if (_consentPrompted) return;
    _consentPrompted = true;
    final l10n = context.l10n;
    final accepted = await showDialog<bool>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (context) => AppFormDialog(
        key: const ValueKey('steps-consent-dialog'),
        hero: const AppDialogHero.cat(
          badge: PhosphorIconsBold.footprints,
          color: AppColors.green,
        ),
        title: l10n.stepsConsentTitle,
        helper: l10n.stepsConsentBody,
        primaryLabel: l10n.stepsConsentAccept,
        primaryIcon: PhosphorIconsBold.footprints,
        primaryKey: const ValueKey('steps-consent-accept'),
        onPrimary: () => Navigator.pop(context, true),
        secondaryLabel: l10n.stepsConsentLater,
        onSecondary: () => Navigator.pop(context, false),
      ),
    );
    if (accepted != true || !mounted) return;
    await ref.read(stepsControllerProvider.notifier).consent();
  }

  Future<void> _changeGoal(StepsConfig config) async {
    final l10n = context.l10n;
    final goal = await showDialog<int>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (_) => _GoalDialog(initial: config.goal),
    );
    if (goal == null || !mounted) return;
    final next = config.copyWith(goal: goal);
    await ref.read(stepsRepositoryProvider).saveConfig(next);
    ref.read(stepsControllerProvider.notifier).applyConfig(next);
    if (!mounted) return;
    AppNotice.show(
      context,
      message: l10n.stepsGoalSaved,
      type: AppNoticeType.success,
    );
  }

  /// Felicitación una vez al día al alcanzar el objetivo.
  Future<void> _maybeCelebrate(StepsState state) async {
    if (!state.goalReached || _celebrating) return;
    final userId = ref.read(authControllerProvider).value?.id ?? 'anonymous';
    final prefs = ref.read(sharedPreferencesProvider);
    final key = stepsCelebratedKey(userId);
    if (prefs?.getString(key) == state.today.key) return;
    await prefs?.setString(key, state.today.key);
    if (!mounted) return;
    _celebrating = true;
    await showStepsGoalCelebration(
      context,
      formattedSteps: _number.format(state.todaySteps),
    );
    _celebrating = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final state = ref.watch(stepsControllerProvider);
    final controller = ref.read(stepsControllerProvider.notifier);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    ref.listen(stepsControllerProvider, (previous, next) {
      if (next.status == StepsStatus.needsConsent) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _askConsent());
      } else if (next.status == StepsStatus.counting &&
          next.goalReached &&
          !(previous?.goalReached ?? false)) {
        _maybeCelebrate(next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.stepsTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            key: const ValueKey('steps-refresh'),
            tooltip: l10n.stepsRefresh,
            onPressed: controller.refresh,
            icon: const Icon(PhosphorIconsBold.arrowsClockwise),
          ),
        ],
      ),
      body: ListView(
        key: const ValueKey('steps-page'),
        padding: EdgeInsets.fromLTRB(20, 8, 20, 40 + bottomInset),
        children: [
          switch (state.status) {
            StepsStatus.needsConsent => _StatusBlock(
              key: const ValueKey('steps-needs-consent'),
              icon: PhosphorIconsFill.footprints,
              title: l10n.stepsConsentTitle,
              body: l10n.stepsConsentBody,
              action: l10n.stepsConsentAccept,
              onAction: () {
                _consentPrompted = false;
                _askConsent();
              },
            ),
            StepsStatus.noPermission => _StatusBlock(
              key: const ValueKey('steps-no-permission'),
              icon: PhosphorIconsFill.lockKey,
              title: l10n.stepsNoPermissionTitle,
              body: l10n.stepsNoPermissionBody,
              action: l10n.stepsGrantPermission,
              onAction: controller.requestPermission,
            ),
            StepsStatus.unavailable => _StatusBlock(
              key: const ValueKey('steps-unavailable'),
              icon: PhosphorIconsFill.warningCircle,
              title: l10n.stepsUnavailableTitle,
              body: l10n.stepsUnavailableBody,
              action: l10n.stepsRefresh,
              onAction: controller.refresh,
            ),
            StepsStatus.loading => Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(color: palette.primary),
              ),
            ),
            StepsStatus.counting => _TodayBlock(
              state: state,
              number: _number,
              onChangeGoal: () => _changeGoal(state.config),
            ),
          },
          const SizedBox(height: 18),
          _HistoryCard(
            range: _range,
            goal: state.config.goal,
            today: state.today,
            todaySteps: state.todaySteps,
            onRangeSelected: (range) => setState(() => _range = range),
          ),
          if (state.status == StepsStatus.counting) ...[
            const SizedBox(height: 12),
            Text(
              l10n.stepsSensorNote,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textHint, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- estados

class _StatusBlock extends StatelessWidget {
  const _StatusBlock({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      decoration: surfaceDecoration(palette),
      child: Column(
        children: [
          Icon(icon, color: AppColors.green, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ hoy

class _TodayBlock extends ConsumerWidget {
  const _TodayBlock({
    required this.state,
    required this.number,
    required this.onChangeGoal,
  });

  final StepsState state;
  final NumberFormat number;
  final VoidCallback onChangeGoal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final body = ref.watch(stepsBodyProvider);
    final week =
        ref.watch(stepsHistoryProvider(StepsRange.week)).value ?? const [];
    final distance =
        state.todayDistanceMeters ??
        StepsEstimator.distanceMeters(
          state.todaySteps,
          heightCm: body.heightCm,
        );
    final calories = StepsEstimator.calories(distance, weightKg: body.weightKg);
    final streak = StepsHistorySummary.goalStreak(
      [
        for (final day in week)
          if (day.day != state.today) day,
        StepsDay(day: state.today, steps: state.todaySteps),
      ],
      state.config.goal,
      state.today,
    );
    final chartDays = [
      for (final day in week)
        if (day.day != state.today) day,
      StepsDay(day: state.today, steps: state.todaySteps),
    ];
    final monday = state.today.addDays(-(state.today.weekday - 1));
    final stepsByDay = {for (final day in chartDays) day.day: day.steps};
    final weekdayLabels = Localizations.localeOf(context).languageCode == 'es'
        ? const ['L', 'M', 'X', 'J', 'V', 'S', 'D']
        : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final calendarWeekDays = [
      for (var index = 0; index < 7; index++)
        StepsDay(
          day: monday.addDays(index),
          steps: stepsByDay[monday.addDays(index)] ?? 0,
        ),
    ];
    final weekSummary = StepsHistorySummary.of(
      calendarWeekDays,
      state.config.goal,
    );
    final weekBars = [
      for (final (index, day) in calendarWeekDays.indexed)
        StepsBar(
          label: weekdayLabels[index],
          steps: day.steps,
          reached: day.steps >= state.config.goal,
          emphasized: day.day == state.today,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepsHeroCard(
          state: state,
          number: number,
          onChangeGoal: onChangeGoal,
        ),
        const SizedBox(height: 20),
        Text(
          Localizations.localeOf(context).languageCode == 'es'
              ? 'Resumen'
              : 'Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                icon: PhosphorIconsFill.mapPin,
                color: AppColors.primary,
                label: l10n.stepsDistanceLabel,
                value: l10n.stepsDistanceKm(
                  NumberFormat('0.0', locale).format(distance / 1000),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryMetric(
                icon: PhosphorIconsFill.fire,
                color: AppColors.pink,
                label: l10n.stepsCaloriesLabel,
                value: l10n.stepsCaloriesKcal(number.format(calories)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryMetric(
                icon: PhosphorIconsFill.trophy,
                color: AppColors.orange,
                label: Localizations.localeOf(context).languageCode == 'es'
                    ? 'Racha'
                    : 'Streak',
                value: l10n.stepsStreakDaysWithCount(streak),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: surfaceDecoration(palette),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.stepsWeekTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              StepsBarsChart(bars: weekBars, goal: state.config.goal),
              const SizedBox(height: 14),
              Divider(color: palette.divider),
              const SizedBox(height: 4),
              Text(
                l10n.stepsDailyAverageLabel,
                style: TextStyle(color: palette.textSecondary),
              ),
              Text(
                '${number.format(weekSummary.dailyAverage)} ${l10n.stepsStepsWithCount('').trim()}',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepsHeroCard extends StatelessWidget {
  const _StepsHeroCard({
    required this.state,
    required this.number,
    required this.onChangeGoal,
  });

  final StepsState state;
  final NumberFormat number;
  final VoidCallback onChangeGoal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AspectRatio(
      aspectRatio: 1.68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // La ilustración trae unos pocos píxeles oscuros alrededor del
            // borde redondeado. Este pequeño zoom los deja fuera del recorte
            // de la card sin alterar de forma perceptible la composición.
            Transform.scale(
              scale: 1.06,
              child: Image.asset(
                'assets/images/cards/pasos.png',
                fit: BoxFit.cover,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7041E8).withValues(alpha: .78),
                    const Color(0xFF7041E8).withValues(alpha: .12),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tasksToday,
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        const Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            number.format(state.todaySteps),
                            key: const ValueKey('steps-today'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              height: .95,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.goalReached
                              ? l10n.stepsGoalReached
                              : l10n.stepsOfGoal(
                                  number.format(state.config.goal),
                                ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.goalReached
                              ? l10n.stepsGoalReached
                              : l10n.stepsRemainingWithCount(state.remaining),
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          key: const ValueKey('steps-change-goal'),
                          onPressed: onChangeGoal,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: .94,
                            ),
                            foregroundColor: AppColors.primaryDeep,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(
                            PhosphorIconsBold.pencilSimple,
                            size: 17,
                          ),
                          label: Text(l10n.stepsChangeGoal),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: const Alignment(.25, -.35),
                      child: ProgressRing(
                        progress: state.progress,
                        size: 128,
                        color: Colors.white,
                        semanticLabel: l10n.stepsTitle,
                        child: const Icon(
                          PhosphorIconsFill.footprints,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 78,
      padding: const EdgeInsets.all(10),
      decoration: surfaceDecoration(palette, radius: 18),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 50,
            decoration: BoxDecoration(
              color: palette.tint(color, .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 10),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ histórico

class _HistoryCard extends ConsumerStatefulWidget {
  const _HistoryCard({
    required this.range,
    required this.goal,
    required this.today,
    required this.todaySteps,
    required this.onRangeSelected,
  });

  final StepsRange range;
  final int goal;
  final LogicalDate today;
  final int todaySteps;
  final ValueChanged<StepsRange> onRangeSelected;

  @override
  ConsumerState<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends ConsumerState<_HistoryCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final number = NumberFormat.decimalPattern(locale);
    final body = ref.watch(stepsBodyProvider);
    final allStored =
        ref.watch(stepsHistoryProvider(StepsRange.all)).value ?? const [];
    final currentMonth = DateTime.utc(widget.today.year, widget.today.month);
    final stored = allStored
        .where(
          (day) =>
              day.day.year == widget.today.year &&
              day.day.month == widget.today.month,
        )
        .toList();
    // "Desde el…" siempre es el primer día guardado, sea cual sea el rango.
    final firstEver = allStored
        .map((day) => day.day)
        .fold<LogicalDate?>(
          null,
          (first, day) => first == null || day.isBefore(first) ? day : first,
        );
    // Hoy se muestra con el contador en vivo aunque aún no esté guardado.
    final days = [
      for (final day in stored)
        if (day.day != widget.today) day,
      if (widget.todaySteps > 0 || stored.any((day) => day.day == widget.today))
        StepsDay(day: widget.today, steps: widget.todaySteps),
    ];
    final summary = StepsHistorySummary.of(days, widget.goal);
    final distance = days.fold(
      0,
      (sum, day) =>
          sum +
          (day.distanceMeters ??
              StepsEstimator.distanceMeters(
                day.steps,
                heightCm: body.heightCm,
              )),
    );
    final calories = StepsEstimator.calories(distance, weightKg: body.weightKg);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: surfaceDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.stepsHistoryTitle,
                  style: textTheme.titleLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('steps-calendar-more'),
                onPressed: () => context.push('/tools/steps/calendar'),
                child: Text(
                  Localizations.localeOf(context).languageCode == 'es'
                      ? 'Más'
                      : 'More',
                ),
              ),
            ],
          ),
          if (firstEver != null) ...[
            const SizedBox(height: 2),
            Text(
              l10n.stepsSinceLabel(
                DateFormat.yMMMd(locale).format(
                  DateTime.utc(firstEver.year, firstEver.month, firstEver.day),
                ),
              ),
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          StepsMonthCalendar(
            month: currentMonth,
            days: days,
            goal: widget.goal,
            locale: locale,
          ),
          const SizedBox(height: 16),
          if (days.isNotEmpty) ...[
            const SizedBox(height: 16),
            _StatsGrid(
              items: [
                (
                  PhosphorIconsFill.footprints,
                  AppColors.primary,
                  l10n.stepsTotalLabel,
                  number.format(summary.totalSteps),
                ),
                (
                  PhosphorIconsFill.chartBar,
                  AppColors.primary,
                  l10n.stepsDailyAverageLabel,
                  number.format(summary.dailyAverage),
                ),
                (
                  PhosphorIconsFill.trophy,
                  AppColors.orange,
                  l10n.stepsBestDayLabel,
                  summary.bestDay == null
                      ? '—'
                      : number.format(summary.bestDay!.steps),
                ),
                (
                  PhosphorIconsFill.target,
                  AppColors.primary,
                  l10n.stepsGoalDaysLabel,
                  l10n.stepsGoalDaysValue(
                    summary.goalDays,
                    summary.daysWithData,
                  ),
                ),
                (
                  PhosphorIconsFill.mapPin,
                  AppColors.primary,
                  l10n.stepsDistanceTotalLabel,
                  l10n.stepsDistanceKm(
                    NumberFormat('0.0', locale).format(distance / 1000),
                  ),
                ),
                (
                  PhosphorIconsFill.fire,
                  AppColors.pink,
                  l10n.stepsCaloriesTotalLabel,
                  l10n.stepsCaloriesKcal(number.format(calories)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ListTitle(l10n.stepsRecentDays),
            for (final day in (days.reversed.take(10)))
              _HistoryRow(
                key: ValueKey('steps-day-${day.day.key}'),
                title: day.day == widget.today
                    ? l10n.tasksToday
                    : DateFormat.MMMEd(locale).format(
                        DateTime.utc(day.day.year, day.day.month, day.day.day),
                      ),
                value: l10n.stepsStepsWithCount(number.format(day.steps)),
                subtitle: _dayDistanceAndCalories(
                  day,
                  body: body,
                  locale: locale,
                  number: number,
                  l10n: l10n,
                ),
                reached: day.steps >= widget.goal,
              ),
          ],
        ],
      ),
    );
  }

  String _dayDistanceAndCalories(
    StepsDay day, {
    required ({double? heightCm, double? weightKg}) body,
    required String locale,
    required NumberFormat number,
    required AppLocalizations l10n,
  }) {
    final distance =
        day.distanceMeters ??
        StepsEstimator.distanceMeters(day.steps, heightCm: body.heightCm);
    final calories = StepsEstimator.calories(distance, weightKg: body.weightKg);
    return '${l10n.stepsDistanceKm(NumberFormat('0.0', locale).format(distance / 1000))}  ·  '
        '${l10n.stepsCaloriesKcal(number.format(calories))}';
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});
  final List<(IconData icon, Color color, String label, String value)> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) => Column(
        children: [
          for (var row = 0; row < (items.length / 3).ceil(); row++) ...[
            if (row > 0) const SizedBox(height: 10),
            Row(
              children: [
                for (var column = 0; column < 3; column++) ...[
                  if (column > 0) const SizedBox(width: 10),
                  Expanded(
                    child: row * 3 + column < items.length
                        ? _ProgressMetricCard(item: items[row * 3 + column])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressMetricCard extends StatelessWidget {
  const _ProgressMetricCard({required this.item});

  final (IconData icon, Color color, String label, String value) item;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, color, label, value) = item;
    return Container(
      height: 86,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 48,
            decoration: BoxDecoration(
              color: palette.tint(color, .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 9),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTitle extends StatelessWidget {
  const _ListTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        color: context.palette.textSecondary,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    ),
  );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    super.key,
    required this.title,
    required this.value,
    required this.reached,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsFill.footprints,
              size: 21,
              color: palette.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title[0].toUpperCase() + title.substring(1),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
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

// ------------------------------------------------------------- objetivo

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.initial});
  final int initial;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late int _goal = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    );
    return AppFormDialog(
      key: const ValueKey('steps-goal-dialog'),
      hero: const AppDialogHero.icon(
        icon: PhosphorIconsFill.target,
        color: AppColors.green,
      ),
      title: l10n.stepsGoalTitle,
      helper: l10n.stepsGoalHelper,
      primaryLabel: l10n.stepsGoalSave,
      primaryKey: const ValueKey('steps-goal-save'),
      onPrimary: () => Navigator.pop(context, _goal),
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              key: const ValueKey('steps-goal-minus'),
              onPressed: _goal - StepsConfig.goalStep >= StepsConfig.minGoal
                  ? () => setState(() => _goal -= StepsConfig.goalStep)
                  : null,
              icon: const Icon(PhosphorIconsBold.minus),
            ),
            Expanded(
              child: Text(
                number.format(_goal),
                key: const ValueKey('steps-goal-value'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton.filledTonal(
              key: const ValueKey('steps-goal-plus'),
              onPressed: _goal + StepsConfig.goalStep <= StepsConfig.maxGoal
                  ? () => setState(() => _goal += StepsConfig.goalStep)
                  : null,
              icon: const Icon(PhosphorIconsBold.plus),
            ),
          ],
        ),
      ],
    );
  }
}
