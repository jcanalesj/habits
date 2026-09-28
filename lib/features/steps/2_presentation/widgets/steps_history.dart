import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/steps/0_entity/entity.dart';

/// Resumen de un conjunto de días guardados. Dart puro, para poder probarlo.
class StepsHistorySummary {
  const StepsHistorySummary({
    required this.totalSteps,
    required this.daysWithData,
    required this.bestDay,
    required this.goalDays,
    required this.firstDay,
  });

  final int totalSteps;
  final int daysWithData;
  final StepsDay? bestDay;
  final int goalDays;
  final LogicalDate? firstDay;

  int get dailyAverage =>
      daysWithData == 0 ? 0 : (totalSteps / daysWithData).round();

  static StepsHistorySummary of(List<StepsDay> days, int goal) {
    var total = 0;
    var goalDays = 0;
    StepsDay? best;
    LogicalDate? first;
    for (final day in days) {
      total += day.steps;
      if (day.steps >= goal) goalDays++;
      if (best == null || day.steps > best.steps) best = day;
      if (first == null || day.day.isBefore(first)) first = day.day;
    }
    return StepsHistorySummary(
      totalSteps: total,
      daysWithData: days.where((day) => day.steps > 0).length,
      bestDay: best,
      goalDays: goalDays,
      firstDay: first,
    );
  }

  /// Días seguidos cumpliendo el objetivo hasta hoy. Si hoy aún no se ha
  /// cumplido, la racha vigente es la que termina ayer.
  static int goalStreak(List<StepsDay> days, int goal, LogicalDate today) {
    final byDay = {for (final day in days) day.day: day.steps};
    var cursor = (byDay[today] ?? 0) >= goal ? today : today.previous;
    var streak = 0;
    while ((byDay[cursor] ?? 0) >= goal) {
      streak++;
      cursor = cursor.previous;
    }
    return streak;
  }
}

/// Una barra del gráfico: etiqueta, valor y si alcanza el objetivo.
class StepsBar {
  const StepsBar({
    required this.label,
    required this.steps,
    this.reached = false,
    this.emphasized = false,
  });

  final String label;
  final int steps;
  final bool reached;
  final bool emphasized;
}

/// Agrega días en barras según el rango: por día (7 o 30 barras) o por mes.
abstract final class StepsChartBuilder {
  static List<StepsBar> daily(
    List<StepsDay> days,
    LogicalDate today,
    int count,
    int goal,
    String Function(LogicalDate day, int index) label,
  ) {
    final byDay = {for (final day in days) day.day: day.steps};
    return [
      for (var i = count - 1; i >= 0; i--)
        StepsBar(
          label: label(today.addDays(-i), count - 1 - i),
          steps: byDay[today.addDays(-i)] ?? 0,
          reached: (byDay[today.addDays(-i)] ?? 0) >= goal,
          emphasized: i == 0,
        ),
    ];
  }

  /// Total por mes (`año*12+mes`), en orden cronológico.
  static List<(int yearMonth, int steps, int days)> monthly(
    List<StepsDay> days,
  ) {
    final totals = <int, (int, int)>{};
    for (final day in days) {
      final current = totals[day.day.yearMonth] ?? (0, 0);
      totals[day.day.yearMonth] = (current.$1 + day.steps, current.$2 + 1);
    }
    final keys = totals.keys.toList()..sort();
    return [for (final key in keys) (key, totals[key]!.$1, totals[key]!.$2)];
  }
}
