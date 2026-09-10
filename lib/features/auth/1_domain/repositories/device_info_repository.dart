/// Información del dispositivo que necesita el dominio sin depender de
/// Flutter ni de plugins.
abstract class DeviceInfoRepository {
  /// Zona horaria IANA actual (p. ej. `Europe/Madrid`).
  Future<String> currentTimezone();
}
