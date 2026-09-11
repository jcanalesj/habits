import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';

/// Textos localizados de periodicidad y de progreso de objetivos.
///
/// Vive aquí, en la capa de componentes, para que ni las entidades ni el
/// dominio conozcan la localización.
abstract final class PeriodicityLabel {
  /// "Todos los días", "3 veces por semana", "12 veces al mes"…
  static String of(AppLocalizations l10n, Periodicity periodicity) =>
      switch (periodicity.type) {
        PeriodicityType.daily => l10n.periodicityDailyLabel,
        PeriodicityType.weekly => l10n.periodicityWeeklyLabel(
          periodicity.timesPerPeriod,
        ),
        PeriodicityType.monthly => l10n.periodicityMonthlyLabel(
          periodicity.timesPerPeriod,
        ),
        PeriodicityType.yearly => l10n.periodicityYearlyLabel(
          periodicity.timesPerPeriod,
        ),
      };

  /// "esta semana", "este mes", "este año", "hoy".
  static String periodOf(AppLocalizations l10n, PeriodicityType type) =>
      switch (type) {
        PeriodicityType.daily => l10n.goalPeriodDay,
        PeriodicityType.weekly => l10n.goalPeriodWeek,
        PeriodicityType.monthly => l10n.goalPeriodMonth,
        PeriodicityType.yearly => l10n.goalPeriodYear,
      };

  /// "2 / 3 esta semana". Es PROGRESO DEL OBJETIVO, no una racha (§37).
  static String progressOf(AppLocalizations l10n, GoalProgress progress) =>
      '${l10n.goalProgressLabel(progress.completed, progress.goal)} '
      '${periodOf(l10n, progress.period.type)}';
}
