import 'package:habits/features/habits/0_entity/entity.dart';

/// Contrato de datos de la feature de hábitos. La implementación de v1 será
/// Firestore (scoped por usuario); mientras tanto existe una implementación
/// en memoria en 3_data para desarrollo de UI.
abstract class HabitsRepository {
  Future<GeneralStreak> fetchGeneralStreak();

  Future<List<Ambito>> fetchAmbitos();

  Future<List<Habit>> fetchHabits();

  /// Registros con día lógico dentro de [from, to], ambos inclusive.
  Future<List<HabitLog>> fetchLogsBetween(DateTime from, DateTime to);

  /// Marca o desmarca el cumplimiento de un hábito en un día lógico.
  Future<void> setHabitCompletion({
    required String habitId,
    required DateTime date,
    required bool completed,
  });
}
