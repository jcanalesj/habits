import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/app_lifecycle.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';
import 'package:habits/features/steps/2_presentation/providers/steps_providers.dart';

enum StepsStatus {
  /// Falta el consentimiento explícito (primer uso).
  needsConsent,

  /// Sin permiso del sistema (o aún no pedido).
  noPermission,

  /// Dispositivo sin sensor de pasos.
  unavailable,
  loading,

  /// Contando en vivo.
  counting,
}

class StepsState {
  const StepsState({
    required this.status,
    required this.config,
    required this.today,
    this.todaySteps = 0,
    this.todayDistanceMeters,
    this.updatedAt,
    this.permission = PedometerPermission.notDetermined,
    this.error = false,
  });

  final StepsStatus status;
  final StepsConfig config;
  final LogicalDate today;
  final int todaySteps;

  /// Distancia medida por el sistema (iOS); null si se estima.
  final int? todayDistanceMeters;
  final DateTime? updatedAt;
  final PedometerPermission permission;
  final bool error;

  double get progress =>
      config.goal == 0 ? 0 : (todaySteps / config.goal).clamp(0, 1).toDouble();
  bool get goalReached => config.goal > 0 && todaySteps >= config.goal;
  int get remaining => (config.goal - todaySteps).clamp(0, config.goal);

  StepsState copyWith({
    StepsStatus? status,
    StepsConfig? config,
    LogicalDate? today,
    int? todaySteps,
    int? todayDistanceMeters,
    bool clearDistance = false,
    DateTime? updatedAt,
    PedometerPermission? permission,
    bool? error,
  }) => StepsState(
    status: status ?? this.status,
    config: config ?? this.config,
    today: today ?? this.today,
    todaySteps: todaySteps ?? this.todaySteps,
    todayDistanceMeters: clearDistance
        ? null
        : (todayDistanceMeters ?? this.todayDistanceMeters),
    updatedAt: updatedAt ?? this.updatedAt,
    permission: permission ?? this.permission,
    error: error ?? this.error,
  );
}

/// Motor de la herramienta Pasos.
///
/// Se suscribe al contador nativo del día, traduce las lecturas (absolutas
/// en iOS, acumuladas en Android vía [StepLedger]) a pasos de hoy, y guarda
/// el total en la cuenta con un pequeño retardo para no escribir en cada
/// paso. En iOS rellena además los últimos siete días que falten en el
/// histórico, porque Core Motion los conserva.
class StepsController extends Notifier<StepsState> {
  StreamSubscription<PedometerSample>? _subscription;
  Timer? _saveTimer;
  StepLedgerState _ledger = const StepLedgerState();
  int? _lastSavedSteps;
  bool _backfilled = false;

  /// Copia del último día contado, para poder guardarlo al desmontar sin
  /// tocar `state` (Riverpod no permite usar `ref` en `onDispose`).
  StepsDay? _latest;

  late PedometerSource _source;
  late StepsRepository _repository;
  late StepLedgerStore _ledgerStore;
  late LogicalCalendar _calendar;
  late Clock _clock;

  static const historyDays = 7;
  static const saveDelay = Duration(seconds: 3);

  @override
  StepsState build() {
    ref.onDispose(_stop);
    _source = ref.watch(pedometerSourceProvider);
    _repository = ref.watch(stepsRepositoryProvider);
    _ledgerStore = ref.watch(stepLedgerStoreProvider);
    _calendar = ref.watch(logicalCalendarProvider);
    _clock = ref.watch(clockProvider);
    final today = ref.watch(todayProvider);
    final config = ref.watch(stepsConfigProvider).value ?? const StepsConfig();
    // Al volver de segundo plano se vuelve a pedir la lectura: el sensor ha
    // seguido contando y en iOS la suscripción puede haberse dormido.
    ref.listen(systemStateTickProvider, (_, _) => refresh());

    final saved = _ledgerStore.load();
    if (saved != null) _ledger = StepLedgerState.fromJson(saved);
    // Se escucha (no se observa) para mantener vivo el histórico sin
    // reconstruir el contador cada vez que se guarda el total del día.
    ref.listen(storedStepsDaysProvider, (_, next) {
      final storedToday = next.value
          ?.where((day) => day.day == state.today)
          .firstOrNull;
      if (storedToday != null && storedToday.steps > state.todaySteps) {
        state = state.copyWith(
          todaySteps: storedToday.steps,
          todayDistanceMeters: storedToday.distanceMeters,
        );
      }
    });
    final stored = ref
        .read(storedStepsDaysProvider)
        .value
        ?.where((day) => day.day == today)
        .firstOrNull;
    final initialSteps = _initialSteps(today, stored);
    _lastSavedSteps = stored?.steps;

    final initial = StepsState(
      status: StepsStatus.loading,
      config: config,
      today: today,
      todaySteps: initialSteps,
      todayDistanceMeters: stored?.distanceMeters,
    );
    Future.microtask(_start);
    return initial;
  }

  int _initialSteps(LogicalDate today, StepsDay? stored) {
    final fromLedger = _ledger.dayKey == today.key ? _ledger.todaySteps : 0;
    final fromStore = stored?.steps ?? 0;
    return fromLedger > fromStore ? fromLedger : fromStore;
  }

  Future<void> _start() async {
    if (!state.config.consented) {
      state = state.copyWith(status: StepsStatus.needsConsent);
      return;
    }
    try {
      if (!await _source.isAvailable()) {
        state = state.copyWith(status: StepsStatus.unavailable);
        return;
      }
      final permission = await _source.permissionStatus();
      state = state.copyWith(permission: permission);
      if (permission != PedometerPermission.granted) {
        state = state.copyWith(status: StepsStatus.noPermission);
        return;
      }
      _subscribe();
    } catch (_) {
      state = state.copyWith(status: StepsStatus.unavailable, error: true);
    }
  }

  void _subscribe() {
    _subscription?.cancel();
    final dayStart = _calendar.startOfDayUtc(state.today);
    _subscription = _source
        .updates(dayStartUtc: dayStart)
        .listen(_onSample, onError: (_) => state = state.copyWith(error: true));
    state = state.copyWith(status: StepsStatus.counting, error: false);
    if (!_backfilled) {
      _backfilled = true;
      Future.microtask(_backfillHistory);
    }
  }

  void _onSample(PedometerSample sample) {
    final today = _calendar.dateOf(_clock.nowUtc());
    if (today != state.today) {
      // Ha cambiado el día con la suscripción abierta: se reinicia desde el
      // nuevo inicio de día (todayProvider hará lo mismo enseguida).
      state = state.copyWith(today: today, todaySteps: 0, clearDistance: true);
      _lastSavedSteps = null;
      _subscribe();
      if (!sample.isCumulative) return;
    }
    int steps;
    int? distance;
    if (sample.isCumulative) {
      _ledger = StepLedger.apply(_ledger, sample.counter!, today);
      _ledgerStore.save(_ledger.toJson());
      steps = _ledger.todaySteps;
    } else {
      steps = sample.steps ?? state.todaySteps;
      distance = sample.distanceMeters;
    }
    // Nunca hacia atrás dentro del mismo día: otra fuente (otro dispositivo,
    // el histórico) puede haber guardado más.
    if (steps < state.todaySteps) steps = state.todaySteps;
    state = state.copyWith(
      status: StepsStatus.counting,
      todaySteps: steps,
      todayDistanceMeters: distance,
      updatedAt: sample.at,
      error: false,
    );
    _latest = StepsDay(day: today, steps: steps, distanceMeters: distance);
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, _saveNow);
  }

  Future<void> _saveNow() async {
    final snapshot = _latest;
    if (snapshot == null || snapshot.steps == _lastSavedSteps) return;
    _lastSavedSteps = snapshot.steps;
    try {
      await _repository.upsertDay(snapshot);
    } catch (_) {
      // Guardar el histórico es un extra: el contador sigue.
    }
  }

  /// iOS conserva siete días: los que falten en la cuenta se rellenan.
  Future<void> _backfillHistory() async {
    final List<StepsDay> stored;
    try {
      stored = await ref.read(storedStepsDaysProvider.future);
    } catch (_) {
      return;
    }
    final known = {for (final day in stored) day.day};
    for (var offset = 1; offset < historyDays; offset++) {
      final day = state.today.addDays(-offset);
      if (known.contains(day)) continue;
      try {
        final sample = await _source.query(
          _calendar.startOfDayUtc(day),
          _calendar.startOfDayUtc(day.next),
        );
        final steps = sample?.steps;
        if (steps == null || steps == 0) continue;
        await _repository.upsertDay(
          StepsDay(
            day: day,
            steps: steps,
            distanceMeters: sample!.distanceMeters,
          ),
        );
      } catch (_) {
        return;
      }
    }
  }

  /// Guarda el consentimiento y arranca.
  Future<void> consent() async {
    if (!state.config.consented) {
      final config = state.config.copyWith(consented: true);
      state = state.copyWith(config: config);
      try {
        await _repository.saveConfig(config);
      } catch (_) {}
    }
    await requestPermission();
  }

  Future<void> requestPermission() async {
    try {
      if (!await _source.isAvailable()) {
        state = state.copyWith(status: StepsStatus.unavailable);
        return;
      }
      final permission = await _source.requestPermission();
      state = state.copyWith(permission: permission);
      if (permission == PedometerPermission.granted) {
        _subscribe();
      } else {
        state = state.copyWith(status: StepsStatus.noPermission);
      }
    } catch (_) {
      state = state.copyWith(status: StepsStatus.noPermission, error: true);
    }
  }

  /// Vuelve a suscribirse (botón "Actualizar" y vuelta de segundo plano).
  void refresh() {
    if (state.status == StepsStatus.counting ||
        state.status == StepsStatus.noPermission) {
      _start();
    }
  }

  void applyConfig(StepsConfig config) {
    final wasConsented = state.config.consented;
    state = state.copyWith(config: config);
    if (!wasConsented && config.consented) _start();
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
    _saveTimer?.cancel();
    _saveNow();
  }
}
