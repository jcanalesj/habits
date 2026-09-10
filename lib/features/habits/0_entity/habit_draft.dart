import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';

part 'habit_draft.freezed.dart';

/// Datos que aporta el usuario para crear un hábito.
@freezed
abstract class HabitDraft with _$HabitDraft {
  const factory HabitDraft({
    required String name,
    required String ambitoId,
    required Periodicity periodicity,
    @Default(0) int restDaysAllowed,
    String? recoveryTask,
    @Default(7) int recoveryCooldownDays,
    required int colorValue,
    required String emoji,
    String? reminderTime,
  }) = _HabitDraft;
}
