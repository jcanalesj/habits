import 'package:habits/features/habits/0_entity/entity.dart';

/// Borrador de hábito válido para tests.
HabitDraft habitDraft({
  String name = 'Beber agua',
  String ambitoId = 'salud',
  Periodicity periodicity = Periodicity.daily,
  String? reminderTime,
  HabitTrackingType trackingType = HabitTrackingType.single,
  int targetCount = 1,
  String? unit,
  String? displayGoal,
  String progressIconId = 'check',
  String? iconId = 'water_drop',
}) => HabitDraft(
  name: name,
  ambitoId: ambitoId,
  periodicity: periodicity,
  colorValue: 0xFF38BDF8,
  emoji: '💧',
  iconId: iconId,
  reminderTime: reminderTime,
  trackingType: trackingType,
  targetCount: targetCount,
  unit: unit,
  displayGoal: displayGoal,
  progressIconId: progressIconId,
);

/// Borrador de ámbito válido para tests.
const ambitoDraft = AmbitoDraft(
  name: 'Música',
  emoji: '🎸',
  colorValue: 0xFFF16A8F,
);

/// Día lógico a partir de sus componentes.
LogicalDate day(int y, int m, int d) => LogicalDate(y, m, d);
