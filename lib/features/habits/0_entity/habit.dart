import 'package:flutter/foundation.dart';
import 'package:habits/features/habits/0_entity/habit_tracking.dart';
import 'package:habits/features/habits/0_entity/habit_kind.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';

@immutable
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.ambitoId,
    required this.periodicityTimeline,
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
    this.bestAbstinenceSeconds = 0,
    this.relapseCount = 0,
    this.reminderTime,
    this.reminderMessage,
    this.order = 0,
    required this.createdAt,
    this.deletedAt,
  });
  final String id, name, ambitoId, emoji, progressIconId;
  final String? iconId;
  final List<PeriodicityEntry> periodicityTimeline;
  final int colorValue, targetCount, order;
  final HabitTrackingType trackingType;
  final HabitKind kind;
  final DateTime? abstinenceStartedAt;
  final int bestAbstinenceSeconds, relapseCount;
  final String? unit, displayGoal, reminderTime, reminderMessage;
  final DateTime createdAt;
  final DateTime? deletedAt;
  bool get isDeleted => deletedAt != null;
  bool get hasRepetitions => trackingType == HabitTrackingType.repetitions;
  bool get isQuitHabit => kind == HabitKind.quit;
  Periodicity periodicityOn(LogicalDate date) {
    var result = periodicityTimeline.isEmpty
        ? Periodicity.daily
        : periodicityTimeline.first.periodicity;
    for (final entry in periodicityTimeline) {
      if (entry.since.isAfter(date)) break;
      result = entry.periodicity;
    }
    return result;
  }

  Habit copyWith({
    String? id,
    String? name,
    String? ambitoId,
    List<PeriodicityEntry>? periodicityTimeline,
    int? colorValue,
    String? emoji,
    Object? iconId = _sentinel,
    HabitTrackingType? trackingType,
    int? targetCount,
    Object? unit = _sentinel,
    Object? displayGoal = _sentinel,
    String? progressIconId,
    HabitKind? kind,
    Object? abstinenceStartedAt = _sentinel,
    int? bestAbstinenceSeconds,
    int? relapseCount,
    Object? reminderTime = _sentinel,
    Object? reminderMessage = _sentinel,
    int? order,
    DateTime? createdAt,
    Object? deletedAt = _sentinel,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    ambitoId: ambitoId ?? this.ambitoId,
    periodicityTimeline: periodicityTimeline ?? this.periodicityTimeline,
    colorValue: colorValue ?? this.colorValue,
    emoji: emoji ?? this.emoji,
    iconId: identical(iconId, _sentinel) ? this.iconId : iconId as String?,
    trackingType: trackingType ?? this.trackingType,
    targetCount: targetCount ?? this.targetCount,
    unit: identical(unit, _sentinel) ? this.unit : unit as String?,
    displayGoal: identical(displayGoal, _sentinel)
        ? this.displayGoal
        : displayGoal as String?,
    progressIconId: progressIconId ?? this.progressIconId,
    kind: kind ?? this.kind,
    abstinenceStartedAt: identical(abstinenceStartedAt, _sentinel)
        ? this.abstinenceStartedAt
        : abstinenceStartedAt as DateTime?,
    bestAbstinenceSeconds: bestAbstinenceSeconds ?? this.bestAbstinenceSeconds,
    relapseCount: relapseCount ?? this.relapseCount,
    reminderTime: identical(reminderTime, _sentinel)
        ? this.reminderTime
        : reminderTime as String?,
    reminderMessage: identical(reminderMessage, _sentinel)
        ? this.reminderMessage
        : reminderMessage as String?,
    order: order ?? this.order,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: identical(deletedAt, _sentinel)
        ? this.deletedAt
        : deletedAt as DateTime?,
  );
  @override
  bool operator ==(Object other) =>
      other is Habit &&
      id == other.id &&
      name == other.name &&
      ambitoId == other.ambitoId &&
      listEquals(periodicityTimeline, other.periodicityTimeline) &&
      colorValue == other.colorValue &&
      emoji == other.emoji &&
      iconId == other.iconId &&
      trackingType == other.trackingType &&
      targetCount == other.targetCount &&
      unit == other.unit &&
      displayGoal == other.displayGoal &&
      progressIconId == other.progressIconId &&
      kind == other.kind &&
      abstinenceStartedAt == other.abstinenceStartedAt &&
      bestAbstinenceSeconds == other.bestAbstinenceSeconds &&
      relapseCount == other.relapseCount &&
      reminderTime == other.reminderTime &&
      reminderMessage == other.reminderMessage &&
      order == other.order &&
      createdAt == other.createdAt &&
      deletedAt == other.deletedAt;
  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    ambitoId,
    Object.hashAll(periodicityTimeline),
    colorValue,
    emoji,
    iconId,
    trackingType,
    targetCount,
    unit,
    displayGoal,
    progressIconId,
    kind,
    abstinenceStartedAt,
    bestAbstinenceSeconds,
    relapseCount,
    reminderTime,
    reminderMessage,
    order,
    createdAt,
    deletedAt,
  ]);
}

const _sentinel = Object();
