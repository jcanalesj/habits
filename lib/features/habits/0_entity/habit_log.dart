import 'package:flutter/foundation.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

enum HabitLogType { completed, legacy }

@immutable
class HabitLog {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    this.type = HabitLogType.completed,
    this.completedCount = 1,
    this.targetCount = 1,
  });
  final String id, habitId;
  final LogicalDate date;
  final HabitLogType type;
  final int completedCount, targetCount;
  bool get isActivity =>
      type == HabitLogType.completed && completedCount >= targetCount;
  @override
  bool operator ==(Object other) =>
      other is HabitLog &&
      id == other.id &&
      habitId == other.habitId &&
      date == other.date &&
      type == other.type &&
      completedCount == other.completedCount &&
      targetCount == other.targetCount;
  @override
  int get hashCode =>
      Object.hash(id, habitId, date, type, completedCount, targetCount);
}
