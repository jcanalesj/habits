import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/repositories/wildcards_repository.dart';
import 'package:habits/features/habits/1_domain/services/streak_calculator.dart';

/// Reconstruye la racha general desde la FUENTE DE VERDAD y refresca la
/// proyección de `cache/rachas`.
///
/// Demuestra el invariante de la fase 5: la caché se puede borrar entera y
/// volver a calcularse a partir de los registros y de los días protegidos,
/// sin perder nada (§31). La caché nunca decide: solo se escribe.
class RebuildStreakUsecase {
  const RebuildStreakUsecase(this._habits, this._wildcards);

  final HabitsRepository _habits;
  final WildcardsRepository _wildcards;

  /// Recalcula desde cero y guarda el resultado. Idempotente: dos
  /// ejecuciones seguidas con los mismos datos dan el mismo estado y la
  /// segunda no escribe nada.
  Future<StreakState> execute(LogicalDate today) async {
    final activityDays = await _habits.fetchActivityDays();
    final protectedDays = await _wildcards.fetchProtectedDays();

    final state = StreakCalculator.calculate(
      activityDays: activityDays,
      protectedDays: protectedDays,
      today: today,
    );

    await syncCache(state, today);
    return state;
  }

  /// Escribe la proyección solo si cambió algo, para no generar una
  /// escritura por cada recálculo.
  Future<void> syncCache(StreakState state, LogicalDate today) async {
    final entry = StreakCacheEntry(
      currentStreak: state.currentStreak,
      bestStreak: state.bestStreak,
      lastActivityDay: state.lastActivityDay,
      calculatedThrough: today,
      algorithmVersion: StreakCalculator.algorithmVersion,
    );
    try {
      final existing = await _habits.fetchStreakCache();
      if (existing == entry) return;
      await _habits.saveStreakCache(entry);
    } catch (_) {
      // La caché es prescindible: si no se puede escribir, la app sigue
      // funcionando porque la racha se calcula en vivo. Nunca propaga.
    }
  }
}
