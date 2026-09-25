import 'dart:async';

import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/theme/app_theme.dart';

/// [HabitsRepository] en memoria con el mismo comportamiento observable que
/// Firestore (streams reactivos, soft delete, ids de registro deterministas,
/// reasignación a General). Para tests y arranques con datos simulados.
class InMemoryHabitsRepository implements HabitsRepository {
  InMemoryHabitsRepository({
    bool seeded = true,
    DateTime Function()? now,
    LogicalDate? today,
  }) : _now = now ?? DateTime.now,
       _today = today ?? _dayOf((now ?? DateTime.now)()) {
    if (seeded) _seed();
  }

  static LogicalDate _dayOf(DateTime instant) =>
      LogicalDate(instant.year, instant.month, instant.day);

  final DateTime Function() _now;
  final LogicalDate _today;
  final List<Ambito> _ambitos = [];
  final List<Habit> _habits = [];
  final Map<String, HabitLog> _logs = {};
  StreakCacheEntry? _streakCache;
  int _nextId = 1;

  final _ambitosController = StreamController<List<Ambito>>.broadcast();
  final _habitsController = StreamController<List<Habit>>.broadcast();
  final _logsController = StreamController<List<HabitLog>>.broadcast();
  final _cacheController = StreamController<StreakCacheEntry?>.broadcast();

  void _seed() {
    _ambitos.addAll(const [
      Ambito(
        id: Ambito.generalId,
        name: 'General',
        emoji: '✨',
        colorValue: 0xFF7C5CE0,
        isPredefined: true,
        order: 0,
      ),
      Ambito(
        id: 'salud',
        name: 'Salud',
        emoji: '💜',
        colorValue: 0xFF8B5CF6,
        isPredefined: true,
        order: 1,
      ),
      Ambito(
        id: 'mente',
        name: 'Mente',
        emoji: '🧠',
        colorValue: 0xFFF16A8F,
        isPredefined: true,
        order: 2,
      ),
      Ambito(
        id: 'desarrollo',
        name: 'Desarrollo',
        emoji: '🌿',
        colorValue: 0xFF34B379,
        isPredefined: true,
        order: 3,
      ),
      Ambito(
        id: 'energia',
        name: 'Energía',
        emoji: '🏋️',
        colorValue: 0xFFF59E0B,
        isPredefined: true,
        order: 4,
      ),
    ]);

    final createdAt = _now().subtract(const Duration(days: 30));
    final since = _today.addDays(-30);
    Habit seedHabit({
      required String id,
      required String name,
      required String ambitoId,
      required Periodicity periodicity,
      required int colorValue,
      required String emoji,
      required int order,
      String? reminderTime,
    }) => Habit(
      id: id,
      name: name,
      ambitoId: ambitoId,
      periodicityTimeline: [
        PeriodicityEntry(periodicity: periodicity, since: since),
      ],
      colorValue: colorValue,
      emoji: emoji,
      reminderTime: reminderTime,
      order: order,
      createdAt: createdAt,
    );

    _habits.addAll([
      seedHabit(
        id: 'agua',
        name: 'Beber agua',
        ambitoId: 'salud',
        periodicity: Periodicity.daily,
        colorValue: AppColors.blue.toARGB32(),
        emoji: '💧',
        order: 0,
      ),
      seedHabit(
        id: 'meditacion',
        name: 'Meditación',
        ambitoId: 'mente',
        periodicity: Periodicity.daily,
        colorValue: AppColors.lilac.toARGB32(),
        emoji: '🧘',
        order: 1,
      ),
      seedHabit(
        id: 'entrenar',
        name: 'Entrenar',
        ambitoId: 'energia',
        periodicity: const Periodicity(
          type: PeriodicityType.weekly,
          timesPerPeriod: 3,
        ),
        colorValue: AppColors.green.toARGB32(),
        emoji: '👟',
        reminderTime: '18:00',
        order: 2,
      ),
      seedHabit(
        id: 'leer',
        name: 'Leer 20 min',
        ambitoId: 'desarrollo',
        periodicity: Periodicity.daily,
        colorValue: AppColors.orange.toARGB32(),
        emoji: '📖',
        order: 3,
      ),
      seedHabit(
        id: 'ingles',
        name: 'Estudiar inglés',
        ambitoId: 'desarrollo',
        periodicity: const Periodicity(
          type: PeriodicityType.monthly,
          timesPerPeriod: 12,
        ),
        colorValue: AppColors.pink.toARGB32(),
        emoji: '💬',
        order: 4,
      ),
    ]);

    // Semana en curso completada hasta ayer (hoy queda pendiente de marcar);
    // "Estudiar inglés" falló ayer para tener variedad visual.
    final monday = _today.addDays(-(_today.weekday - DateTime.monday));
    final yesterday = _today.previous;
    for (final habit in _habits) {
      for (var day = monday; day.isBefore(_today); day = day.next) {
        if (habit.id == 'ingles' && day == yesterday) continue;
        _putLog(habit.id, day);
      }
    }
  }

  // ---------------------------------------------------------------- lecturas

  List<Habit> get _activeHabits =>
      (_habits.where((h) => !h.isDeleted).toList()
            ..sort((a, b) => a.order.compareTo(b.order)))
          .toList(growable: false);

  List<Ambito> get _sortedAmbitos => (List.of(
    _ambitos,
  )..sort((a, b) => a.order.compareTo(b.order))).toList(growable: false);

  @override
  Stream<List<Ambito>> watchAmbitos() async* {
    yield _sortedAmbitos;
    yield* _ambitosController.stream;
  }

  @override
  Stream<List<Habit>> watchActiveHabits() async* {
    yield _activeHabits;
    yield* _habitsController.stream;
  }

  @override
  Stream<List<HabitLog>> watchLogsBetween(
    LogicalDate from,
    LogicalDate to,
  ) async* {
    List<HabitLog> select() => _logsBetween(from, to);
    yield select();
    yield* _logsController.stream.map((_) => select());
  }

  @override
  Stream<Set<LogicalDate>> watchActivityDays() async* {
    yield _activityDays();
    yield* _logsController.stream.map((_) => _activityDays());
  }

  @override
  Future<Set<LogicalDate>> fetchActivityDays() async => _activityDays();

  Set<LogicalDate> _activityDays() => {
    for (final log in _logs.values)
      if (log.isActivity) log.date,
  };

  @override
  Stream<StreakCacheEntry?> watchStreakCache() async* {
    yield _streakCache;
    yield* _cacheController.stream;
  }

  @override
  Future<StreakCacheEntry?> fetchStreakCache() async => _streakCache;

  @override
  Future<void> saveStreakCache(StreakCacheEntry entry) async {
    _streakCache = entry;
    _cacheController.add(entry);
  }

  @override
  Future<void> clearStreakCache() async {
    _streakCache = null;
    _cacheController.add(null);
  }

  List<HabitLog> _logsBetween(LogicalDate from, LogicalDate to) =>
      (_logs.values
              .where((l) => l.date.isAtOrAfter(from) && l.date.isAtOrBefore(to))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date)))
          .toList(growable: false);

  @override
  Future<List<HabitLog>> fetchHabitLogs(
    String habitId, {
    LogicalDate? from,
    LogicalDate? to,
  }) async {
    return (_logs.values.where((l) {
      if (l.habitId != habitId) return false;
      if (from != null && l.date.isBefore(from)) return false;
      if (to != null && l.date.isAfter(to)) return false;
      return true;
    }).toList()..sort((a, b) => a.date.compareTo(b.date))).toList(
      growable: false,
    );
  }

  @override
  Future<Habit?> getHabit(String habitId) async {
    for (final habit in _habits) {
      if (habit.id == habitId) return habit;
    }
    return null;
  }

  // ---------------------------------------------------------------- escritura

  @override
  Future<Habit> createHabit(
    HabitDraft draft, {
    required LogicalDate today,
  }) async {
    // Las Security Rules exigen que el ámbito exista (exists(ambitoPath)).
    if (!_ambitos.any((a) => a.id == draft.ambitoId)) {
      throw const HabitsException(HabitsFailure.ambitoNotFound);
    }
    final habit = Habit(
      id: 'h${_nextId++}',
      name: draft.name,
      ambitoId: draft.ambitoId,
      periodicityTimeline: [
        PeriodicityEntry(periodicity: draft.periodicity, since: today),
      ],
      colorValue: draft.colorValue,
      emoji: draft.emoji,
      iconId: draft.iconId,
      reminderTime: draft.reminderTime,
      reminderMessage: draft.reminderMessage,
      trackingType: draft.trackingType,
      targetCount: draft.targetCount,
      unit: draft.unit,
      displayGoal: draft.displayGoal,
      progressIconId: draft.progressIconId,
      order: _habits.length,
      createdAt: _now(),
    );
    _habits.add(habit);
    _emitHabits();
    return habit;
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index < 0) throw const HabitsException(HabitsFailure.habitNotFound);
    // Como en Firestore: editar no cambia el estado de borrado.
    _habits[index] = habit.copyWith(deletedAt: _habits[index].deletedAt);
    _emitHabits();
  }

  @override
  Future<void> reorderHabits(Map<String, int> orderById) async {
    for (final entry in orderById.entries) {
      final index = _habits.indexWhere((h) => h.id == entry.key);
      if (index < 0) throw const HabitsException(HabitsFailure.habitNotFound);
      _habits[index] = _habits[index].copyWith(order: entry.value);
    }
    _emitHabits();
  }

  @override
  Future<void> softDeleteHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index < 0) throw const HabitsException(HabitsFailure.habitNotFound);
    _habits[index] = _habits[index].copyWith(deletedAt: _now());
    _emitHabits();
  }

  @override
  Future<Ambito> createAmbito(AmbitoDraft draft) async {
    final ambito = Ambito(
      id: 'a${_nextId++}',
      name: draft.name,
      emoji: draft.emoji,
      colorValue: draft.colorValue,
      order: _ambitos.length,
      createdAt: _now(),
    );
    _ambitos.add(ambito);
    _emitAmbitos();
    return ambito;
  }

  @override
  Future<void> updateAmbito(Ambito ambito) async {
    final index = _ambitos.indexWhere((a) => a.id == ambito.id);
    if (index < 0) throw const HabitsException(HabitsFailure.ambitoNotFound);
    // `esPredefinido` es inmutable para las reglas: se conserva el valor
    // guardado aunque el cliente envíe otro.
    _ambitos[index] = ambito.copyWith(
      isPredefined: _ambitos[index].isPredefined,
    );
    _emitAmbitos();
  }

  @override
  Future<void> deleteAmbito(String ambitoId) async {
    if (ambitoId == Ambito.generalId) {
      throw const HabitsException(HabitsFailure.generalAmbitoProtected);
    }
    final index = _ambitos.indexWhere((a) => a.id == ambitoId);
    if (index < 0) throw const HabitsException(HabitsFailure.ambitoNotFound);
    // Los hábitos (activos y eliminados) pasan a General, como en Firestore.
    for (var i = 0; i < _habits.length; i++) {
      if (_habits[i].ambitoId == ambitoId) {
        _habits[i] = _habits[i].copyWith(ambitoId: Ambito.generalId);
      }
    }
    _ambitos.removeAt(index);
    _emitAmbitos();
    _emitHabits();
  }

  @override
  Future<void> setHabitCompletion({
    required String habitId,
    required LogicalDate date,
    required bool completed,
  }) async {
    final key = '${habitId}_${date.key}';
    if (completed) {
      if (_logs.containsKey(key)) return; // idempotente, sin escritura
      _requireActiveHabit(habitId);
      _putLog(habitId, date);
    } else {
      if (!_logs.containsKey(key)) return; // nada que borrar
      _requireActiveHabit(habitId);
      _logs.remove(key);
    }
    _logsController.add(_logs.values.toList(growable: false));
  }

  @override
  Future<void> setHabitDailyCount({
    required String habitId,
    required LogicalDate date,
    required int completedCount,
    required int targetCount,
  }) async {
    _requireActiveHabit(habitId);
    final key = '${habitId}_${date.key}';
    final safeTarget = targetCount.clamp(1, 999);
    final safeCount = completedCount.clamp(0, safeTarget);
    if (safeCount == 0) {
      _logs.remove(key);
    } else {
      _logs[key] = HabitLog(
        id: key,
        habitId: habitId,
        date: date,
        completedCount: safeCount,
        targetCount: safeTarget,
      );
    }
    _logsController.add(_logs.values.toList(growable: false));
  }

  /// Mismo comportamiento que las Security Rules: un hábito eliminado con
  /// soft delete no admite registros nuevos y su histórico es inmutable.
  void _requireActiveHabit(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index < 0) throw const HabitsException(HabitsFailure.habitNotFound);
    if (_habits[index].isDeleted) {
      throw const HabitsException(HabitsFailure.habitDeleted);
    }
  }

  void _putLog(String habitId, LogicalDate date) {
    final key = '${habitId}_${date.key}';
    _logs[key] = HabitLog(id: key, habitId: habitId, date: date);
  }

  void _emitHabits() => _habitsController.add(_activeHabits);
  void _emitAmbitos() => _ambitosController.add(_sortedAmbitos);

  Future<void> dispose() async {
    await _ambitosController.close();
    await _habitsController.close();
    await _logsController.close();
    await _cacheController.close();
  }
}
