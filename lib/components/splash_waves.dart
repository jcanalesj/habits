import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

/// Fondo del splash: degradado suave con ondas lavanda en la mitad inferior.
/// En oscuro pinta las ondas con tonos de marca a menos alfa sobre
/// `palette.background`.
class SplashWavesBackground extends StatelessWidget {
  const SplashWavesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _SplashWavesPainter(context.palette),
    );
  }
}

class _SplashWavesPainter extends CustomPainter {
  const _SplashWavesPainter(this.palette);

  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final isDark = palette.isDark;

    // Fondo degradado suave.
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [palette.background, palette.surface]
            : const [Color(0xFFF8F5FD), Color(0xFFEFEAF9)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    // Halo cálido tras el logo (lila tenue en oscuro).
    final glowColor = isDark
        ? AppColors.gradientStart
        : const Color(0xFFFFF4E8);
    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              glowColor.withValues(alpha: isDark ? 0.16 : 0.55),
              glowColor.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(0.62 * w, 0.24 * h),
              radius: 0.45 * w,
            ),
          );
    canvas.drawCircle(Offset(0.62 * w, 0.24 * h), 0.45 * w, glow);

    // Ondas translúcidas.
    if (isDark) {
      _wave(canvas, w, h, 0.62, 0.10, AppColors.gradientStart, 0.10);
      _wave(canvas, w, h, 0.72, 0.08, AppColors.gradientEnd, 0.14);
      _wave(canvas, w, h, 0.84, 0.07, AppColors.primaryDeep, 0.18);
    } else {
      _wave(canvas, w, h, 0.62, 0.10, AppColors.gradientStart, 0.22);
      _wave(canvas, w, h, 0.72, 0.08, const Color(0xFFC9B8F5), 0.35);
      _wave(canvas, w, h, 0.84, 0.07, const Color(0xFFDDD2F7), 0.5);
    }
  }

  void _wave(
    Canvas canvas,
    double w,
    double h,
    double startFraction,
    double amplitudeFraction,
    Color color,
    double alpha,
  ) {
    final y = startFraction * h;
    final amp = amplitudeFraction * h;
    final paint = Paint()..color = color.withValues(alpha: alpha);

    final path = Path()
      ..moveTo(0, y)
      ..cubicTo(0.25 * w, y - amp, 0.40 * w, y + amp, 0.65 * w, y)
      ..cubicTo(
        0.82 * w,
        y - amp * 0.7,
        0.92 * w,
        y + amp * 0.4,
        w,
        y - amp * 0.3,
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashWavesPainter oldDelegate) =>
      oldDelegate.palette.isDark != palette.isDark;
}
