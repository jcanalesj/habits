import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/app_lifecycle.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/pomodoro/0_entity/entity.dart';
import 'package:habits/features/pomodoro/1_domain/domain.dart';
import 'package:habits/features/pomodoro/2_presentation/providers/pomodoro_providers.dart';

/// Textos de las notificaciones de fin de fase, resueltos por la pantalla
/// (el controlador no conoce el idioma).
class PomodoroCopy {
  const PomodoroCopy({
    required this.workDoneTitle,
    required this.workDoneBody,
    required this.breakDoneTitle,
    required this.breakDoneBody,
  });

  final String workDoneTitle;
  final String Function(int nextMinutes) workDoneBody;
  final String breakDoneTitle;
  final String Function(int nextMinutes) breakDoneBody;
}

/// Motor del temporizador.
///
/// Reglas:
///  - el fin de fase es un instante ([PomodoroState.endAtUtc]); al pausar se
///    guarda lo que queda y al reanudar se recalcula el instante;
///  - cada arranque programa la notificación de fin y cada pausa, salto o
///    reinicio la cancela: así suena aunque la app esté cerrada;
///  - solo las fases de concentración completas se registran como sesión;
///  - al volver de segundo plano [syncClock] cierra la fase si ya venció.
class PomodoroController extends Notifier<PomodoroState> {
  late PomodoroRepository repository;
  late PomodoroStateStore store;
  late NotificationsRepository notifications;
  late Clock clock;
  late LogicalCalendar calendar;
  PomodoroConfig config = const PomodoroConfig();
  PomodoroCopy? copy;
  Timer? _ticker;

  static const tag = 'pomodoro';
  static final notificationId = HabitReminder.stableNotificationId(
    'pomodoro|end',
  );

  @override
  PomodoroState build() {
    // El temporizador sigue contando al salir de la pantalla: se mantiene
    // vivo mientras dure la sesión (session_cleanup lo invalida al salir).
    ref.keepAlive();
    ref.onDispose(() => _ticker?.cancel());
    repository = ref.watch(pomodoroRepositoryProvider);
    store = ref.watch(pomodoroStateStoreProvider);
    notifications = ref.read(notificationsRepositoryProvider);
    clock = ref.read(clockProvider);
    calendar = ref.watch(logicalCalendarProvider);
    config = ref.read(pomodoroConfigProvider).value ?? const PomodoroConfig();
    ref.listen(pomodoroConfigProvider, (_, next) {
      if (next.value case final loaded?) applyConfig(loaded);
    });
    ref.listen(systemStateTickProvider, (_, _) => syncClock());
    final saved = store.load();
    final initial = saved ?? PomodoroState.initial(config.workMinutes);
    if (initial.isRunning) {
      Future.microtask(syncClock);
      _startTicker();
    }
    return initial;
  }

  int _phaseSeconds(PomodoroPhase phase) =>
      60 *
      switch (phase) {
        PomodoroPhase.work => config.workMinutes,
        PomodoroPhase.shortBreak => config.shortBreakMinutes,
        PomodoroPhase.longBreak => config.longBreakMinutes,
      };

  void _set(PomodoroState next) {
    state = next;
    store.save(next);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Ajustes nuevos: si la fase actual está parada, adopta la duración
  /// nueva; en marcha o en pausa se respeta lo que ya estaba corriendo.
  void applyConfig(PomodoroConfig next) {
    config = next;
    if (state.isIdle) {
      final seconds = _phaseSeconds(state.phase);
      _set(state.copyWith(totalSeconds: seconds, remainingSeconds: seconds));
    }
  }

  void setLabel(String label) {
    if (label == state.label) return;
    _set(state.copyWith(label: label));
  }

  void start() {
    if (state.isRunning) return;
    final now = clock.nowUtc();
    final remaining = state.remainingSeconds > 0
        ? state.remainingSeconds
        : state.totalSeconds;
    final endAt = now.add(Duration(seconds: remaining));
    _set(
      state.copyWith(
        status: PomodoroStatus.running,
        remainingSeconds: remaining,
        endAtUtc: endAt,
      ),
    );
    _scheduleEndNotification(endAt);
    _startTicker();
  }

  void pause() {
    if (!state.isRunning) return;
    final remaining = _remainingNow();
    _stopTicker();
    _cancelEndNotification();
    _set(
      state.copyWith(
        status: PomodoroStatus.paused,
        remainingSeconds: remaining,
        clearEndAt: true,
      ),
    );
  }

  void toggle() => state.isRunning ? pause() : start();

  /// Vuelve al principio de la fase actual, parada.
  void reset() {
    _stopTicker();
    _cancelEndNotification();
    final seconds = _phaseSeconds(state.phase);
    _set(
      state.copyWith(
        status: PomodoroStatus.idle,
        totalSeconds: seconds,
        remainingSeconds: seconds,
        clearEndAt: true,
      ),
    );
  }

  /// Pasa a la fase siguiente sin registrar nada.
  void skip() {
    _stopTicker();
    _cancelEndNotification();
    _advance(recordWork: false, autoStart: false);
  }

  int _remainingNow() {
    final endAt = state.endAtUtc;
    if (endAt == null) return state.remainingSeconds;
    final seconds = endAt.difference(clock.nowUtc()).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  void _tick() {
    if (!state.isRunning) {
      _stopTicker();
      return;
    }
    final remaining = _remainingNow();
    if (remaining <= 0) {
      _complete();
      return;
    }
    state = state.copyWith(remainingSeconds: remaining);
  }

  /// Al volver de segundo plano: si la fase venció mientras la app dormía,
  /// se cierra ahora (y se registra si era de concentración).
  void syncClock() {
    if (!state.isRunning) return;
    if (_remainingNow() <= 0) {
      _complete();
    } else {
      state = state.copyWith(remainingSeconds: _remainingNow());
      _startTicker();
    }
  }

  Future<void> _complete() async {
    _stopTicker();
    final finished = state;
    if (config.vibration) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (finished.isWork) {
      final endAt = finished.endAtUtc ?? clock.nowUtc();
      final startedAt = endAt.subtract(
        Duration(seconds: finished.totalSeconds),
      );
      try {
        await repository.addSession(
          day: calendar.dateOf(endAt),
          startedAt: startedAt,
          durationMinutes: finished.totalSeconds ~/ 60,
          label: finished.label.trim().isEmpty ? null : finished.label.trim(),
        );
      } catch (_) {
        // Registrar la sesión es un extra: el temporizador sigue.
      }
    }
    _advance(recordWork: true, autoStart: true);
  }

  void _advance({required bool recordWork, required bool autoStart}) {
    final current = state;
    var completed = current.completedInCycle;
    PomodoroPhase next;
    if (current.isWork) {
      if (recordWork) completed += 1;
      next = completed >= config.pomodorosPerCycle
          ? PomodoroPhase.longBreak
          : PomodoroPhase.shortBreak;
      if (!recordWork && completed >= config.pomodorosPerCycle) {
        next = PomodoroPhase.longBreak;
      }
    } else {
      if (current.phase == PomodoroPhase.longBreak) completed = 0;
      next = PomodoroPhase.work;
    }
    final seconds = _phaseSeconds(next);
    _set(
      PomodoroState(
        phase: next,
        status: PomodoroStatus.idle,
        totalSeconds: seconds,
        remainingSeconds: seconds,
        completedInCycle: completed,
        label: current.label,
      ),
    );
    final shouldAutoStart =
        autoStart &&
        (next == PomodoroPhase.work
            ? config.autoStartWork
            : config.autoStartBreaks);
    if (shouldAutoStart) start();
  }

  void _scheduleEndNotification(DateTime endAt) {
    final copy = this.copy;
    if (copy == null) return;
    final nextPhaseMinutes = state.isWork
        ? (state.completedInCycle + 1 >= config.pomodorosPerCycle
              ? config.longBreakMinutes
              : config.shortBreakMinutes)
        : config.workMinutes;
    notifications
        .syncTagged(tag, [
          ScheduledNotification(
            id: notificationId,
            title: state.isWork ? copy.workDoneTitle : copy.breakDoneTitle,
            body: state.isWork
                ? copy.workDoneBody(nextPhaseMinutes)
                : copy.breakDoneBody(nextPhaseMinutes),
            whenUtc: endAt,
            payload: 'end',
            silent: !config.sound,
          ),
        ])
        .catchError((_) {});
  }

  void _cancelEndNotification() {
    notifications.cancelTagged(tag).catchError((_) {});
  }
}
