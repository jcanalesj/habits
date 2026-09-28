import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:habits/components/components.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Felicitación con el gato del gimnasio al cumplir el objetivo diario.
/// Va acompañada del confeti habitual de la app.
Future<void> showStepsGoalCelebration(
  BuildContext context, {
  required String formattedSteps,
}) async {
  final l10n = context.l10n;
  final player = AudioPlayer();
  HabitCelebration.show(
    context,
    message: l10n.stepsGoalCelebrationTitle,
    allDone: true,
    haptic: false,
  );
  unawaited(AppHaptics.stepsGoalCompleted());
  try {
    // El diálogo aparece de inmediato; el audio nunca bloquea la felicitación.
    unawaited(
      player
          .play(AssetSource('audio/applause.wav'), volume: .75)
          .catchError((Object _) {}),
    );
    await showDialog<void>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (context) => AppFormDialog(
        key: const ValueKey('steps-celebration-dialog'),
        hero: Image.asset(
          'assets/images/gatogym.png',
          width: 170,
          height: 138,
          fit: BoxFit.contain,
          semanticLabel: l10n.stepsCelebrationCatImageLabel,
        ),
        title: l10n.stepsGoalCelebrationTitle,
        helper: l10n.stepsGoalCelebrationBody(formattedSteps),
        primaryLabel: l10n.stepsGoalCelebrationAction,
        primaryIcon: PhosphorIconsBold.confetti,
        primaryColor: AppColors.green,
        primaryKey: const ValueKey('steps-celebration-ok'),
        onPrimary: () => Navigator.pop(context),
        secondaryLabel: l10n.cancel,
      ),
    );
  } finally {
    await player.dispose();
  }
}
