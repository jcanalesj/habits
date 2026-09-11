import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';

part 'habit_draft.freezed.dart';

/// Datos que aporta el usuario para crear un hábito. La periodicidad
/// inicial pasa a ser la primera entrada de su línea temporal.
@freezed
abstract class HabitDraft with _$HabitDraft {
  const factory HabitDraft({
    required String name,
    required String ambitoId,
    @Default(Periodicity.daily) Periodicity periodicity,
    required int colorValue,
    required String emoji,
    String? reminderTime,
  }) = _HabitDraft;
}
