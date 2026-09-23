import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/gen/app_localizations.dart';

/// Estado de la Home, alimentado por snapshots del repositorio: cualquier
/// escritura (local u otro dispositivo) se refleja sola, sin recargas.
///
/// La racha llega ya calculada en vivo desde la fuente de verdad; el
/// controller solo sincroniza la proyección de `cache/rachas` cuando cambia.
///
/// También es quien mantiene al día los recordatorios del sistema: ve pasar
/// los cambios de hábitos y de registros, que es justo lo que decide qué hay
/// que avisar.
class HomeController extends StreamNotifier<HomeSummary> {
  /// Huella de lo último que se programó, para no reprogramar en cada
  /// emisión del stream (cancelar y volver a crear decenas de avisos no es
  /// gratis).
  String? _remindersFingerprint;

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
    unawaited(_syncReminders(summary));
    return summary;
  }

  /// Solo depende de lo que cambia el plan de avisos: el día, y por cada
  /// hábito su hora, su nombre, si ya está hecho hoy y si el objetivo del
  /// periodo está cumplido.
  static String _fingerprintOf(HomeSummary summary) => [
    summary.today.key,
    for (final habit in summary.habits)
      '${habit.id}|${habit.reminderTime}|${habit.name}'
          '|${summary.isCompletedOn(habit.id, summary.today)}'
          '|${summary.progressOf(habit.id)?.isMet}',
  ].join('~');

  Future<void> _syncReminders(HomeSummary summary) async {
    final fingerprint = _fingerprintOf(summary);
    if (fingerprint == _remindersFingerprint) return;
    _remindersFingerprint = fingerprint;

    final l10n = await AppLocalizations.delegate.load(_deviceLocale());
    if (!ref.mounted) return;

    final now = ref.read(clockProvider).nowUtc();
    final calendar = ref.read(logicalCalendarProvider);
    final localNow = calendar.dateOf(now);

    await ref
        .read(syncRemindersUsecaseProvider)
        .execute(
          habits: summary.habits,
          today: summary.today,
          nowMinutes: _minutesOfDay(summary, localNow),
          timezone: calendar.timezoneName,
          completedDays: {
            for (final habit in summary.habits)
              habit.id: {
                for (final log in summary.weekLogs)
                  if (log.habitId == habit.id && log.isActivity) log.date,
              },
          },
          isGoalMetOn: (habit, day) {
            final progress = summary.progressOf(habit.id);
            // Del progreso de periodos futuros no sabemos nada todavía, así
            // que solo se salta el periodo en curso.
            if (progress == null || !progress.isMet) return false;
            return progress.period.contains(day);
          },
          title: (reminder) =>
              l10n.reminderNotificationTitle(reminder.habitName),
          body: (reminder) => l10n.reminderNotificationBody,
        );
  }

  /// Idioma con el que se redactan las notificaciones.
  ///
  /// La app no fija `locale` en MaterialApp, así que usa el del sistema;
  /// aquí se resuelve igual para que el aviso llegue en el mismo idioma que
  /// ve el usuario en pantalla.
  static Locale _deviceLocale() {
    final device = PlatformDispatcher.instance.locale;
    return AppLocalizations.supportedLocales.firstWhere(
      (locale) => locale.languageCode == device.languageCode,
      orElse: () => const Locale('es'),
    );
  }

  /// Minutos transcurridos del día de hoy, para no programar avisos de una
  /// hora que ya pasó.
  int _minutesOfDay(HomeSummary summary, LogicalDate localToday) {
    if (localToday != summary.today) return 0;
    final calendar = ref.read(logicalCalendarProvider);
    final startOfDay = calendar.startOfDayUtc(summary.today);
    final elapsed = ref.read(clockProvider).nowUtc().difference(startOfDay);
    return elapsed.inMinutes.clamp(0, 24 * 60);
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

  /// Reordena los hábitos dentro de un ámbito y persiste el nuevo orden.
  Future<void> reorderHabitsInAmbito(
    String ambitoId,
    int oldIndex,
    int newIndex,
  ) async {
    final summary = state.value;
    if (summary == null) return;
    final habits = [
      for (final habit in summary.habits)
        if (habit.ambitoId == ambitoId) habit,
    ];
    if (oldIndex < 0 || oldIndex >= habits.length) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0 || newIndex >= habits.length || oldIndex == newIndex) {
      return;
    }

    final availableOrders = habits.map((habit) => habit.order).toList()..sort();
    final moved = habits.removeAt(oldIndex);
    habits.insert(newIndex, moved);
    final repository = ref.read(habitsRepositoryProvider);
    await Future.wait([
      for (var index = 0; index < habits.length; index++)
        if (habits[index].order != availableOrders[index])
          repository.updateHabit(
            habits[index].copyWith(order: availableOrders[index]),
          ),
    ]);
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
