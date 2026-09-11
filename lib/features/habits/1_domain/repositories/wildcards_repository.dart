import 'package:habits/features/habits/0_entity/entity.dart';

/// Contrato del sistema de comodines.
///
/// Es deliberadamente un repositorio APARTE del de hábitos: los comodines
/// son *entitlements* con relación futura con anuncios, compras y Premium, y
/// tienen un contrato distinto al de los datos normales (§39).
///
///  - Datos normales (hábitos, registros): offline-first, idempotentes,
///    tolerantes a la falta de red.
///  - Comodines: **requieren conectividad**. Conceder y consumir se validan
///    en servidor y se ejecutan de forma atómica. Preferimos fallar sin red
///    a permitir una escritura local que el servidor revierte en silencio.
abstract class WildcardsRepository {
  /// Saldo actual; null mientras el documento no existe.
  Stream<WildcardBalance?> watchBalance();

  Future<WildcardBalance?> fetchBalance();

  /// Crea el saldo inicial si no existe y aplica las concesiones mensuales
  /// pendientes. Idempotente: llamarla muchas veces el mismo mes no concede
  /// de más (§20).
  ///
  /// [currentYearMonth] es `año * 12 + mes` del instante actual.
  Future<WildcardBalance> ensureGranted(int currentYearMonth);

  /// Días protegidos por comodín dentro de [from, to] inclusive.
  Stream<Set<LogicalDate>> watchProtectedDays();

  Future<Set<LogicalDate>> fetchProtectedDays();

  /// Consume un comodín y protege [day] de forma ATÓMICA (§25).
  ///
  /// Ambas escrituras viajan en una transacción y las Security Rules atan
  /// una a la otra en las dos direcciones: no se puede proteger un día sin
  /// pagarlo ni decrementar el saldo sin crear el día.
  Future<void> consumeForDay(LogicalDate day);
}
