import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

part 'habit_log.freezed.dart';

/// Tipo de registro.
///
/// Desde la fase 5 la app solo produce [completed]. [legacy] agrupa los
/// tipos del modelo anterior (`recovery`, `plannedRest`), que se conservan
/// intactos en Firestore pero **no cuentan como actividad real** para la
/// racha general: solo cuenta un hábito realmente completado.
enum HabitLogType { completed, legacy }

/// Registro de cumplimiento. Los registros son la FUENTE DE VERDAD: la
/// racha general y el progreso de objetivos se derivan íntegramente de
/// ellos y deben poder reconstruirse desde cero (§2).
@freezed
abstract class HabitLog with _$HabitLog {
  const factory HabitLog({
    required String id,
    required String habitId,

    /// Día lógico, ya resuelto en la zona horaria del perfil en el momento
    /// de crear el registro. Es inmutable: un cambio posterior de zona
    /// horaria no reinterpreta el pasado (§13).
    required LogicalDate date,
    @Default(HabitLogType.completed) HabitLogType type,
  }) = _HabitLog;

  const HabitLog._();

  /// Si este registro cuenta como actividad real del usuario ese día.
  bool get isActivity => type == HabitLogType.completed;
}
