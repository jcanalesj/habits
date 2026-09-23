import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/controllers/home_controller.dart';
import 'package:habits/features/habits/2_presentation/pages/habits_list_page.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeControllerProvider);
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (summaryAsync) {
          AsyncData(:final value) => _HomeContent(
            summary: value,
            greeting: WelcomeGreetingResolver.resolve(
              context.l10n,
              userName,
              DateTime.now().hour,
            ),
          ),
          AsyncError(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.somethingWentWrong('$error')),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

enum _HabitFilter { all, daily, weekly, monthly, yearly }

class _HomeContent extends ConsumerStatefulWidget {
  const _HomeContent({required this.summary, required this.greeting});

  final HomeSummary summary;
  final String greeting;

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  _HabitFilter _filter = _HabitFilter.all;
  bool _hideAllDone = false;
  int _habitCelebrationIndex = 0;
  int _dayCelebrationIndex = 0;
  late bool _showColdStartWelcome;
  late final int _welcomeMessageIndex;

  @override
  void initState() {
    super.initState();
    _showColdStartWelcome = ref
        .read(coldStartWelcomeSessionProvider)
        .take(enabled: ref.read(welcomeAnimationEnabledProvider));
    _welcomeMessageIndex = WelcomeMessageSelector.randomIndex();
  }

  HomeSummary get summary => widget.summary;

  /// Hábito con recordatorio hoy aún sin completar y con hora más próxima.
  Habit? get _nextReminderHabit {
    final pending = summary.habits.where((habit) {
      if (habit.reminderTime == null) return false;
      return !summary.isCompletedOn(habit.id, summary.today);
    }).toList()..sort((a, b) => a.reminderTime!.compareTo(b.reminderTime!));
    return pending.isEmpty ? null : pending.first;
  }

  Future<void> _useWildcard(BuildContext context, WidgetRef ref) async {
    final rescue = summary.streak.rescue;
    if (rescue == null) return;

    final confirmed = await WildcardRescueSheet.show(
      context,
      rescue: rescue,
      available: summary.wildcards.available,
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref
        .read(homeControllerProvider.notifier)
        .useWildcard();
    if (!context.mounted) return;

    final l10n = context.l10n;
    final message = switch (result) {
      UseWildcardSuccess() => l10n.wildcardUsed,
      UseWildcardFailed(:final failure) => switch (failure) {
        WildcardFailure.noneAvailable => l10n.wildcardErrorNone,
        WildcardFailure.rescueWindowClosed => l10n.wildcardErrorWindowClosed,
        WildcardFailure.requiresConnection => l10n.wildcardErrorConnection,
        _ => l10n.wildcardErrorGeneric,
      },
      null => null,
    };
    if (message == null) return;
    AppNotice.show(
      context,
      message: message,
      type: result is UseWildcardSuccess
          ? AppNoticeType.success
          : AppNoticeType.error,
    );
  }

  /// Hábitos que todavía no se han registrado hoy.
  List<Habit> get _pending => [
    for (final habit in summary.habits)
      if (!summary.isCompletedOn(habit.id, summary.today)) habit,
  ];

  /// Hábitos ya registrados hoy.
  List<Habit> get _completed => [
    for (final habit in summary.habits)
      if (summary.isCompletedOn(habit.id, summary.today)) habit,
  ];

  String _nextCelebrationMessage({required bool allDone}) {
    final l10n = context.l10n;
    final messages = allDone
        ? [
            l10n.allHabitsCompletedCelebration,
            l10n.allHabitsCompletedCelebration2,
            l10n.allHabitsCompletedCelebration3,
            l10n.allHabitsCompletedCelebration4,
          ]
        : [
            l10n.habitCompletedCelebration,
            l10n.habitCompletedCelebration2,
            l10n.habitCompletedCelebration3,
            l10n.habitCompletedCelebration4,
            l10n.habitCompletedCelebration5,
            l10n.habitCompletedCelebration6,
          ];
    final index = allDone ? _dayCelebrationIndex : _habitCelebrationIndex;
    if (allDone) {
      _dayCelebrationIndex = (index + 1) % messages.length;
    } else {
      _habitCelebrationIndex = (index + 1) % messages.length;
    }
    return messages[index];
  }

  Future<void> _toggleHabit(
    BuildContext context,
    HomeController controller,
    String habitId,
  ) async {
    final wasCompleted = summary.isCompletedOn(habitId, summary.today);
    final completesTheDay = !wasCompleted && _pending.length == 1;
    final result = await controller.toggleToday(habitId);
    if (!context.mounted || result is! ToggleHabitCompletionSuccess) return;

    // Desmarcar es una corrección, no un logro: solo celebramos al completar.
    if (wasCompleted) return;
    HabitCelebration.show(
      context,
      message: _nextCelebrationMessage(allDone: completesTheDay),
      allDone: completesTheDay,
    );
  }

  Future<void> _setRepetitionCount(
    BuildContext context,
    HomeController controller,
    Habit habit,
    int count,
  ) async {
    final previous = summary.completedCountOn(habit.id, summary.today);
    final historicalTarget = summary.weekLogs
        .where((log) => log.habitId == habit.id && log.date == summary.today)
        .firstOrNull
        ?.targetCount;
    final target = historicalTarget ?? habit.targetCount;
    final completesHabit = previous < target && count >= target;
    final completesTheDay = completesHabit && _pending.length == 1;
    final saved = await controller.setTodayCount(habit.id, count);
    if (!saved || !context.mounted || !completesHabit) return;
    HabitCelebration.show(
      context,
      message: _nextCelebrationMessage(allDone: completesTheDay),
      allDone: completesTheDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(homeControllerProvider.notifier);
    final nextReminder = _nextReminderHabit;
    final pending = _pending.where(_matchesFilter).toList();
    final completed = _completed.where(_matchesFilter).toList();
    final hasHabits = summary.habits.isNotEmpty;
    final bottomClearance =
        AppBottomNavBar.contentClearance +
        MediaQuery.viewPaddingOf(context).bottom;

    final home = ListView(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomClearance),
      children: [
        HomeHeader(
          greeting: widget.greeting,
          onAvatarTap: () => context.go('/profile'),
        ),
        const SizedBox(height: 16),
        // Única racha de la app: la general del usuario. Ya no hay rachas
        // por ámbito ni por hábito (§1/§29).
        GeneralStreakCard(
          streak: summary.streak,
          wildcards: summary.wildcards,
          deviceHour: DateTime.now().hour,
          onUseWildcard: summary.streak.canRescue && summary.wildcards.hasAny
              ? () => _useWildcard(context, ref)
              : null,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: SectionHeader(title: l10n.myHabits)),
            FilledButton.tonalIcon(
              key: const ValueKey('home-new-habit'),
              onPressed: () => HabitsListPage.openCreateHabit(
                context,
                activeHabitCount: summary.habits.length,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              icon: const Icon(PhosphorIconsBold.plus, size: 18),
              label: Text(l10n.newHabit),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _HabitFilters(
          selected: _filter,
          onSelected: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 10),

        // Inicio sirve para REGISTRAR, no para editar: las filas no navegan
        // y se separan en pendientes y completados para ver de un vistazo
        // qué queda por hacer hoy.
        if (!hasHabits)
          HabitsListCard(
            habits: const [],
            weekLogs: const [],
            today: summary.today,
            onToggleToday: (_) {},
            mode: HabitTileMode.track,
          )
        else ...[
          if (_pending.isEmpty && !_hideAllDone)
            _AllDoneCard(
              onCreate: () => HabitsListPage.openCreateHabit(
                context,
                activeHabitCount: summary.habits.length,
              ),
              onDismiss: () => setState(() => _hideAllDone = true),
            )
          else ...[
            if (pending.isNotEmpty) ...[
              _SubSection(
                label: l10n.pendingHabitsWithCount(pending.length),
                onSeeAll: () => context.go('/habits'),
              ),
              const SizedBox(height: 8),
              HabitsListCard(
                habits: pending,
                weekLogs: summary.weekLogs,
                today: summary.today,
                progressOf: summary.progressOf,
                onToggleToday: (habitId) {
                  _toggleHabit(context, controller, habitId);
                },
                onHabitTap: (habit) =>
                    HabitsListPage.openEditHabit(context, habit),
                mode: HabitTileMode.trackCompact,
                onSetDailyCount: (habitId, count) {
                  final habit = summary.habits.firstWhere(
                    (item) => item.id == habitId,
                  );
                  _setRepetitionCount(context, controller, habit, count);
                },
              ),
            ],
          ],
          if (completed.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SubSection(
              label: l10n.completedHabitsWithCount(completed.length),
              onSeeAll: () => context.go('/habits'),
            ),
            const SizedBox(height: 8),
            HabitsListCard(
              habits: completed,
              weekLogs: summary.weekLogs,
              today: summary.today,
              progressOf: summary.progressOf,
              onToggleToday: (habitId) {
                _toggleHabit(context, controller, habitId);
              },
              onHabitTap: (habit) =>
                  HabitsListPage.openEditHabit(context, habit),
              mode: HabitTileMode.trackCompact,
              onSetDailyCount: (habitId, count) {
                final habit = summary.habits.firstWhere(
                  (item) => item.id == habitId,
                );
                _setRepetitionCount(context, controller, habit, count);
              },
            ),
          ],
        ],
        if (nextReminder != null) ...[
          const SizedBox(height: 16),
          NextReminderCard(
            habit: nextReminder,
            onMarkNow: () {
              _toggleHabit(context, controller, nextReminder.id);
            },
          ),
        ],
      ],
    );

    if (!_showColdStartWelcome) return home;
    return ColdStartWelcome(
      greeting: widget.greeting,
      message: WelcomeMessageSelector.message(l10n, _welcomeMessageIndex),
      onFinished: () {
        if (mounted) setState(() => _showColdStartWelcome = false);
      },
      child: home,
    );
  }

  bool _matchesFilter(Habit habit) {
    final type = habit.periodicityOn(summary.today).type;
    return switch (_filter) {
      _HabitFilter.all => true,
      _HabitFilter.daily => type == PeriodicityType.daily,
      _HabitFilter.weekly => type == PeriodicityType.weekly,
      _HabitFilter.monthly => type == PeriodicityType.monthly,
      _HabitFilter.yearly => type == PeriodicityType.yearly,
    };
  }
}

class _HabitFilters extends StatelessWidget {
  const _HabitFilters({required this.selected, required this.onSelected});

  final _HabitFilter selected;
  final ValueChanged<_HabitFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      _HabitFilter.all: l10n.habitFilterAll,
      _HabitFilter.daily: l10n.habitFilterDaily,
      _HabitFilter.weekly: l10n.habitFilterWeekly,
      _HabitFilter.monthly: l10n.habitFilterMonthly,
      _HabitFilter.yearly: l10n.habitFilterYearly,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _HabitFilter.values) ...[
            ChoiceChip(
              label: Text(labels[filter]!),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
              showCheckmark: false,
              side: BorderSide.none,
              selectedColor: AppColors.primary.withValues(alpha: 0.16),
              backgroundColor: AppColors.primary.withValues(alpha: 0.045),
              labelStyle: TextStyle(
                color: selected == filter
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: selected == filter
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
            if (filter != _HabitFilter.values.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// Cabecera pequeña de "Pendientes" / "Completados hoy".
class _SubSection extends StatelessWidget {
  const _SubSection({required this.label, required this.onSeeAll});

  final String label;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onSeeAll,
          icon: const Icon(PhosphorIconsBold.caretRight, size: 16),
          label: Text(context.l10n.seeAll),
          iconAlignment: IconAlignment.end,
        ),
      ],
    );
  }
}

/// Estado de "no queda nada por registrar hoy".
class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard({required this.onCreate, required this.onDismiss});

  final VoidCallback onCreate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌱', style: TextStyle(fontSize: 21)),
                ),
                const SizedBox(height: 7),
                Text(
                  l10n.allHabitsDoneTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.allHabitsDoneBody,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 9),
                FilledButton.tonal(
                  onPressed: onCreate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.newHabit),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              key: const ValueKey('dismiss-all-done'),
              onPressed: onDismiss,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                minimumSize: const Size(36, 36),
              ),
              icon: const Icon(PhosphorIconsRegular.x, size: 19),
            ),
          ),
        ],
      ),
    );
  }
}
