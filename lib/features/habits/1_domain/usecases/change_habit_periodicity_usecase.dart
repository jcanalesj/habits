import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/habit_validation.dart';
import 'package:habits/features/habits/1_domain/services/periodicity_resolver.dart';

sealed class ChangePeriodicityResult {}

/// El cambio se guardó y entrará en vigor el día [effectiveFrom].
class ChangePeriodicityScheduled extends ChangePeriodicityResult {
  ChangePeriodicityScheduled(this.habit, this.effectiveFrom);

  final Habit habit;
  final LogicalDate effectiveFrom;
}

/// El objetivo pedido es el que ya estaba vigente: no hay nada que hacer.
class ChangePeriodicityUnchanged extends ChangePeriodicityResult {}

class ChangePeriodicityInvalid extends ChangePeriodicityResult {
  ChangePeriodicityInvalid(this.errors);

  final Set<HabitValidationError> errors;
}

class ChangePeriodicityFailed extends ChangePeriodicityResult {
  ChangePeriodicityFailed(this.failure);

  final HabitsFailure failure;
}

/// Programa un cambio de objetivo de un hábito.
///
/// El cambio NUNCA altera el periodo en curso (§10). Entra en vigor al
/// empezar el siguiente periodo natural completo del tipo nuevo, así que no
/// hay periodos parciales ni objetivos prorrateados:
///
///   3/semana → 12/mes  (un jueves) → el día 1 del mes siguiente
///   12/mes   → 3/semana            → el lunes siguiente
///   3/semana → 5/semana            → el lunes siguiente
///   →  X/año                       → el próximo 1 de enero
///
/// La UI debe avisar de la fecha efectiva ANTES de guardar; el usecase
/// devuelve esa fecha en [ChangePeriodicityScheduled] para poder mostrarla
/// también después.
///
/// El historial queda completo: qué configuración hubo, desde cuándo, y
/// cuál es la siguiente con su fecha efectiva. Es lo que permitirá calcular
/// los rangos por hábito más adelante (§7).
class ChangeHabitPeriodicityUsecase {
  const ChangeHabitPeriodicityUsecase(this._repository, this._resolver);

  final HabitsRepository _repository;
  final PeriodicityResolver _resolver;

  /// Fecha en la que entraría en vigor el cambio, para previsualizarla en la
  /// UI sin guardar nada.
  LogicalDate previewEffectiveDate(
    Periodicity next,
    LogicalDate today,
  ) => _resolver.effectiveDateFor(next.type, today);

  Future<ChangePeriodicityResult> execute({
    required Habit habit,
    required Periodicity next,
    required LogicalDate today,
  }) async {
    if (habit.isDeleted) {
      return ChangePeriodicityFailed(HabitsFailure.habitDeleted);
    }
    final errors = HabitValidation.validatePeriodicity(next);
    if (errors.isNotEmpty) return ChangePeriodicityInvalid(errors);

    final effectiveFrom = _resolver.effectiveDateFor(next.type, today);

    // Si ya hay un cambio pendiente para esa misma fecha, se sustituye en
    // lugar de apilar entradas: la línea temporal se mantiene limpia y con
    // `since` estrictamente creciente.
    final timeline = [
      for (final entry in habit.periodicityTimeline)
        if (entry.since.isBefore(effectiveFrom)) entry,
    ];

    final alreadyEffective =
        timeline.isNotEmpty && timeline.last.periodicity == next;
    if (alreadyEffective && timeline.length == habit.periodicityTimeline.length) {
      return ChangePeriodicityUnchanged();
    }

    final updated = habit.copyWith(
      periodicityTimeline: [
        ...timeline,
        PeriodicityEntry(periodicity: next, since: effectiveFrom),
      ],
    );

    try {
      await _repository.updateHabit(updated);
      return ChangePeriodicityScheduled(updated, effectiveFrom);
    } on HabitsException catch (e) {
      return ChangePeriodicityFailed(e.failure);
    } catch (_) {
      return ChangePeriodicityFailed(HabitsFailure.unknown);
    }
  }
}
