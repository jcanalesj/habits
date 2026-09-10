import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/periodicity.dart';

part 'periodicity_change.freezed.dart';

/// Cambio de periodicidad de un hábito (doc funcional §4.3): la racha se
/// recalcula desde [since] con las reglas de la nueva periodicidad.
@freezed
abstract class PeriodicityChange with _$PeriodicityChange {
  const factory PeriodicityChange({
    required Periodicity periodicity,

    /// Día lógico desde el que aplica.
    required DateTime since,
  }) = _PeriodicityChange;
}
