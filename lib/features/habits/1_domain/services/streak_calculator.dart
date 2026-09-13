import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/0_entity/streak_state.dart';

/// Motor de la racha general. **Dart puro**: sin Firebase, sin Riverpod, sin
/// BuildContext y sin `DateTime.now()`. Todo entra por parámetros, así que
/// es determinista, idempotente y trivial de testear (§33).
///
/// Regla fundamental (§1): si el usuario completa AL MENOS UN hábito en un
/// día natural, ese día cuenta para la racha. Completar 1 hábito o 20
/// produce exactamente el mismo efecto: +1 día. La periodicidad de los
/// hábitos no interviene (§5).
///
/// Vocabulario del algoritmo:
///  - **día de actividad**: día con al menos un registro de hábito
///    realmente completado;
///  - **día protegido**: día sin actividad que un comodín mantiene unido a
///    la cadena;
///  - **día mantenido**: día de actividad o día protegido;
///  - **cadena**: racha maximal de días mantenidos consecutivos;
///  - **valor de una cadena**: cuántos de sus días son de actividad. Los
///    protegidos mantienen la continuidad pero NO suman (§16/§32).
abstract final class StreakCalculator {
  /// Versión del algoritmo. Se guarda en la caché para poder invalidarla
  /// cuando cambien las reglas de cálculo.
  static const algorithmVersion = 2;

  /// Calcula el estado de la racha a fecha de [today].
  ///
  /// [activityDays] y [protectedDays] son conjuntos de días lógicos ya
  /// resueltos en la zona horaria del perfil. Deben venir del histórico
  /// COMPLETO, incluidos los registros de hábitos eliminados con soft
  /// delete: borrar un hábito hoy no reescribe la racha del pasado (§30).
  static StreakState calculate({
    required Set<LogicalDate> activityDays,
    required Set<LogicalDate> protectedDays,
    required LogicalDate today,
  }) {
    // §3: la racha no empieza al crear la cuenta, sino con el primer hábito
    // completado. Sin actividad no hay racha, ni fallos, ni nada que
    // proteger, por lejos que quede el registro de usuario.
    if (activityDays.isEmpty) return StreakState.empty;

    bool isActivity(LogicalDate d) => activityDays.contains(d);
    bool isKept(LogicalDate d) => isActivity(d) || protectedDays.contains(d);

    final firstDay = activityDays.reduce((a, b) => a.isBefore(b) ? a : b);
    final lastActivityDay = activityDays.reduce((a, b) => a.isAfter(b) ? a : b);

    /// Valor de la cadena que termina en [end]: retrocede mientras los días
    /// se mantengan y cuenta solo los de actividad. Acotado por [firstDay],
    /// así que siempre termina.
    int chainValueEndingAt(LogicalDate end) {
      var value = 0;
      var cursor = end;
      while (cursor.isAtOrAfter(firstDay) && isKept(cursor)) {
        if (isActivity(cursor)) value++;
        cursor = cursor.previous;
      }
      return value;
    }

    final yesterday = today.previous;

    // ---- ¿hay una oportunidad de rescate abierta? -------------------------
    // Solo se puede salvar el día INMEDIATAMENTE anterior, y solo durante
    // hoy (§17). Como la ventana se deriva de `today`, al pasar de día
    // desaparece sola: no hay estado que caducar ni tarea programada.
    final yesterdayIsGap = !isKept(yesterday);
    final streakAtRisk = yesterdayIsGap
        ? chainValueEndingAt(yesterday.previous)
        : 0;
    final canRescue = yesterdayIsGap && streakAtRisk > 0;

    // ---- racha actual determinista ---------------------------------------
    // Si ayer es un hueco sin proteger, la cadena anterior YA está rota: la
    // racha viva es la que empieza hoy (0, o 1 si hoy hay actividad). El
    // valor en peligro viaja aparte, en `rescue`.
    final int currentStreak;
    if (isActivity(today)) {
      currentStreak = chainValueEndingAt(today);
    } else if (isKept(yesterday)) {
      currentStreak = chainValueEndingAt(yesterday);
    } else {
      currentStreak = 0;
    }

    final StreakStatus status;
    if (canRescue) {
      status = StreakStatus.atRisk;
    } else if (isActivity(today)) {
      status = StreakStatus.completedToday;
    } else if (isKept(yesterday)) {
      status = StreakStatus.pendingToday;
    } else {
      status = StreakStatus.none;
    }

    return StreakState(
      currentStreak: currentStreak,
      bestStreak: _bestStreak(
        firstDay: firstDay,
        lastDay: lastActivityDay,
        isActivity: isActivity,
        isKept: isKept,
        // La cadena viva de hoy puede ser la mejor de la historia.
        floor: currentStreak,
      ),
      lastActivityDay: lastActivityDay,
      status: status,
      rescue: canRescue
          ? RescueOpportunity(
              day: yesterday,
              streakAtRisk: streakAtRisk,
              // Proteger ayer reconecta la cadena; la actividad de hoy, si
              // la hay, sí suma su día (§16).
              streakIfRescued: streakAtRisk + (isActivity(today) ? 1 : 0),
            )
          : null,
    );
  }

  /// Recorre el histórico una sola vez contando el valor de cada cadena.
  ///
  /// Solo hace falta barrer entre el primer y el último día de ACTIVIDAD:
  /// los días protegidos posteriores al último día de actividad no aportan
  /// valor a ninguna cadena.
  static int _bestStreak({
    required LogicalDate firstDay,
    required LogicalDate lastDay,
    required bool Function(LogicalDate) isActivity,
    required bool Function(LogicalDate) isKept,
    required int floor,
  }) {
    var best = floor;
    var running = 0;
    for (
      var cursor = firstDay;
      cursor.isAtOrBefore(lastDay);
      cursor = cursor.next
    ) {
      if (isKept(cursor)) {
        if (isActivity(cursor)) running++;
        if (running > best) best = running;
      } else {
        running = 0;
      }
    }
    return best;
  }
}
