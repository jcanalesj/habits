import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

part 'periodicity.freezed.dart';

/// Tipo de periodo sobre el que se mide el objetivo de un hábito.
///
/// No hay selección de días concretos: los objetivos son flexibles (§8).
/// "3 veces por semana" se cumple igual lunes/miércoles/viernes que
/// martes/jueves/domingo.
enum PeriodicityType { daily, weekly, monthly, yearly }

/// Objetivo de un hábito: cuántas veces hay que completarlo dentro de su
/// periodo. `daily` significa una vez cada día.
///
/// La periodicidad NO interviene en el cálculo de la racha general (§5).
/// Solo sirve para mostrar el objetivo, el progreso del periodo, las
/// estadísticas y el futuro sistema de rangos (§7).
@freezed
abstract class Periodicity with _$Periodicity {
  const factory Periodicity({
    required PeriodicityType type,
    @Default(1) int timesPerPeriod,
  }) = _Periodicity;

  const Periodicity._();

  static const daily = Periodicity(type: PeriodicityType.daily);

  /// `daily` siempre es 1 vez al día, sea cual sea el valor almacenado.
  int get target => type == PeriodicityType.daily ? 1 : timesPerPeriod;
}

/// Una configuración de periodicidad con la fecha desde la que está
/// vigente. `since` puede ser **futura**: así se representa un cambio
/// diferido sin necesidad de ninguna escritura posterior de "promoción"
/// (§10/§11).
@freezed
abstract class PeriodicityEntry with _$PeriodicityEntry {
  const factory PeriodicityEntry({
    required Periodicity periodicity,
    required LogicalDate since,
  }) = _PeriodicityEntry;
}
