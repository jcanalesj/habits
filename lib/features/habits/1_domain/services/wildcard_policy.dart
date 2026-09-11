import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/habits/0_entity/wildcard_balance.dart';

/// Reglas puras del sistema de comodines. Sin Firebase y sin reloj propio:
/// todo entra por parámetros para poder testear cambios de mes, de año y
/// meses enteros sin abrir la app (§42).
///
/// Las Security Rules replican exactamente esta aritmética, de modo que la
/// idempotencia y el tope de saldo no dependen de que el cliente se porte
/// bien (§38).
abstract final class WildcardPolicy {
  /// Saldo máximo disponible (§23). El tope aplica al saldo total, no por
  /// origen: no son "3 gratuitos + 3 de anuncios + 3 premium".
  static const maxAvailable = WildcardBalance.maxAvailable;

  /// Saldo con el que arranca un usuario nuevo: la concesión del mes en
  /// curso.
  static WildcardBalance initial(int currentYearMonth) => WildcardBalance(
    available: 1,
    lastGrantYearMonth: currentYearMonth,
    grantedTotal: 1,
  );

  /// Aplica las concesiones mensuales pendientes.
  ///
  /// Concede +1 por cada mes transcurrido desde la última concesión, con
  /// tope [maxAvailable]. Así un usuario que no abre la app durante tres
  /// meses recupera lo que le correspondía sin exceder el máximo (§20), y
  /// abrir la app cien veces el mismo día no concede nada extra: la función
  /// es idempotente porque `lastGrantYearMonth` es monótono.
  ///
  /// Ejemplos (§19): 0→1, 1→2, 2→3, 3→3.
  static WildcardBalance applyMonthlyGrants(
    WildcardBalance balance,
    int currentYearMonth,
  ) {
    final elapsedMonths = currentYearMonth - balance.lastGrantYearMonth;
    if (elapsedMonths <= 0) return balance;

    final target = balance.available + elapsedMonths;
    final capped = target > maxAvailable ? maxAvailable : target;
    final granted = capped - balance.available;

    return balance.copyWith(
      available: capped,
      lastGrantYearMonth: currentYearMonth,
      grantedTotal: balance.grantedTotal + granted,
    );
  }

  /// Si [day] se puede rescatar estando hoy a [today].
  ///
  /// Solo el día inmediatamente anterior, y solo durante todo el día de hoy
  /// (§17). Al empezar el día siguiente el pasado queda cerrado, aunque el
  /// usuario tenga comodines, consiga más, pague o vea anuncios.
  static bool isWithinRescueWindow(LogicalDate day, LogicalDate today) =>
      day == today.previous;
}
