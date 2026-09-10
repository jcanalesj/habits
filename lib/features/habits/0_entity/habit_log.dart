import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_log.freezed.dart';

/// Tipo de registro de cumplimiento (sección 9.1 del documento funcional).
enum HabitLogType { completed, recovery, plannedRest }

@freezed
abstract class HabitLog with _$HabitLog {
  const factory HabitLog({
    required String id,
    required String habitId,

    /// Día lógico: fecha normalizada a las 00:00 en zona horaria local.
    required DateTime date,
    @Default(HabitLogType.completed) HabitLogType type,
  }) = _HabitLog;
}
