import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';
import 'package:habits/theme/app_theme.dart';

/// Implementación en memoria para desarrollo de UI, sembrada con los datos
/// del visual de referencia. Se sustituirá por la implementación Firestore
/// sin tocar dominio ni presentación.
class InMemoryHabitsRepository implements HabitsRepository {
  InMemoryHabitsRepository() {
    _seed();
  }

  final List<Ambito> _ambitos = [];
  final List<Habit> _habits = [];
  final List<HabitLog> _logs = [];
  GeneralStreak _generalStreak = const GeneralStreak();
  int _nextLogId = 0;

  void _seed() {
    _ambitos.addAll(const [
      Ambito(
        id: 'salud',
        name: 'Salud',
        emoji: '💜',
        colorValue: 0xFF8B5CF6,
        isPredefined: true,
        currentStreak: 8,
        bestStreak: 21,
      ),
      Ambito(
        id: 'mente',
        name: 'Mente',
        emoji: '🧠',
        colorValue: 0xFFF16A8F,
        isPredefined: true,
        currentStreak: 5,
        bestStreak: 12,
      ),
      Ambito(
        id: 'desarrollo',
        name: 'Desarrollo',
        emoji: '🌿',
        colorValue: 0xFF34B379,
        isPredefined: true,
        currentStreak: 6,
        bestStreak: 15,
      ),
      Ambito(
        id: 'energia',
        name: 'Energía',
        emoji: '🏋️',
        colorValue: 0xFFF59E0B,
        isPredefined: true,
        currentStreak: 3,
        bestStreak: 9,
      ),
    ]);

    final createdAt = DateTime.now().subtract(const Duration(days: 30));
    _habits.addAll([
      Habit(
        id: 'agua',
        name: 'Beber agua',
        ambitoId: 'salud',
        periodicity: Periodicity.daily,
        restDaysAllowed: 2,
        colorValue: AppColors.blue.toARGB32(),
        emoji: '💧',
        currentStreak: 12,
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
        currentStreak: 7,
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
        currentStreak: 5,
        createdAt: createdAt,
      ),
      Habit(
        id: 'leer',
        name: 'Leer 20 min',
        ambitoId: 'desarrollo',
        periodicity: Periodicity.daily,
        colorValue: AppColors.orange.toARGB32(),
        emoji: '📖',
        currentStreak: 10,
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
        currentStreak: 3,
        createdAt: createdAt,
      ),
    ]);

    // Semana en curso completada hasta ayer (hoy queda pendiente de marcar);
    // "Estudiar inglés" falló ayer para tener variedad visual.
    final today = LogicalDay.today();
    final monday = LogicalDay.mondayOfWeek(today);
    for (final habit in _habits) {
      for (var day = monday;
          day.isBefore(today);
          day = day.add(const Duration(days: 1))) {
        final isYesterday =
            LogicalDay.isSameDay(day, today.subtract(const Duration(days: 1)));
        if (habit.id == 'ingles' && isYesterday) continue;
        _logs.add(
          HabitLog(id: '${_nextLogId++}', habitId: habit.id, date: day),
        );
      }
    }

    _generalStreak = GeneralStreak(
      count: 12,
      comodinDisponible: true,
      lastLogDate: today.subtract(const Duration(days: 1)),
    );
  }

  @override
  Future<GeneralStreak> fetchGeneralStreak() async => _generalStreak;

  @override
  Future<List<Ambito>> fetchAmbitos() async => List.unmodifiable(_ambitos);

  @override
  Future<List<Habit>> fetchHabits() async => List.unmodifiable(_habits);

  @override
  Future<List<HabitLog>> fetchLogsBetween(DateTime from, DateTime to) async {
    return _logs
        .where((log) => !log.date.isBefore(from) && !log.date.isAfter(to))
        .toList(growable: false);
  }

  @override
  Future<void> setHabitCompletion({
    required String habitId,
    required DateTime date,
    required bool completed,
  }) async {
    final alreadyLogged = _logs.any(
      (log) => log.habitId == habitId && LogicalDay.isSameDay(log.date, date),
    );

    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) throw ArgumentError('Hábito no encontrado: $habitId');

    if (completed && !alreadyLogged) {
      _logs.add(HabitLog(id: '${_nextLogId++}', habitId: habitId, date: date));
      _habits[habitIndex] = _habits[habitIndex].copyWith(
        currentStreak: _habits[habitIndex].currentStreak + 1,
      );
      _bumpGeneralStreakIfFirstOf(date);
    } else if (!completed && alreadyLogged) {
      _logs.removeWhere(
        (log) => log.habitId == habitId && LogicalDay.isSameDay(log.date, date),
      );
      _habits[habitIndex] = _habits[habitIndex].copyWith(
        currentStreak: (_habits[habitIndex].currentStreak - 1).clamp(0, 1 << 31),
      );
      _dropGeneralStreakIfEmpty(date);
    }
  }

  void _bumpGeneralStreakIfFirstOf(DateTime date) {
    final last = _generalStreak.lastLogDate;
    if (last == null || !LogicalDay.isSameDay(last, date)) {
      _generalStreak = _generalStreak.copyWith(
        count: _generalStreak.count + 1,
        lastLogDate: date,
      );
    }
  }

  void _dropGeneralStreakIfEmpty(DateTime date) {
    final anyLogToday =
        _logs.any((log) => LogicalDay.isSameDay(log.date, date));
    final last = _generalStreak.lastLogDate;
    if (!anyLogToday && last != null && LogicalDay.isSameDay(last, date)) {
      _generalStreak = _generalStreak.copyWith(
        count: (_generalStreak.count - 1).clamp(0, 1 << 31),
        lastLogDate: date.subtract(const Duration(days: 1)),
      );
    }
  }
}
