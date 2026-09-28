import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

/// Anillo de progreso: pista tintada y arco de color (o degradado de marca)
/// con el contenido centrado dentro. Lo usan Pomodoro y Pasos.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.size,
    this.color,
    this.gradient = false,
    this.strokeWidth = 12,
    this.child,
    this.semanticLabel,
  });

  /// De 0 a 1. Fuera de rango se recorta.
  final double progress;
  final double size;
  final Color? color;

  /// Arco con el degradado de marca en vez de color plano.
  final bool gradient;
  final double strokeWidth;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = color ?? palette.primary;
    return Semantics(
      label: semanticLabel,
      value: '${(progress.clamp(0, 1) * 100).round()} %',
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => CustomPaint(
            painter: _RingPainter(
              progress: value,
              track: palette.tint(accent, .12),
              color: accent,
              gradient: gradient
                  ? const [AppColors.gradientStart, AppColors.gradientEnd]
                  : null,
              strokeWidth: strokeWidth,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.color,
    required this.gradient,
    required this.strokeWidth,
  });

  final double progress;
  final Color track;
  final Color color;
  final List<Color>? gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    if (gradient case final colors?) {
      arcPaint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [colors.first, colors.last, colors.first],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    } else {
      arcPaint.color = color;
    }
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.color != color ||
      old.gradient != gradient ||
      old.strokeWidth != strokeWidth;
}
