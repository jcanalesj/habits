import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contador que sube cada vez que puede haber cambiado algo FUERA de la app:
/// al volver de segundo plano (otro día, otra hora, permisos cambiados en
/// Ajustes del sistema) o tras pedir un permiso.
///
/// Quien dependa de ese estado externo lo observa y se recalcula: el día
/// lógico de hoy, el permiso de notificaciones, los recordatorios.
final systemStateTickProvider = NotifierProvider<SystemStateTick, int>(
  SystemStateTick.new,
);

class SystemStateTick extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
