import 'package:habits/features/habits/0_entity/periodicity.dart';

/// Reglas de validación de hábitos y ámbitos. Coinciden con los límites que
/// imponen las Security Rules para que un dato válido aquí nunca sea
/// rechazado por el backend.
enum HabitValidationError {
  nameRequired,
  nameTooLong,
  emojiRequired,
  invalidTimesPerPeriod,
  invalidReminderTime,
  reminderMessageTooLong,
}

enum AmbitoValidationError { nameRequired, nameTooLong, emojiRequired }

abstract final class HabitValidation {
  static const maxHabitNameLength = 60;
  static const maxAmbitoNameLength = 40;
  static const minTimesPerPeriod = 1;
  static const maxReminderMessageLength = 120;

  /// Tope de veces por periodo. 366 cubre el caso más amplio (un objetivo
  /// anual en año bisiesto) y evita valores absurdos.
  static const maxTimesPerPeriod = 366;

  static final _timeRegex = RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9]$');

  /// Tope de veces coherente con el tipo de periodo: no tiene sentido
  /// "10 veces por semana" si una semana tiene 7 días con un registro por
  /// día como máximo.
  static int maxTimesFor(PeriodicityType type) => switch (type) {
    PeriodicityType.daily => 1,
    PeriodicityType.weekly => 7,
    PeriodicityType.monthly => 31,
    PeriodicityType.yearly => maxTimesPerPeriod,
  };

  static Set<HabitValidationError> validatePeriodicity(
    Periodicity periodicity,
  ) => {
    if (periodicity.type != PeriodicityType.daily &&
        (periodicity.timesPerPeriod < minTimesPerPeriod ||
            periodicity.timesPerPeriod > maxTimesFor(periodicity.type)))
      HabitValidationError.invalidTimesPerPeriod,
  };

  static Set<HabitValidationError> validateHabit({
    required String name,
    required String emoji,
    required Periodicity periodicity,
    required String? reminderTime,
    String? reminderMessage,
  }) {
    final trimmedName = name.trim();
    return {
      if (trimmedName.isEmpty) HabitValidationError.nameRequired,
      if (trimmedName.length > maxHabitNameLength)
        HabitValidationError.nameTooLong,
      if (emoji.trim().isEmpty) HabitValidationError.emojiRequired,
      ...validatePeriodicity(periodicity),
      if (reminderTime != null && !_timeRegex.hasMatch(reminderTime))
        HabitValidationError.invalidReminderTime,
      if (reminderMessage != null &&
          reminderMessage.trim().length > maxReminderMessageLength)
        HabitValidationError.reminderMessageTooLong,
    };
  }

  static Set<AmbitoValidationError> validateAmbito({
    required String name,
    required String emoji,
  }) {
    final trimmedName = name.trim();
    return {
      if (trimmedName.isEmpty) AmbitoValidationError.nameRequired,
      if (trimmedName.length > maxAmbitoNameLength)
        AmbitoValidationError.nameTooLong,
      if (emoji.trim().isEmpty) AmbitoValidationError.emojiRequired,
    };
  }
}
