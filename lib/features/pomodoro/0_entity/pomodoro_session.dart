import 'package:habits/features/habits/0_entity/logical_date.dart';

/// Una fase de concentración completada. Los descansos no se registran y
/// las fases saltadas tampoco.
class PomodoroSession {
  const PomodoroSession({
    required this.id,
    required this.day,
    required this.startedAt,
    required this.durationMinutes,
    this.label,
  });

  final String id;

  /// Día lógico en el que terminó.
  final LogicalDate day;
  final DateTime startedAt;
  final int durationMinutes;
  final String? label;

  static const maxLabelLength = 60;

  @override
  bool operator ==(Object other) =>
      other is PomodoroSession &&
      other.id == id &&
      other.day == day &&
      other.startedAt == startedAt &&
      other.durationMinutes == durationMinutes &&
      other.label == label;

  @override
  int get hashCode => Object.hash(id, day, startedAt, durationMinutes, label);
}
