import 'package:habits/features/habits/0_entity/entity.dart';

/// Contrato de datos de la feature de hábitos, scoped al usuario con sesión.
///
/// - Los `watch*` emiten el estado actual al suscribirse y cada cambio
///   (en Firestore, snapshots con compensación de latencia: la UI ve las
///   escrituras locales al instante, también sin red).
/// - Los REGISTROS son la fuente de verdad; las rachas ([watchStreaks]) son
///   una caché derivada que puede no existir.
/// - Las escrituras son idempotentes y compatibles con funcionamiento
///   offline (sin transacciones; batches cuando hace falta atomicidad).
///
/// Los fallos se lanzan como [HabitsException].
abstract class HabitsRepository {
  Stream<List<Ambito>> watchAmbitos();

  /// Hábitos sin soft delete, ordenados por [Habit.order].
  Stream<List<Habit>> watchActiveHabits();

  /// Registros con día lógico dentro de [from, to], ambos inclusive, de
  /// todos los hábitos (también los eliminados).
  Stream<List<HabitLog>> watchLogsBetween(DateTime from, DateTime to);

  /// Caché de rachas; [StreaksSnapshot.empty] si no existe.
  Stream<StreaksSnapshot> watchStreaks();

  /// Registros de un hábito, opcionalmente acotados por día lógico.
  Future<List<HabitLog>> fetchHabitLogs(
    String habitId, {
    DateTime? from,
    DateTime? to,
  });

  /// Hábito por id, incluidos los eliminados. Null si no existe.
  Future<Habit?> getHabit(String habitId);

  Future<Habit> createHabit(HabitDraft draft);

  /// Actualiza los campos editables de [habit] (incluido su historial de
  /// periodicidad y `deletedAt`).
  Future<void> updateHabit(Habit habit);

  /// Soft delete: marca `deletedAt`. Los registros históricos se conservan.
  Future<void> softDeleteHabit(String habitId);

  Future<Ambito> createAmbito(AmbitoDraft draft);

  Future<void> updateAmbito(Ambito ambito);

  /// Elimina un ámbito personalizado reasignando sus hábitos (activos y
  /// eliminados, para no dejar referencias colgando) a General en la misma
  /// operación atómica. Lanza [HabitsFailure.generalAmbitoProtected] para
  /// General.
  Future<void> deleteAmbito(String ambitoId);

  /// Marca o desmarca el cumplimiento de un hábito en un día lógico.
  /// Idempotente: marcar dos veces no duplica ni falla; desmarcar algo no
  /// marcado no hace nada.
  Future<void> setHabitCompletion({
    required String habitId,
    required DateTime date,
    required bool completed,
    HabitLogType type = HabitLogType.completed,
  });
}
