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
