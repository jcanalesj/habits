import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/pomodoro/0_entity/entity.dart';
import 'package:habits/features/pomodoro/2_presentation/controllers/pomodoro_controller.dart';
import 'package:habits/features/pomodoro/2_presentation/providers/pomodoro_providers.dart';
import 'package:habits/features/pomodoro/2_presentation/widgets/pomodoro_settings_sheet.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Temporizador Pomodoro: anillo de fase, controles, etiqueta de sesión,
/// métricas de hoy y de la semana y sesiones del día.
class PomodoroPage extends ConsumerStatefulWidget {
  const PomodoroPage({super.key});

  @override
  ConsumerState<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends ConsumerState<PomodoroPage> {
  late final TextEditingController _label;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(
      text: ref.read(pomodoroControllerProvider).label,
    );
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _openSettings() async {
    final l10n = context.l10n;
    final current =
        ref.read(pomodoroConfigProvider).value ?? const PomodoroConfig();
    final next = await showPomodoroSettingsSheet(context, initial: current);
    if (next == null || !mounted) return;
    await ref.read(pomodoroRepositoryProvider).saveConfig(next);
    ref.read(pomodoroControllerProvider.notifier).applyConfig(next);
    if (!mounted) return;
    AppNotice.show(
      context,
      message: l10n.pomodoroSettingsSaved,
      type: AppNoticeType.success,
    );
  }

  Future<void> _clearHistory() async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: l10n.pomodoroClearHistoryTitle,
      body: l10n.pomodoroClearHistoryBody,
    );
    if (!confirmed || !mounted) return;
    await ref.read(pomodoroRepositoryProvider).deleteAllSessions();
    if (!mounted) return;
    AppNotice.show(context, message: l10n.pomodoroHistoryCleared);
  }

  static Color phaseColor(PomodoroPhase phase) => switch (phase) {
    PomodoroPhase.work => AppColors.flame,
    PomodoroPhase.shortBreak => AppColors.green,
    PomodoroPhase.longBreak => AppColors.blue,
  };

  static String _clock(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${rest.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(pomodoroControllerProvider);
    final controller = ref.read(pomodoroControllerProvider.notifier);
    final config = ref.watch(pomodoroConfigProvider).value ?? controller.config;
    final today = ref.watch(todayPomodoroSessionsProvider).value ?? const [];
    final week = ref.watch(weekPomodoroSessionsProvider).value ?? const [];
    final weekMinutes = week.fold(0, (sum, s) => sum + s.durationMinutes);
    final color = phaseColor(state.phase);

    // Textos de las notificaciones en el idioma actual.
    controller.copy = PomodoroCopy(
      workDoneTitle: l10n.pomodoroWorkDoneTitle,
      workDoneBody: l10n.pomodoroWorkDoneBody,
      breakDoneTitle: l10n.pomodoroBreakDoneTitle,
      breakDoneBody: l10n.pomodoroBreakDoneBody,
    );

    final phaseLabel = switch (state.phase) {
      PomodoroPhase.work => l10n.pomodoroPhaseWork,
      PomodoroPhase.shortBreak => l10n.pomodoroPhaseShortBreak,
      PomodoroPhase.longBreak => l10n.pomodoroPhaseLongBreak,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.pomodoroTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            key: const ValueKey('pomodoro-settings'),
            tooltip: l10n.pomodoroSettingsTitle,
            onPressed: _openSettings,
            icon: const Icon(PhosphorIconsBold.gear),
          ),
        ],
      ),
      body: ListView(
        key: const ValueKey('pomodoro-page'),
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          40 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          Center(
            child: Text(
              phaseLabel.toUpperCase(),
              key: const ValueKey('pomodoro-phase'),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ProgressRing(
              progress: state.progress,
              size: 260,
              color: color,
              semanticLabel: phaseLabel,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _clock(state.remainingSeconds),
                    key: const ValueKey('pomodoro-clock'),
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.pomodoroCycleProgress(
                      (state.isWork
                              ? state.completedInCycle + 1
                              : state.completedInCycle)
                          .clamp(1, config.pomodorosPerCycle),
                      config.pomodorosPerCycle,
                    ),
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SideButton(
                key: const ValueKey('pomodoro-reset'),
                icon: PhosphorIconsBold.arrowCounterClockwise,
                tooltip: l10n.pomodoroReset,
                onPressed: controller.reset,
              ),
              const SizedBox(width: 18),
              Semantics(
                button: true,
                label: state.isRunning
                    ? l10n.pomodoroPause
                    : state.isPaused
                    ? l10n.pomodoroResume
                    : l10n.pomodoroStart,
                child: Material(
                  key: const ValueKey('pomodoro-toggle'),
                  color: palette.primary,
                  shape: const CircleBorder(),
                  elevation: 0,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: controller.toggle,
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: Icon(
                        state.isRunning
                            ? PhosphorIconsFill.pause
                            : PhosphorIconsFill.play,
                        color: palette.onPrimary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              _SideButton(
                key: const ValueKey('pomodoro-skip'),
                icon: PhosphorIconsBold.skipForward,
                tooltip: l10n.pomodoroSkip,
                onPressed: controller.skip,
              ),
            ],
          ),
          const SizedBox(height: 22),
          AppTextField(
            key: const ValueKey('pomodoro-label'),
            controller: _label,
            hint: l10n.pomodoroLabelHint,
            prefixIcon: PhosphorIconsBold.tag,
            maxLength: PomodoroSession.maxLabelLength,
            onChanged: controller.setLabel,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  icon: PhosphorIconsFill.timer,
                  color: AppColors.flame,
                  label: l10n.pomodoroTodayLabel,
                  value: '${today.length}',
                  detail: l10n.pomodoroTodayDetailWithCount(today.length),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricTile(
                  icon: PhosphorIconsFill.chartBar,
                  color: palette.primary,
                  label: l10n.pomodoroWeekLabel,
                  value: l10n.pomodoroMinutesWithCount(weekMinutes),
                  detail: l10n.pomodoroFocusMinutes,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            l10n.pomodoroSessionsToday,
            style: textTheme.titleLarge?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          if (today.isEmpty)
            EmptyStateBlock(
              icon: PhosphorIconsRegular.timer,
              text: l10n.pomodoroSessionsEmpty,
              color: AppColors.flame,
            )
          else
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: surfaceDecoration(palette),
              child: Column(
                children: [
                  for (final (index, session) in today.indexed) ...[
                    if (index > 0)
                      Divider(height: 1, indent: 56, color: palette.divider),
                    _SessionRow(session: session),
                  ],
                ],
              ),
            ),
          if (week.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: const ValueKey('pomodoro-clear-history'),
                onPressed: _clearHistory,
                style: TextButton.styleFrom(foregroundColor: dangerColor),
                icon: const Icon(PhosphorIconsBold.trash, size: 18),
                label: Text(l10n.pomodoroClearHistory),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: palette.tint(palette.primary, .10),
        foregroundColor: palette.primary,
        minimumSize: const Size(52, 52),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final PomodoroSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final time = DateFormat.Hm(locale).format(session.startedAt.toLocal());
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.tint(AppColors.flame, .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              PhosphorIconsFill.timer,
              color: AppColors.flame,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.label ?? l10n.pomodoroSessionNoLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: session.label == null
                        ? palette.textSecondary
                        : palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            l10n.pomodoroMinutesWithCount(session.durationMinutes),
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
