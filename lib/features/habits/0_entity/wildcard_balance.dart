import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

part 'wildcard_balance.freezed.dart';

/// Saldo de comodines del usuario (`users/{uid}/comodines/saldo`).
///
/// Los comodines son un SALDO fungible, no están atados al mes que los
/// generó (§19). Se acumulan hasta un máximo de [maxAvailable]; ese máximo
/// aplica al saldo total, no por origen (§23).
///
/// Esto NO es caché: es fuente de verdad, y las Security Rules validan cada
/// transición. Los orígenes futuros (anuncio recompensado, compra, Premium)
/// entrarán por backend confiable y solo tendrán que sumar a `grantedTotal`
/// y a `available`; el modelo no cambia (§21/§22).
@freezed
abstract class WildcardBalance with _$WildcardBalance {
  const factory WildcardBalance({
    /// Comodines disponibles ahora mismo, 0..[maxAvailable].
    @Default(0) int available,

    /// Último mes en que se concedió el comodín gratuito, como `año*12+mes`.
    /// Es monótono: nunca retrocede, lo que hace la concesión idempotente.
    @Default(0) int lastGrantYearMonth,

    /// Total histórico concedido, solo para auditoría (§20).
    @Default(0) int grantedTotal,

    /// Último día protegido. Las Security Rules lo usan para atar el
    /// decremento del saldo a la creación del día protegido (§25).
    LogicalDate? lastProtectedDay,
  }) = _WildcardBalance;

  const WildcardBalance._();

  /// Tope de saldo disponible (§23).
  static const maxAvailable = 3;

  static const empty = WildcardBalance();

  bool get hasAny => available > 0;
  bool get isFull => available >= maxAvailable;
}

/// Día cuya ausencia de actividad quedó protegida por un comodín
/// (`users/{uid}/diasProtegidos/{YYYY-MM-DD}`).
///
/// Un día protegido NO crea un registro falso, no marca ningún hábito y no
/// rellena el calendario del hábito (§15). Solo mantiene la continuidad de
/// la racha general, y nunca suma un día (§16).
@freezed
abstract class ProtectedDay with _$ProtectedDay {
  const factory ProtectedDay({
    required LogicalDate day,
    DateTime? createdAt,
  }) = _ProtectedDay;
}
