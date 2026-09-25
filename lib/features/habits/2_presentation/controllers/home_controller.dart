import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/app_lifecycle.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
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

  /// Última Home pendiente de sincronizar con los recordatorios. Las
  /// sincronizaciones van de una en una: dos a la vez se pisarían (una
  /// cancela todo mientras la otra aún está programando).
  HomeSummary? _pendingReminders;
  bool _syncingReminders = false;

  /// Última racha enviada a `cache/rachas`. Evita leer y escribir la caché
  /// en cada emisión: solo cuando cambia la racha o el día.
  String? _cachedStreakKey;

  /// Hábitos con una escritura de hoy en curso: un doble toque rápido no
  /// debe lanzar dos escrituras (la segunda llegaría como update y las
  /// reglas la rechazarían aunque el registro ya se hubiera creado).
  final _togglesInFlight = <String>{};

  @override
  Stream<HomeSummary> build() {
    ref.watch(premiumAccessProvider);
    // El día sale del provider que se refresca solo a medianoche y al volver
    // de segundo plano: al cambiar, la Home se recalcula entera.
    final today = ref.watch(todayProvider);
    // Concesión mensual perezosa: al abrir la app se ponen al día los
    // comodines gratuitos pendientes. Es idempotente y no bloquea la Home.
    ref.listen(todayProvider, (previous, next) {
      if (previous == next) return;
      _grantPendingWildcards();
    }, fireImmediately: true);
    // Permisos o zona pueden haber cambiado fuera de la app: se fuerza la
    // resincronización aunque la Home no haya cambiado. De paso se reintenta
    // la concesión, por si el mes del servidor ha cambiado con la app en
    // segundo plano.
    ref.listen(systemStateTickProvider, (_, _) {
      resyncReminders();
      _grantPendingWildcards();
    });

    return ref
        .watch(watchHomeSummaryUsecaseProvider)
        .execute(today: today)
        .map(_syncCacheAndPass);
  }

  /// El mes de la concesión es el del SERVIDOR (UTC), que es con el que
  /// validan las reglas. Con el de la zona del perfil, en Madrid el día 1 a
  /// las 00:30 se pedía un mes que el servidor aún no había empezado y la
  /// concesión se rechazaba.
  Future<void> _grantPendingWildcards() async {
    final serverMonthDay = LogicalCalendar(
      LogicalCalendar.fallbackTimezone,
    ).dateOf(ref.read(clockProvider).nowUtc());
    await ref
        .read(ensureMonthlyWildcardGrantUsecaseProvider)
        .execute(serverMonthDay);
  }

  HomeSummary _syncCacheAndPass(HomeSummary summary) {
    // Escribe la proyección en segundo plano. Si falla no pasa nada: la
    // racha que se muestra se ha calculado desde los registros, no de aquí.
    final streak = summary.streak;
    final cacheKey =
        '${summary.today.key}|${streak.currentStreak}|${streak.bestStreak}'
        '|${streak.lastActivityDay?.key}';
    if (cacheKey != _cachedStreakKey) {
      _cachedStreakKey = cacheKey;
      unawaited(
        ref.read(rebuildStreakUsecaseProvider).syncCache(streak, summary.today),
      );
    }
    _requestReminderSync(summary);
    return summary;
  }

  /// Vuelve a evaluar los recordatorios sin que la Home haya cambiado: tras
  /// conceder el permiso o al volver de segundo plano. La huella incluye el
  /// permiso y la zona, así que si nada ha cambiado no se reprograma.
  void resyncReminders() {
    final summary = state.value;
    if (summary != null) _requestReminderSync(summary);
  }

  void _requestReminderSync(HomeSummary summary) {
    _pendingReminders = summary;
    if (_syncingReminders) return;
    unawaited(_drainReminderSyncs());
  }

  Future<void> _drainReminderSyncs() async {
    _syncingReminders = true;
    try {
      while (_pendingReminders != null && ref.mounted) {
        final summary = _pendingReminders!;
        _pendingReminders = null;
        await _syncReminders(summary);
      }
    } finally {
      _syncingReminders = false;
    }
  }

  /// Solo depende de lo que cambia el plan de avisos: el día, la zona, el
  /// permiso y, por cada hábito, su hora, su nombre, si ya está hecho hoy y
  /// si el objetivo del periodo está cumplido.
  static String _fingerprintOf(
    HomeSummary summary, {
    required bool isPremium,
    required String timezone,
    required NotificationPermission permission,
  }) => [
    summary.today.key,
    timezone,
    permission.name,
    isPremium,
    for (final habit in summary.habits)
      '${habit.id}|${habit.reminderTime}|${habit.reminderMessage}|${habit.name}'
          '|${summary.isCompletedOn(habit.id, summary.today)}'
          '|${summary.progressOf(habit.id)?.isMet}',
  ].join('~');

  Future<void> _syncReminders(HomeSummary summary) async {
    // Sin la zona del perfil los avisos saldrían en UTC. Cuando llegue, el
    // repositorio se recrea, la Home vuelve a emitir y se programa bien.
    if (!ref.read(profileTimezoneProvider).hasValue) return;

    final isPremium = ref.read(premiumAccessProvider);
    final calendar = ref.read(logicalCalendarProvider);
    final NotificationPermission permission;
    try {
      permission = await ref
          .read(notificationsRepositoryProvider)
          .currentPermission();
    } catch (_) {
      return;
    }
    if (!ref.mounted) return;

    final fingerprint = _fingerprintOf(
      summary,
      isPremium: isPremium,
      timezone: calendar.timezoneName,
      permission: permission,
    );
    if (fingerprint == _remindersFingerprint) return;

    final l10n = await AppLocalizations.delegate.load(_deviceLocale());
    if (!ref.mounted) return;

    final now = ref.read(clockProvider).nowUtc();
    final localNow = calendar.dateOf(now);

    await ref
        .read(syncRemindersUsecaseProvider)
        .execute(
          habits: summary.habits,
          today: summary.today,
          nowMinutes: localNow == summary.today
              ? calendar.minutesOfDay(now)
              : 0,
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
          body: (reminder) => isPremium
              ? reminder.customMessage ?? l10n.reminderNotificationBody
              : l10n.reminderNotificationBody,
        );
    // La huella se guarda al terminar: si algo falla antes, el siguiente
    // intento vuelve a programar en vez de dar por buena una sincronización
    // que no llegó a hacerse.
    _remindersFingerprint = fingerprint;
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

  /// La Home solo vale para escribir si su "hoy" sigue siendo hoy. Si el día
  /// ha cambiado (la app llevaba horas abierta), se fuerza el recálculo y
  /// la acción se descarta: registrar sobre el día anterior sería un
  /// registro retroactivo (§14).
  HomeSummary? _currentSummary() {
    final summary = state.value;
    if (summary == null) return null;
    final realToday = ref
        .read(logicalCalendarProvider)
        .dateOf(ref.read(clockProvider).nowUtc());
    if (realToday != summary.today) {
      ref.invalidate(todayProvider);
      return null;
    }
    return summary;
  }

  /// Marca o desmarca el cumplimiento de HOY para [habitId].
  ///
  /// Solo se puede registrar hoy: no existen registros retroactivos (§14).
  Future<ToggleHabitCompletionResult?> toggleToday(String habitId) async {
    final summary = _currentSummary();
    if (summary == null || !_togglesInFlight.add(habitId)) return null;

    final today = summary.today;
    try {
      return await ref
          .read(toggleHabitCompletionUsecaseProvider)
          .execute(
            habitId: habitId,
            date: today,
            completed: !summary.isCompletedOn(habitId, today),
            today: today,
          );
    } finally {
      _togglesInFlight.remove(habitId);
    }
  }

  /// Null si no se ha intentado (la Home estaba desfasada o el hábito no
  /// admite repeticiones); false si la escritura ha fallado.
  Future<bool?> setTodayCount(String habitId, int count) async {
    final summary = _currentSummary();
    if (summary == null) return null;
    final habit = summary.habits
        .where((item) => item.id == habitId)
        .firstOrNull;
    if (habit == null || !habit.hasRepetitions) return null;
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
  /// Devuelve false si no se ha podido guardar.
  Future<bool> reorderHabitsInAmbito(
    String ambitoId,
    int oldIndex,
    int newIndex,
  ) async {
    final summary = state.value;
    if (summary == null) return true;
    final habits = [
      for (final habit in summary.habits)
        if (habit.ambitoId == ambitoId) habit,
    ];
    if (oldIndex < 0 || oldIndex >= habits.length) return true;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0 || newIndex >= habits.length || oldIndex == newIndex) {
      return true;
    }

    final availableOrders = habits.map((habit) => habit.order).toList()..sort();
    final moved = habits.removeAt(oldIndex);
    habits.insert(newIndex, moved);
    try {
      await ref.read(habitsRepositoryProvider).reorderHabits({
        for (var index = 0; index < habits.length; index++)
          if (habits[index].order != availableOrders[index])
            habits[index].id: availableOrders[index],
      });
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
    final summary = _currentSummary();
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
