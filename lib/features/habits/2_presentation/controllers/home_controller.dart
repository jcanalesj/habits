import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';

/// Estado de la Home, alimentado por snapshots del repositorio: cualquier
/// escritura (local u otro dispositivo) se refleja sola, sin recargas.
///
/// La racha llega ya calculada en vivo desde la fuente de verdad; el
/// controller solo sincroniza la proyección de `cache/rachas` cuando cambia.
class HomeController extends StreamNotifier<HomeSummary> {
  @override
  Stream<HomeSummary> build() {
    // Concesión mensual perezosa: al abrir la app se ponen al día los
    // comodines gratuitos pendientes. Es idempotente y no bloquea la Home.
    ref.listen(todayProvider, (previous, next) {
      if (previous == next) return;
      _grantPendingWildcards(next);
    }, fireImmediately: true);

    return ref
        .watch(watchHomeSummaryUsecaseProvider)
        .execute()
        .map(_syncCacheAndPass);
  }

  Future<void> _grantPendingWildcards(LogicalDate today) async {
    await ref.read(ensureMonthlyWildcardGrantUsecaseProvider).execute(today);
  }

  HomeSummary _syncCacheAndPass(HomeSummary summary) {
    // Escribe la proyección en segundo plano. Si falla no pasa nada: la
    // racha que se muestra se ha calculado desde los registros, no de aquí.
    unawaited(
      ref
          .read(rebuildStreakUsecaseProvider)
          .syncCache(summary.streak, summary.today),
    );
    return summary;
  }

  /// Marca o desmarca el cumplimiento de HOY para [habitId].
  ///
  /// Solo se puede registrar hoy: no existen registros retroactivos (§14).
  Future<ToggleHabitCompletionResult?> toggleToday(String habitId) async {
    final summary = state.value;
    if (summary == null) return null;

    final today = summary.today;
    return ref
        .read(toggleHabitCompletionUsecaseProvider)
        .execute(
          habitId: habitId,
          date: today,
          completed: !summary.isCompletedOn(habitId, today),
          today: today,
        );
  }

  Future<bool> setTodayCount(String habitId, int count) async {
    final summary = state.value;
    if (summary == null) return false;
    final habit = summary.habits
        .where((item) => item.id == habitId)
        .firstOrNull;
    if (habit == null || !habit.hasRepetitions) return false;
    final existingTarget = summary.weekLogs
        .where((log) => log.habitId == habitId && log.date == summary.today)
        .firstOrNull
        ?.targetCount;
    try {
      await ref
          .read(habitsRepositoryProvider)
          .setHabitDailyCount(
            habitId: habitId,
            date: summary.today,
            completedCount: count,
            targetCount: existingTarget ?? habit.targetCount,
          );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Gasta un comodín para proteger el día en peligro.
  ///
  /// El comodín nunca se consume solo: esto solo se llama desde una acción
  /// explícita del usuario (§24).
  Future<UseWildcardResult?> useWildcard() async {
    final summary = state.value;
    final rescue = summary?.streak.rescue;
    if (summary == null || rescue == null) return null;
    if (!summary.wildcards.hasAny) {
      return UseWildcardFailed(WildcardFailure.noneAvailable);
    }

    return ref
        .read(useWildcardUsecaseProvider)
        .execute(
          day: rescue.day,
          today: summary.today,
          // El día en peligro es por definición un día sin actividad; se pasa
          // el conjunto para que el usecase lo verifique igualmente.
          activityDays: {
            for (final log in summary.weekLogs)
              if (log.isActivity) log.date,
          },
        );
  }
}

/// autoDispose: muere con la Home (p. ej. al cerrar sesión) para que no
/// queden suscripciones a Firestore ni cadenas de providers obsoletas.
final homeControllerProvider =
    StreamNotifierProvider.autoDispose<HomeController, HomeSummary>(
      HomeController.new,
    );
