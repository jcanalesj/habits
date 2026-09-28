import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:habits/components/app_form_dialog.dart';
import 'package:habits/components/app_haptics.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Celebración no bloqueante al registrar un hábito.
abstract final class HabitCelebration {
  static void show(
    BuildContext context, {
    required String message,
    required bool allDone,
    bool haptic = true,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CelebrationOverlay(
        message: message,
        allDone: allDone,
        onFinished: entry.remove,
      ),
    );
    overlay.insert(entry);
    if (haptic) unawaited(AppHaptics.habitCompleted());
  }

  /// Celebra el momento especial en el que ya no queda ningún hábito del día.
  ///
  /// El confeti aparece de inmediato y el audio se reproduce en paralelo para
  /// que un fallo del reproductor nunca impida mostrar la felicitación.
  static Future<void> showDayCompleted(
    BuildContext context, {
    required String message,
  }) async {
    final l10n = context.l10n;
    final player = AudioPlayer();

    show(context, message: message, allDone: true);
    unawaited(
      player
          .play(AssetSource('audio/applause.wav'), volume: .8)
          .catchError((Object _) {}),
    );

    try {
      await showDialog<void>(
        context: context,
        barrierColor: context.palette.scrim,
        builder: (dialogContext) => AppFormDialog(
          key: const ValueKey('habits-day-completed-dialog'),
          hero: const AppDialogHero.cat(
            badge: PhosphorIconsBold.confetti,
            color: AppColors.primary,
          ),
          title: message,
          helper: l10n.allHabitsDoneBody,
          primaryLabel: l10n.continueLabel,
          primaryIcon: PhosphorIconsBold.sparkle,
          primaryKey: const ValueKey('habits-day-completed-ok'),
          onPrimary: () => Navigator.pop(dialogContext),
          secondaryLabel: l10n.cancel,
        ),
      );
    } finally {
      await player.dispose();
    }
  }
}

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({
    required this.message,
    required this.allDone,
    required this.onFinished,
  });

  final String message;
  final bool allDone;
  final VoidCallback onFinished;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.allDone ? 1900 : 1250),
    )..forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.duration = const Duration(milliseconds: 450);
    }

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            final entrance = Curves.elasticOut.transform(
              (progress / 0.42).clamp(0.0, 1.0),
            );
            final fade =
                1 -
                Curves.easeIn.transform(
                  ((progress - 0.72) / 0.28).clamp(0.0, 1.0),
                );

            return Stack(
              fit: StackFit.expand,
              children: [
                if (!reduceMotion)
                  CustomPaint(
                    painter: _CelebrationPainter(
                      progress: progress,
                      particleCount: widget.allDone ? 52 : 22,
                    ),
                  ),
                Center(
                  child: Opacity(
                    opacity: fade,
                    child: Transform.scale(
                      scale: 0.35 + (0.65 * entrance),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 310),
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9877FF), Color(0xFF6546E8)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.38),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.allDone ? '🏆' : '✨',
                              style: const TextStyle(fontSize: 34),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.message,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter({
    required this.progress,
    required this.particleCount,
  });

  final double progress;
  final int particleCount;

  static const _colors = [
    Color(0xFF7C5CE0),
    Color(0xFFFFB84D),
    Color(0xFF38BDF8),
    Color(0xFFF16A8F),
    Color(0xFF34B379),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final travel = Curves.easeOutCubic.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0);

    for (var index = 0; index < particleCount; index++) {
      final angle = (index / particleCount) * math.pi * 2;
      final variation = 0.72 + ((index * 37) % 31) / 50;
      final distance =
          (70 + math.min(size.width, size.height) * 0.46) * travel * variation;
      final gravity = 90 * progress * progress;
      final position = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance + gravity,
      );
      final paint = Paint()
        ..color = _colors[index % _colors.length].withValues(alpha: opacity);
      final radius = 3.0 + (index % 4);
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + progress * 5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 1.2,
            height: radius * 2.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.particleCount != particleCount;
}
