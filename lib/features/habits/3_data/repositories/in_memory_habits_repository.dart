import 'dart:async';

import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';
import 'package:habits/theme/app_theme.dart';

/// [HabitsRepository] en memoria con el mismo comportamiento observable que
/// Firestore (streams reactivos, soft delete, ids de registro deterministas,
/// reasignación a General). Para tests y arranques con datos simulados.
class InMemoryHabitsRepository implements HabitsRepository {
  InMemoryHabitsRepository({bool seeded = true, DateTime Function()? now})
    : _now = now ?? DateTime.now {
    if (seeded) _seed();
  }

  final DateTime Function() _now;
  final List<Ambito> _ambitos = [];
  final List<Habit> _habits = [];
  final Map<String, HabitLog> _logs = {};
  StreaksSnapshot _streaks = StreaksSnapshot.empty;
  int _nextId = 1;

  final _ambitosController = StreamController<List<Ambito>>.broadcast();
  final _habitsController = StreamController<List<Habit>>.broadcast();
  final _logsController = StreamController<List<HabitLog>>.broadcast();
  final _streaksController = StreamController<StreaksSnapshot>.broadcast();

  /// Fija la caché de rachas (simula lo que escribirá la fase 5).
  void setStreaks(StreaksSnapshot streaks) {
    _streaks = streaks;
    _streaksController.add(streaks);
  }

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
    _habits.addAll([
      Habit(
        id: 'agua',
        name: 'Beber agua',
        ambitoId: 'salud',
        periodicity: Periodicity.daily,
        restDaysAllowed: 2,
        colorValue: AppColors.blue.toARGB32(),
        emoji: '💧',
        order: 0,
        createdAt: createdAt,
      ),
      Habit(
        id: 'meditacion',
        name: 'Meditación',
        ambitoId: 'mente',
        periodicity: Periodicity.daily,
        restDaysAllowed: 1,
        colorValue: AppColors.lilac.toARGB32(),
        emoji: '🧘',
        order: 1,
        createdAt: createdAt,
      ),
      Habit(
        id: 'entrenar',
        name: 'Entrenar',
        ambitoId: 'energia',
        periodicity: Periodicity.daily,
        restDaysAllowed: 2,
        recoveryTask: '10 flexiones',
        colorValue: AppColors.green.toARGB32(),
        emoji: '👟',
        reminderTime: '18:00',
        order: 2,
        createdAt: createdAt,
      ),
      Habit(
        id: 'leer',
        name: 'Leer 20 min',
        ambitoId: 'desarrollo',
        periodicity: Periodicity.daily,
        colorValue: AppColors.orange.toARGB32(),
        emoji: '📖',
        order: 3,
        createdAt: createdAt,
      ),
      Habit(
        id: 'ingles',
        name: 'Estudiar inglés',
        ambitoId: 'desarrollo',
        periodicity: Periodicity.daily,
        restDaysAllowed: 1,
        colorValue: AppColors.pink.toARGB32(),
        emoji: '💬',
        order: 4,
        createdAt: createdAt,
      ),
    ]);

    // Semana en curso completada hasta ayer (hoy queda pendiente de marcar);
    // "Estudiar inglés" falló ayer para tener variedad visual.
    final today = LogicalDay.of(_now());
    final monday = LogicalDay.mondayOfWeek(today);
    for (final habit in _habits) {
      for (
        var day = monday;
        day.isBefore(today);
        day = day.add(const Duration(days: 1))
      ) {
        final isYesterday = LogicalDay.isSameDay(
          day,
          today.subtract(const Duration(days: 1)),
        );
        if (habit.id == 'ingles' && isYesterday) continue;
        _putLog(habit.id, day, HabitLogType.completed);
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
  Stream<List<HabitLog>> watchLogsBetween(DateTime from, DateTime to) async* {
    List<HabitLog> select() => _logsBetween(from, to);
    yield select();
    yield* _logsController.stream.map((_) => select());
  }

  @override
  Stream<StreaksSnapshot> watchStreaks() async* {
    yield _streaks;
    yield* _streaksController.stream;
  }

  List<HabitLog> _logsBetween(DateTime from, DateTime to) {
    final f = LogicalDay.of(from);
    final t = LogicalDay.of(to);
    return (_logs.values
            .where((l) => !l.date.isBefore(f) && !l.date.isAfter(t))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)))
        .toList(growable: false);
  }

  @override
  Future<List<HabitLog>> fetchHabitLogs(
    String habitId, {
    DateTime? from,
    DateTime? to,
  }) async {
    return (_logs.values.where((l) {
      if (l.habitId != habitId) return false;
      if (from != null && l.date.isBefore(LogicalDay.of(from))) return false;
      if (to != null && l.date.isAfter(LogicalDay.of(to))) return false;
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

  // ---------------------------------------------------------------- hábitos

  @override
  Future<Habit> createHabit(HabitDraft draft) async {
    if (!_ambitos.any((a) => a.id == draft.ambitoId)) {
      throw const HabitsException(HabitsFailure.ambitoNotFound);
    }
    final now = _now();
    final habit = Habit(
      id: 'habit-${_nextId++}',
      name: draft.name,
      ambitoId: draft.ambitoId,
      periodicity: draft.periodicity,
      restDaysAllowed: draft.restDaysAllowed,
      recoveryTask: draft.recoveryTask,
      recoveryCooldownDays: draft.recoveryCooldownDays,
      colorValue: draft.colorValue,
      emoji: draft.emoji,
      reminderTime: draft.reminderTime,
      order: now.millisecondsSinceEpoch,
      createdAt: now,
    );
    _habits.add(habit);
    _habitsController.add(_activeHabits);
    return habit;
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) throw const HabitsException(HabitsFailure.habitNotFound);
    if (!_ambitos.any((a) => a.id == habit.ambitoId)) {
      throw const HabitsException(HabitsFailure.ambitoNotFound);
    }
    _habits[index] = habit.copyWith(createdAt: _habits[index].createdAt);
    _habitsController.add(_activeHabits);
  }

  @override
  Future<void> softDeleteHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) throw const HabitsException(HabitsFailure.habitNotFound);
    _habits[index] = _habits[index].copyWith(deletedAt: _now());
    _habitsController.add(_activeHabits);
  }

  // ---------------------------------------------------------------- ámbitos

  @override
  Future<Ambito> createAmbito(AmbitoDraft draft) async {
    final now = _now();
    final ambito = Ambito(
      id: 'ambito-${_nextId++}',
      name: draft.name,
      emoji: draft.emoji,
      colorValue: draft.colorValue,
      order: now.millisecondsSinceEpoch,
      createdAt: now,
    );
    _ambitos.add(ambito);
    _ambitosController.add(_sortedAmbitos);
    return ambito;
  }

  @override
  Future<void> updateAmbito(Ambito ambito) async {
    final index = _ambitos.indexWhere((a) => a.id == ambito.id);
    if (index == -1) throw const HabitsException(HabitsFailure.ambitoNotFound);
    _ambitos[index] = ambito.copyWith(
      isPredefined: _ambitos[index].isPredefined,
      createdAt: _ambitos[index].createdAt,
    );
    _ambitosController.add(_sortedAmbitos);
  }

  @override
  Future<void> deleteAmbito(String ambitoId) async {
    if (ambitoId == Ambito.generalId) {
      throw const HabitsException(HabitsFailure.generalAmbitoProtected);
    }
    if (!_ambitos.any((a) => a.id == ambitoId)) {
      throw const HabitsException(HabitsFailure.ambitoNotFound);
    }
    for (var i = 0; i < _habits.length; i++) {
      if (_habits[i].ambitoId == ambitoId) {
        _habits[i] = _habits[i].copyWith(ambitoId: Ambito.generalId);
      }
    }
    _ambitos.removeWhere((a) => a.id == ambitoId);
    _ambitosController.add(_sortedAmbitos);
    _habitsController.add(_activeHabits);
  }

  // -------------------------------------------------------------- registros

  @override
  Future<void> setHabitCompletion({
    required String habitId,
    required DateTime date,
    required bool completed,
    HabitLogType type = HabitLogType.completed,
  }) async {
    final habit = await getHabit(habitId);
    if (habit == null) throw const HabitsException(HabitsFailure.habitNotFound);
    if (habit.isDeleted) {
      throw const HabitsException(HabitsFailure.habitDeleted);
    }

    final day = LogicalDay.of(date);
    if (completed) {
      _putLog(habitId, day, type);
    } else {
      _logs.remove(_logId(habitId, day));
    }
    _logsController.add(const []);
  }

  static String _logId(String habitId, DateTime day) =>
      '${habitId}_${LogicalDay.format(day)}';

  void _putLog(String habitId, DateTime day, HabitLogType type) {
    final id = _logId(habitId, day);
    _logs[id] = HabitLog(id: id, habitId: habitId, date: day, type: type);
  }
}
