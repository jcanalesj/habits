import 'dart:math' as math;

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
          const _PomodoroHero(),
          const SizedBox(height: 18),
          Center(
            child: _PomodoroDial(
              progress: state.progress,
              color: color,
              phaseLabel: phaseLabel,
              clock: _clock(state.remainingSeconds),
              cycleLabel: l10n.pomodoroCycleProgress(
                (state.isWork
                        ? state.completedInCycle + 1
                        : state.completedInCycle)
                    .clamp(1, config.pomodorosPerCycle),
                config.pomodorosPerCycle,
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
            _EmptySessions(text: l10n.pomodoroSessionsEmpty)
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

class _PomodoroHero extends StatelessWidget {
  const _PomodoroHero();

  @override
  Widget build(BuildContext context) => Container(
    height: 112,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: AppColors.flame.withValues(alpha: .10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Image.asset(
      'assets/images/pomodoro/pomodoro_hero.png',
      fit: BoxFit.cover,
      alignment: Alignment.center,
    ),
  );
}

class _PomodoroDial extends StatelessWidget {
  const _PomodoroDial({
    required this.progress,
    required this.color,
    required this.phaseLabel,
    required this.clock,
    required this.cycleLabel,
  });

  final double progress;
  final Color color;
  final String phaseLabel;
  final String clock;
  final String cycleLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: phaseLabel,
      value: clock,
      child: SizedBox.square(
        dimension: 270,
        child: CustomPaint(
          painter: _PomodoroDialPainter(
            progress: progress,
            trackColor: color.withValues(alpha: .12),
            startColor: const Color(0xFFFFA43A),
            endColor: const Color(0xFFFF625C),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  phaseLabel.toUpperCase(),
                  key: const ValueKey('pomodoro-phase'),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  clock,
                  key: const ValueKey('pomodoro-clock'),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    height: .95,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  cycleLabel,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w700,
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

class _PomodoroDialPainter extends CustomPainter {
  const _PomodoroDialPainter({
    required this.progress,
    required this.trackColor,
    required this.startColor,
    required this.endColor,
  });

  final double progress;
  final Color trackColor;
  final Color startColor;
  final Color endColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 13.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawOval(arcRect, track);

    final value = progress.clamp(0.0, 1.0);
    if (value <= 0) return;
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 3 / 2,
        colors: [startColor, endColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * value, false, paint);
  }

  @override
  bool shouldRepaint(_PomodoroDialPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.startColor != startColor ||
      oldDelegate.endColor != endColor;
}

class _EmptySessions extends StatelessWidget {
  const _EmptySessions({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/pomodoro/pomodoro_empty_cat.png',
            height: 74,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
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
