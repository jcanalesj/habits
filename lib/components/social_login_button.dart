import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

enum SocialProvider { google, apple }

/// Botón de login social (Google / Apple). En v1 el login social está fuera
/// de alcance: se muestran por diseño y avisan de "muy pronto" al pulsar.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 130,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.divider),
        ),
        child: switch (provider) {
          SocialProvider.google => const _GoogleGlyph(size: 24),
          SocialProvider.apple => Icon(
            Icons.apple,
            size: 28,
            color: palette.textPrimary,
          ),
        },
      ),
    );
  }
}

/// "G" de Google dibujada con los cuatro colores de marca.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);
    final stroke = s * 0.2;
    final radius = (s - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double deg(double d) => d * math.pi / 180;
    Paint arcPaint(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color;

    // Segmentos aproximados de la "G" (el hueco queda arriba a la derecha).
    canvas.drawArc(rect, deg(-15), deg(60), false, arcPaint(_blue));
    canvas.drawArc(rect, deg(45), deg(90), false, arcPaint(_green));
    canvas.drawArc(rect, deg(135), deg(90), false, arcPaint(_yellow));
    canvas.drawArc(rect, deg(225), deg(90), false, arcPaint(_red));

    // Barra horizontal de la G.
    final barPaint = Paint()..color = _blue;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - stroke / 2,
        radius + stroke / 2,
        stroke,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
