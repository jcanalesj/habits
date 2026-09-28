import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:habits/features/steps/2_presentation/widgets/steps_history.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Barras de pasos con línea de objetivo opcional (solo para barras diarias).
class StepsBarsChart extends StatelessWidget {
  const StepsBarsChart({
    super.key,
    required this.bars,
    this.goal,
    this.labelEvery = 1,
  });

  final List<StepsBar> bars;
  final int? goal;

  /// Muestra una etiqueta cada N barras (30 días no caben todos).
  final int labelEvery;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final maxValue = [
      goal ?? 0,
      for (final bar in bars) bar.steps,
    ].fold(0, (a, b) => a > b ? a : b);
    final scale = _roundedScale(maxValue == 0 ? 1 : maxValue);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      children: [
        SizedBox(
          height: 142,
          child: CustomPaint(
            size: Size.infinite,
            painter: _BarsPainter(
              bars: bars,
              maxValue: scale,
              goal: goal,
              color: AppColors.primary,
              highlightColor: palette.isDark
                  ? const Color(0xFF78E5C1)
                  : const Color(0xFF39B991),
              gridColor: palette.divider,
              labelColor: palette.textSecondary,
              goalColor: palette.primary,
              goalBackground: palette.surface,
              goalLabel: Localizations.localeOf(context).languageCode == 'es'
                  ? 'Objetivo'
                  : 'Goal',
              numberFormat: NumberFormat.decimalPattern(locale),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 44),
            for (final (index, bar) in bars.indexed)
              Expanded(
                child: Text(
                  index % labelEvery == 0 || bar.emphasized ? bar.label : '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: bars.length > 12 ? 9 : 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: 2),
          ],
        ),
      ],
    );
  }

  double _roundedScale(int value) {
    if (value <= 1000) return ((value / 100).ceil() * 100).toDouble();
    return ((value / 1000).ceil() * 1000).toDouble();
  }
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({
    required this.bars,
    required this.maxValue,
    required this.goal,
    required this.color,
    required this.highlightColor,
    required this.gridColor,
    required this.labelColor,
    required this.goalColor,
    required this.goalBackground,
    required this.goalLabel,
    required this.numberFormat,
  });

  final List<StepsBar> bars;
  final double maxValue;
  final int? goal;
  final Color color;
  final Color highlightColor;
  final Color gridColor;
  final Color labelColor;
  final Color goalColor;
  final Color goalBackground;
  final String goalLabel;
  final NumberFormat numberFormat;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    const left = 44.0;
    const right = 2.0;
    const top = 12.0;
    final plotWidth = size.width - left - right;
    final plotHeight = size.height - top;
    final slot = plotWidth / bars.length;
    final barWidth = slot * (bars.length > 12 ? .62 : .58);
    final radius = Radius.circular(bars.length > 12 ? 4 : 8);
    final labelStyle = TextStyle(
      color: labelColor,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    for (final value in [maxValue, maxValue / 2, 0.0]) {
      final y = top + plotHeight - (value / maxValue) * plotHeight;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1,
      );
      final label = value == 0 ? '0' : numberFormat.format(value.round());
      final painter = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: left - 6);
      painter.paint(canvas, Offset(0, y - painter.height / 2));
    }

    for (final (index, bar) in bars.indexed) {
      final barLeft = left + slot * index + (slot - barWidth) / 2;
      final height = (bar.steps / maxValue).clamp(0, 1) * plotHeight;
      if (height <= 0) continue;
      final rect = Rect.fromLTWH(
        barLeft,
        top + plotHeight - height,
        barWidth,
        height,
      );
      final baseColor = bar.emphasized ? highlightColor : color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              baseColor.withValues(alpha: bar.emphasized ? 1 : .86),
              baseColor.withValues(alpha: bar.emphasized ? .72 : .52),
            ],
          ).createShader(rect),
      );
    }
    if (goal case final goal? when goal > 0) {
      final y = top + plotHeight - (goal / maxValue).clamp(0, 1) * plotHeight;
      final paint = Paint()
        ..color = goalColor
        ..strokeWidth = 1.5;
      const dash = 6.0;
      var x = left;
      while (x < size.width - right) {
        canvas.drawLine(
          Offset(x, y),
          Offset((x + dash).clamp(left, size.width - right), y),
          paint,
        );
        x += dash * 2;
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: goalLabel,
          style: TextStyle(
            color: goalColor,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      const horizontalPadding = 5.0;
      const verticalPadding = 2.0;
      final pillWidth = textPainter.width + horizontalPadding * 2;
      final pillHeight = textPainter.height + verticalPadding * 2;
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - right - pillWidth,
          (y - pillHeight / 2).clamp(0, size.height - pillHeight),
          pillWidth,
          pillHeight,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(pillRect, Paint()..color = goalBackground);
      canvas.drawRRect(
        pillRect,
        Paint()
          ..color = goalColor.withValues(alpha: .55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      textPainter.paint(
        canvas,
        Offset(
          pillRect.left + horizontalPadding,
          pillRect.top + verticalPadding,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.bars != bars ||
      old.maxValue != maxValue ||
      old.goal != goal ||
      old.color != color ||
      old.highlightColor != highlightColor ||
      old.gridColor != gridColor ||
      old.labelColor != labelColor ||
      old.goalColor != goalColor ||
      old.goalBackground != goalBackground ||
      old.goalLabel != goalLabel;
}
