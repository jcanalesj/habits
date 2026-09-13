import 'package:habits/features/habits/0_entity/entity.dart';

/// Contrato de datos de la feature de hábitos, scoped al usuario con sesión.
///
/// - Los `watch*` emiten el estado actual al suscribirse y cada cambio
///   (en Firestore, snapshots con compensación de latencia: la UI ve las
///   escrituras locales al instante, también sin red).
/// - Los REGISTROS son la fuente de verdad. La racha se calcula siempre a
///   partir de ellos; [watchStreakCache] es una proyección reconstruible que
///   nunca decide nada (§2/§31).
/// - Las escrituras de datos normales son idempotentes y offline-first.
///
/// Los fallos se lanzan como [HabitsException].
abstract class HabitsRepository {
  Stream<List<Ambito>> watchAmbitos();

  /// Hábitos sin soft delete, ordenados por [Habit.order].
  Stream<List<Habit>> watchActiveHabits();

  /// Registros con día lógico dentro de [from, to], ambos inclusive, de
  /// todos los hábitos (también los eliminados).
  Stream<List<HabitLog>> watchLogsBetween(LogicalDate from, LogicalDate to);

  /// Conjunto de días con AL MENOS un hábito realmente completado, sobre el
  /// histórico completo y de todos los hábitos, incluidos los eliminados
  /// con soft delete (§30).
  ///
  /// Es la entrada de la que el motor reconstruye la racha. Se expone como
  /// conjunto de días y no como lista de registros porque al motor solo le
  /// importa si el día tuvo actividad, no cuántos hábitos se completaron
  /// (§4).
  Stream<Set<LogicalDate>> watchActivityDays();

  /// Igual que [watchActivityDays] pero de un solo tiro, para reconstruir
  /// la caché desde cero.
  Future<Set<LogicalDate>> fetchActivityDays();

  /// Caché de racha; null si no existe. Es solo una proyección.
  Stream<StreakCacheEntry?> watchStreakCache();

  Future<StreakCacheEntry?> fetchStreakCache();

  /// Escribe la proyección. Nunca es autoridad: se puede borrar entera y
  /// reconstruir desde los registros y los días protegidos (§31).
  Future<void> saveStreakCache(StreakCacheEntry entry);

  /// Borra la caché. La app debe seguir funcionando sin ella.
  Future<void> clearStreakCache();

  /// Registros de un hábito, opcionalmente acotados por día lógico. Es lo
  /// que alimentará la vista calendario por hábito (§6).
  Future<List<HabitLog>> fetchHabitLogs(
    String habitId, {
    LogicalDate? from,
    LogicalDate? to,
  });

  /// Hábito por id, incluidos los eliminados. Null si no existe.
  Future<Habit?> getHabit(String habitId);

  Future<Habit> createHabit(HabitDraft draft, {required LogicalDate today});

  /// Actualiza los campos editables de [habit] (incluida su línea temporal
  /// de periodicidad y `deletedAt`).
  Future<void> updateHabit(Habit habit);

  /// Soft delete: marca `deletedAt`. Los registros históricos se conservan.
  Future<void> softDeleteHabit(String habitId);

  Future<Ambito> createAmbito(AmbitoDraft draft);

  Future<void> updateAmbito(Ambito ambito);

  /// Elimina un ámbito personalizado reasignando sus hábitos (activos y
  /// eliminados, para no dejar referencias colgando) a General en la misma
  /// operación atómica.
  Future<void> deleteAmbito(String ambitoId);

  /// Marca o desmarca el cumplimiento de un hábito en un día lógico.
  /// Idempotente: marcar dos veces no duplica ni falla; desmarcar algo no
  /// marcado no hace nada.
  ///
  /// El use case garantiza que [date] es siempre HOY según la zona horaria
  /// del perfil: no se admiten registros retroactivos (§14).
  Future<void> setHabitCompletion({
    required String habitId,
    required LogicalDate date,
    required bool completed,
  });

  /// Guarda el contador diario de un hábito con repeticiones. Un contador
  /// cero elimina el documento; el objetivo se copia al registro para que el
  /// historial conserve la configuración vigente en ese momento.
  Future<void> setHabitDailyCount({
    required String habitId,
    required LogicalDate date,
    required int completedCount,
    required int targetCount,
  });
}

/// Contenido de `users/{uid}/cache/rachas`. Proyección pura.
class StreakCacheEntry {
  const StreakCacheEntry({
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActivityDay,
    required this.calculatedThrough,
    required this.algorithmVersion,
  });

  final int currentStreak;
  final int bestStreak;
  final LogicalDate? lastActivityDay;

  /// Último día lógico incluido en el cálculo.
  final LogicalDate calculatedThrough;

  /// Versión del algoritmo con la que se calculó. Si no coincide con
  /// [StreakCalculator.algorithmVersion] la caché se descarta.
  final int algorithmVersion;

  @override
  bool operator ==(Object other) =>
      other is StreakCacheEntry &&
      other.currentStreak == currentStreak &&
      other.bestStreak == bestStreak &&
      other.lastActivityDay == lastActivityDay &&
      other.calculatedThrough == calculatedThrough &&
      other.algorithmVersion == algorithmVersion;

  @override
  int get hashCode => Object.hash(
    currentStreak,
    bestStreak,
    lastActivityDay,
    calculatedThrough,
    algorithmVersion,
  );
}
