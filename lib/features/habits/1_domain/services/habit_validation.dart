/// Reglas de validación de hábitos y ámbitos. Coinciden con los límites que
/// imponen las Security Rules para que un dato válido aquí nunca sea
/// rechazado por el backend.
enum HabitValidationError {
  nameRequired,
  nameTooLong,
  emojiRequired,
  invalidRestDays,
  invalidRecoveryCooldown,
  recoveryTaskTooLong,
  invalidReminderTime,
}

enum AmbitoValidationError { nameRequired, nameTooLong, emojiRequired }

abstract final class HabitValidation {
  static const maxHabitNameLength = 60;
  static const maxAmbitoNameLength = 40;
  static const maxRecoveryTaskLength = 120;
  static const maxRestDays = 366;
  static const minRecoveryCooldownDays = 1;
  static const maxRecoveryCooldownDays = 365;

  static final _timeRegex = RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9]$');

  static Set<HabitValidationError> validateHabit({
    required String name,
    required String emoji,
    required int restDaysAllowed,
    required String? recoveryTask,
    required int recoveryCooldownDays,
    required String? reminderTime,
  }) {
    final trimmedName = name.trim();
    return {
      if (trimmedName.isEmpty) HabitValidationError.nameRequired,
      if (trimmedName.length > maxHabitNameLength)
        HabitValidationError.nameTooLong,
      if (emoji.trim().isEmpty) HabitValidationError.emojiRequired,
      if (restDaysAllowed < 0 || restDaysAllowed > maxRestDays)
        HabitValidationError.invalidRestDays,
      if (recoveryCooldownDays < minRecoveryCooldownDays ||
          recoveryCooldownDays > maxRecoveryCooldownDays)
        HabitValidationError.invalidRecoveryCooldown,
      if (recoveryTask != null &&
          recoveryTask.trim().length > maxRecoveryTaskLength)
        HabitValidationError.recoveryTaskTooLong,
      if (reminderTime != null && !_timeRegex.hasMatch(reminderTime))
        HabitValidationError.invalidReminderTime,
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
