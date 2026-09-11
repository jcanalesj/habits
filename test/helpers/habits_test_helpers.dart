import 'package:habits/features/habits/0_entity/entity.dart';

/// Borrador de hábito válido para tests.
HabitDraft habitDraft({
  String name = 'Beber agua',
  String ambitoId = 'salud',
  Periodicity periodicity = Periodicity.daily,
  String? reminderTime,
}) => HabitDraft(
  name: name,
  ambitoId: ambitoId,
  periodicity: periodicity,
  colorValue: 0xFF38BDF8,
  emoji: '💧',
  reminderTime: reminderTime,
);

/// Borrador de ámbito válido para tests.
const ambitoDraft = AmbitoDraft(
  name: 'Música',
  emoji: '🎸',
  colorValue: 0xFFF16A8F,
);

/// Día lógico a partir de sus componentes.
LogicalDate day(int y, int m, int d) => LogicalDate(y, m, d);
