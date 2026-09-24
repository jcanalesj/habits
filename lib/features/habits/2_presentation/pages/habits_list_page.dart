import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/2_presentation/controllers/home_controller.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Pestaña "Hábitos": todos los hábitos activos con su objetivo y la semana
/// en curso. Tocar uno lleva a su edición.
class HabitsListPage extends ConsumerWidget {
  const HabitsListPage({super.key, this.standalone = false});

  final bool standalone;

  static const freeHabitLimit = 5;

  static Future<void> openEditHabit(BuildContext context, Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (_) => const _EditHabitWarningDialog(),
    );
    if (confirmed == true && context.mounted) {
      context.push('/habit/${habit.id}');
    }
  }

  static Future<void> openCreateHabit(
    BuildContext context, {
    required int activeHabitCount,
  }) async {
    if (activeHabitCount >= freeHabitLimit) {
      final continueToCreate = await showDialog<bool>(
        context: context,
        barrierColor: context.palette.scrim,
        builder: (_) => const _PremiumHabitLimitDialog(),
      );
      if (continueToCreate != true || !context.mounted) return;
    }
    context.push('/habit/new');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: standalone
          ? AppBar(
              key: const ValueKey('standalone-habits-app-bar'),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        top: !standalone,
        bottom: false,
        child: switch (summaryAsync) {
          AsyncData(:final value) => _Content(
            summary: value,
            standalone: standalone,
          ),
          AsyncError(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.somethingWentWrong('$error')),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _PremiumHabitLimitDialog extends StatelessWidget {
  const _PremiumHabitLimitDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Dialog(
      key: const ValueKey('premium-habit-limit-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: palette.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/premium.png',
                width: 230,
                height: 190,
                fit: BoxFit.contain,
                semanticLabel: l10n.premiumCatImageLabel,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.premiumHabitLimitTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: palette.authHeading,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.premiumHabitLimitBody,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: palette.authSecondary,
                  height: 1.42,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: palette.tint(palette.primary, .055),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _PremiumBenefit(
                      icon: PhosphorIconsBold.infinity,
                      title: l10n.premiumUnlimitedHabits,
                      subtitle: l10n.premiumUnlimitedHabitsBody,
                    ),
                    const SizedBox(height: 16),
                    _PremiumBenefit(
                      icon: PhosphorIconsBold.chartBar,
                      title: l10n.premiumAdvancedStats,
                      subtitle: l10n.premiumAdvancedStatsBody,
                    ),
                    const SizedBox(height: 16),
                    _PremiumBenefit(
                      icon: PhosphorIconsBold.star,
                      title: l10n.premiumNewFeatures,
                      subtitle: l10n.premiumNewFeaturesBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.primary,
                        side: const BorderSide(
                          color: AppColors.gradientStart,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(l10n.premiumNotNow),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: FilledButton(
                        key: const ValueKey('view-premium-plans'),
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          l10n.premiumViewPlans,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBenefit extends StatelessWidget {
  const _PremiumBenefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: palette.tint(palette.primary, .1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.palette.primary, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: palette.authHeading,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: palette.authSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.summary, required this.standalone});

  final HomeSummary summary;
  final bool standalone;

  void _openEditor(BuildContext context, Habit habit) =>
      HabitsListPage.openEditHabit(context, habit);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.palette;

    if (summary.habits.isEmpty) {
      return const _EmptyHabits();
    }

    final visibleAmbitos = [
      for (final ambito in summary.ambitos)
        if (summary.habits.any((habit) => habit.ambitoId == ambito.id)) ambito,
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, standalone ? 32 : 120),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: l10n.allHabitsTitle),
                  const SizedBox(height: 4),
                  Text(
                    l10n.myHabitsManageSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!standalone)
              FilledButton.tonalIcon(
                key: const ValueKey('open-habit-calendars'),
                onPressed: () => context.go('/habits'),
                style: FilledButton.styleFrom(
                  foregroundColor: palette.primary,
                  backgroundColor: palette.tint(palette.primary, .10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                ),
                icon: const Icon(PhosphorIconsBold.calendarDots, size: 19),
                label: Text(l10n.habitCalendarsAction),
              ),
          ],
        ),
        const SizedBox(height: 20),
        for (var index = 0; index < visibleAmbitos.length; index++) ...[
          Row(
            children: [
              Expanded(child: _AmbitoHeader(ambito: visibleAmbitos[index])),
              if (index == 0)
                FilledButton.icon(
                  key: const ValueKey('add-habit-inline'),
                  onPressed: () => HabitsListPage.openCreateHabit(
                    context,
                    activeHabitCount: summary.habits.length,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.isDark
                        ? palette.primarySoft
                        : palette.primary,
                    foregroundColor: palette.isDark
                        ? palette.primaryDeep
                        : palette.onPrimary,
                    side: palette.isDark
                        ? BorderSide(
                            color: palette.primary.withValues(alpha: .52),
                          )
                        : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                  ),
                  icon: const Icon(PhosphorIconsBold.plusCircle, size: 19),
                  label: Text(l10n.addHabit),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _ManageHabitsGroup(
            habits: [
              for (final habit in summary.habits)
                if (habit.ambitoId == visibleAmbitos[index].id) habit,
            ],
            today: summary.today,
            onEdit: (habit) => _openEditor(context, habit),
            onReorder: (oldIndex, newIndex) => ref
                .read(homeControllerProvider.notifier)
                .reorderHabitsInAmbito(
                  visibleAmbitos[index].id,
                  oldIndex,
                  newIndex,
                ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _ManageHabitsGroup extends StatelessWidget {
  const _ManageHabitsGroup({
    required this.habits,
    required this.today,
    required this.onEdit,
    required this.onReorder,
  });

  final List<Habit> habits;
  final LogicalDate today;
  final ValueChanged<Habit> onEdit;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: habits.length,
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        elevation: 6,
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Padding(
          key: ValueKey('habit-edit-${habit.id}'),
          padding: const EdgeInsets.only(bottom: 10),
          child: _ManageHabitCard(
            habit: habit,
            today: today,
            onTap: () => onEdit(habit),
            dragHandle: ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 16,
                ),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: context.palette.textSecondary,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ManageHabitCard extends StatelessWidget {
  const _ManageHabitCard({
    required this.habit,
    required this.today,
    required this.onTap,
    required this.dragHandle,
  });

  final Habit habit;
  final LogicalDate today;
  final VoidCallback onTap;
  final Widget dragHandle;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final tintEnd = color.withValues(alpha: 0.18);

    return Semantics(
      button: true,
      label: context.l10n.editHabitTitle,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.surface.withValues(alpha: palette.isDark ? 1 : 0.72),
                  palette.isDark
                      ? Color.alphaBlend(tintEnd, palette.surface)
                      : tintEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                dragHandle,
                const SizedBox(width: 6),
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: HabitIcon(
                    iconId: habit.iconId,
                    legacyEmoji: habit.emoji,
                    size: 52,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        PeriodicityLabel.of(
                          context.l10n,
                          habit.periodicityOn(today),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.isDark
                        ? palette.surfaceMuted
                        : palette.surface.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsBold.pencilSimple,
                    color: palette.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  const _EmptyHabits();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    void createHabit() => context.push('/habit/new');

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.allHabitsTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: AppDimensions.screenTitleFontSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.myHabitsManageSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: const ValueKey('empty-add-habit-top'),
              onPressed: createHabit,
              style: FilledButton.styleFrom(
                backgroundColor: palette.isDark
                    ? palette.primarySoft
                    : palette.primary,
                foregroundColor: palette.isDark
                    ? palette.primaryDeep
                    : palette.onPrimary,
                side: palette.isDark
                    ? BorderSide(color: palette.primary.withValues(alpha: .52))
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(PhosphorIconsBold.plus, size: 19),
              label: Text(l10n.addHabit),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Image.asset(
          'assets/images/empty_habits.png',
          height: 265,
          fit: BoxFit.contain,
          semanticLabel: l10n.emptyHabitsImageLabel,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.emptyHabitsTitle,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.emptyHabitsBody,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: palette.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: FilledButton.icon(
            key: const ValueKey('empty-add-first-habit'),
            onPressed: createHabit,
            style: FilledButton.styleFrom(
              backgroundColor: palette.isDark
                  ? palette.primarySoft
                  : palette.primary,
              foregroundColor: palette.isDark
                  ? palette.primaryDeep
                  : palette.onPrimary,
              side: palette.isDark
                  ? BorderSide(color: palette.primary.withValues(alpha: .52))
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(PhosphorIconsBold.plus, size: 20),
            label: Text(l10n.addFirstHabit),
          ),
        ),
        const SizedBox(height: 34),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n.needIdeas,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _HabitIdea(
              icon: PhosphorIconsRegular.sneakerMove,
              color: palette.primary,
              label: l10n.habitIdeaExercise,
            ),
            _HabitIdea(
              icon: PhosphorIconsRegular.bookOpen,
              color: AppColors.green,
              label: l10n.habitIdeaRead,
            ),
            _HabitIdea(
              icon: PhosphorIconsRegular.drop,
              color: AppColors.blue,
              label: l10n.habitIdeaWater,
            ),
            _HabitIdea(
              icon: PhosphorIconsRegular.moon,
              color: palette.primary,
              label: l10n.habitIdeaSleep,
            ),
          ],
        ),
      ],
    );
  }
}

class _HabitIdea extends StatelessWidget {
  const _HabitIdea({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: palette.isDark ? 1 : 0.72),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditHabitWarningDialog extends StatelessWidget {
  const _EditHabitWarningDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: palette.dialogSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context, false),
                  style: IconButton.styleFrom(
                    backgroundColor: palette.tint(palette.primary, .08),
                    foregroundColor: palette.textSecondary,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 28),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -14),
                child: Image.asset(
                  'assets/icons/edit.png',
                  width: 168,
                  height: 168,
                  fit: BoxFit.contain,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -12),
                child: Column(
                  children: [
                    Text(
                      l10n.editHabitWarningTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.editHabitWarningBody,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: palette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: palette.tint(palette.primary, .055),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _WarningPoint(
                            icon: Icons.bar_chart_rounded,
                            text: l10n.editHabitProgressInfo,
                          ),
                          const SizedBox(height: 14),
                          _WarningPoint(
                            icon: Icons.schedule_rounded,
                            text: l10n.editHabitHistoryInfo,
                          ),
                          const SizedBox(height: 14),
                          _WarningPoint(
                            icon: Icons.local_fire_department_rounded,
                            text: l10n.editHabitStreakInfo,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: palette.primary,
                              side: BorderSide(
                                color: palette.primary.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryDeep,
                                  AppColors.primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: Text(l10n.continueLabel),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningPoint extends StatelessWidget {
  const _WarningPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.tint(palette.primary, .10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: palette.primary, size: 23),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.textSecondary,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _AmbitoHeader extends StatelessWidget {
  const _AmbitoHeader({required this.ambito});

  final Ambito ambito;

  @override
  Widget build(BuildContext context) {
    final color = Color(ambito.colorValue);
    final palette = context.palette;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.tint(color, .14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(ambito.emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ambito.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
