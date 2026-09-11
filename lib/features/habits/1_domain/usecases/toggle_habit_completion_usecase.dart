import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';

sealed class ToggleHabitCompletionResult {}

class ToggleHabitCompletionSuccess extends ToggleHabitCompletionResult {}

/// Solo se puede registrar el día de HOY. Ni ayer, ni anteayer, ni mañana,
/// ni una fecha arbitraria (§14): si no quedó registrado durante el día,
/// para Constanza ese día no tiene ese registro.
class ToggleHabitCompletionNotToday extends ToggleHabitCompletionResult {
  ToggleHabitCompletionNotToday(this.requested, this.today);

  final LogicalDate requested;
  final LogicalDate today;
}

class ToggleHabitCompletionFailed extends ToggleHabitCompletionResult {
  ToggleHabitCompletionFailed(this.failure);

  final HabitsFailure failure;
}

/// Marca o desmarca el cumplimiento de un hábito activo.
///
/// [today] llega ya resuelto en la zona horaria IANA del perfil: esta es la
/// primera de las dos capas que impiden los registros retroactivos. La
/// segunda son las Security Rules, que acotan la fecha pero no pueden
/// garantizar "hoy exacto" sin backend confiable (ver documentación de
/// limitaciones conocidas).
class ToggleHabitCompletionUsecase {
  const ToggleHabitCompletionUsecase(this._repository);

  final HabitsRepository _repository;

  Future<ToggleHabitCompletionResult> execute({
    required String habitId,
    required LogicalDate date,
    required bool completed,
    required LogicalDate today,
  }) async {
    if (date != today) {
      return ToggleHabitCompletionNotToday(date, today);
    }

    try {
      final habit = await _repository.getHabit(habitId);
      if (habit == null) {
        return ToggleHabitCompletionFailed(HabitsFailure.habitNotFound);
      }
      if (habit.isDeleted) {
        return ToggleHabitCompletionFailed(HabitsFailure.habitDeleted);
      }
      await _repository.setHabitCompletion(
        habitId: habitId,
        date: date,
        completed: completed,
      );
      return ToggleHabitCompletionSuccess();
    } on HabitsException catch (e) {
      return ToggleHabitCompletionFailed(e.failure);
    } catch (_) {
      return ToggleHabitCompletionFailed(HabitsFailure.unknown);
    }
  }
}
