import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/general_streak.dart';

part 'streaks_snapshot.freezed.dart';

/// Racha de un hábito, derivada de sus registros.
@freezed
abstract class HabitStreak with _$HabitStreak {
  const factory HabitStreak({@Default(0) int current, @Default(0) int best}) =
      _HabitStreak;
}

/// Racha y comodín de un ámbito, derivados de los registros de sus hábitos.
@freezed
abstract class AmbitoStreak with _$AmbitoStreak {
  const factory AmbitoStreak({
    @Default(0) int current,
    @Default(0) int best,
    @Default(true) bool comodinDisponible,
  }) = _AmbitoStreak;
}

/// Caché de rachas (`users/{uid}/cache/rachas`). Es un dato DERIVADO y
/// reconstruible: la fuente de verdad son los registros. La app funciona
/// aunque no exista ([StreaksSnapshot.empty]).
@freezed
abstract class StreaksSnapshot with _$StreaksSnapshot {
  const factory StreaksSnapshot({
    @Default(GeneralStreak()) GeneralStreak general,
    @Default({}) Map<String, HabitStreak> habits,
    @Default({}) Map<String, AmbitoStreak> ambitos,

    /// Último día lógico incluido en el cálculo, o null si no hay caché.
    DateTime? calculatedThrough,
  }) = _StreaksSnapshot;

  const StreaksSnapshot._();

  static const empty = StreaksSnapshot();

  bool get isEmpty => calculatedThrough == null;

  HabitStreak habitStreak(String habitId) =>
      habits[habitId] ?? const HabitStreak();

  AmbitoStreak ambitoStreak(String ambitoId) =>
      ambitos[ambitoId] ?? const AmbitoStreak();
}
