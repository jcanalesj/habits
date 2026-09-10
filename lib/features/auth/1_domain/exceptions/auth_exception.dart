import 'package:habits/features/auth/0_entity/entity.dart';

/// Error de autenticación ya traducido a dominio. Lo lanzan los
/// repositorios de `3_data` y lo capturan los usecases para devolver un
/// resultado `Failed` tipado, sin que presentación conozca al proveedor.
class AuthException implements Exception {
  const AuthException(this.failure, {this.message});

  final AuthFailure failure;

  /// Mensaje técnico del proveedor, solo para logs.
  final String? message;

  @override
  String toString() =>
      'AuthException(${failure.name}${message == null ? '' : ': $message'})';
}
