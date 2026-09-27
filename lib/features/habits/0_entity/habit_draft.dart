import 'package:flutter/foundation.dart';
import 'package:habits/features/habits/0_entity/habit_tracking.dart';
import 'package:habits/features/habits/0_entity/habit_kind.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';

@immutable
class HabitDraft {
  const HabitDraft({
    required this.name,
    required this.ambitoId,
    this.periodicity = Periodicity.daily,
    required this.colorValue,
    required this.emoji,
    this.iconId,
    this.trackingType = HabitTrackingType.single,
    this.targetCount = 1,
    this.unit,
    this.displayGoal,
    this.progressIconId = 'check',
    this.kind = HabitKind.build,
    this.abstinenceStartedAt,
    this.reminderTime,
    this.reminderMessage,
  });
  final String name, ambitoId, emoji, progressIconId;
  final String? iconId;
  final Periodicity periodicity;
  final int colorValue, targetCount;
  final HabitTrackingType trackingType;
  final HabitKind kind;
  final DateTime? abstinenceStartedAt;
  final String? unit, displayGoal, reminderTime, reminderMessage;
  HabitDraft copyWith({String? name, String? emoji, String? iconId}) =>
      HabitDraft(
        name: name ?? this.name,
        ambitoId: ambitoId,
        periodicity: periodicity,
        colorValue: colorValue,
        emoji: emoji ?? this.emoji,
        iconId: iconId ?? this.iconId,
        trackingType: trackingType,
        targetCount: targetCount,
        unit: unit,
        displayGoal: displayGoal,
        progressIconId: progressIconId,
        kind: kind,
        abstinenceStartedAt: abstinenceStartedAt,
        reminderTime: reminderTime,
        reminderMessage: reminderMessage,
      );
}
