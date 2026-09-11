/// Motivos de fallo de la feature de hábitos que entiende el dominio.
enum HabitsFailure {
  habitNotFound,

  /// El hábito está eliminado (soft delete): no admite registros.
  habitDeleted,
  ambitoNotFound,

  /// El ámbito General no puede eliminarse.
  generalAmbitoProtected,

  /// Sin permiso en backend (sesión inválida o datos de otro usuario).
  permissionDenied,
  network,
  unknown,
}

/// Motivos de fallo específicos del sistema de comodines.
enum WildcardFailure {
  /// Saldo 0: no hay comodín que gastar.
  noneAvailable,

  /// Ese día ya estaba protegido: un comodín no se puede usar dos veces
  /// sobre el mismo día (§25).
  dayAlreadyProtected,

  /// Solo se puede proteger el día inmediatamente anterior, y solo durante
  /// el día siguiente (§17). Fuera de esa ventana el pasado queda cerrado.
  rescueWindowClosed,

  /// Ese día sí tuvo actividad real: protegerlo no haría nada.
  dayHasActivity,

  /// Conceder o consumir un comodín exige conectividad: es un entitlement,
  /// no un dato offline-first (§39).
  requiresConnection,
  permissionDenied,
  unknown,
}

/// Error de la feature ya traducido a dominio. Lo lanzan los repositorios de
/// `3_data` y lo capturan los usecases para devolver resultados tipados.
class HabitsException implements Exception {
  const HabitsException(this.failure, {this.message});

  final HabitsFailure failure;
  final String? message;

  @override
  String toString() =>
      'HabitsException(${failure.name}${message == null ? '' : ': $message'})';
}

class WildcardException implements Exception {
  const WildcardException(this.failure, {this.message});

  final WildcardFailure failure;
  final String? message;

  @override
  String toString() =>
      'WildcardException(${failure.name}${message == null ? '' : ': $message'})';
}
