import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';

class StepsMonthCalendar extends StatelessWidget {
  const StepsMonthCalendar({
    super.key,
    required this.month,
    required this.days,
    required this.goal,
    required this.locale,
  });

  final DateTime month;
  final List<StepsDay> days;
  final int goal;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final byDay = {for (final day in days) day.day.day: day.steps};
    final total = days.fold<int>(0, (sum, day) => sum + day.steps);
    final firstWeekday = DateTime(month.year, month.month).weekday;
    final count = DateTime(month.year, month.month + 1, 0).day;
    final cells = firstWeekday - 1 + count;
    final rows = (cells / 7).ceil();
    final monthLabel = DateFormat.yMMMM(locale).format(month);
    final weekdays = DateFormat.E(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          monthLabel[0].toUpperCase() + monthLabel.substring(1),
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.decimalPattern(locale).format(total),
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 30,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                locale.startsWith('es') ? 'Total de pasos' : 'Total steps',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var weekday = 1; weekday <= 7; weekday++)
              Expanded(
                child: Text(
                  weekdays
                      .format(DateTime(2026, 9, 7 + weekday - 1))
                      .replaceAll('.', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 7),
        for (var row = 0; row < rows; row++) ...[
          Row(
            children: [
              for (var column = 0; column < 7; column++)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final day = row * 7 + column - (firstWeekday - 2);
                      if (day < 1 || day > count) {
                        return const SizedBox(height: 38);
                      }
                      return _CalendarDay(
                        day: day,
                        steps: byDay[day] ?? 0,
                        goal: goal,
                      );
                    },
                  ),
                ),
            ],
          ),
          if (row < rows - 1) const SizedBox(height: 5),
        ],
      ],
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.steps,
    required this.goal,
  });

  final int day;
  final int steps;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final progress = goal <= 0 ? 0.0 : (steps / goal).clamp(0.0, 1.0);
    final reached = progress >= 1;
    return Semantics(
      label: '$day: $steps',
      child: SizedBox(
        height: 38,
        child: CustomPaint(
          painter: _DayProgressPainter(
            progress: progress,
            color: palette.primary,
            track: palette.primarySoft,
            reached: reached,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                color: reached ? palette.onPrimary : palette.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayProgressPainter extends CustomPainter {
  const _DayProgressPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.reached,
  });

  final double progress;
  final Color color;
  final Color track;
  final bool reached;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;
    canvas.drawCircle(center, radius, Paint()..color = reached ? color : track);
    if (!reached && progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_DayProgressPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.reached != reached;
}
