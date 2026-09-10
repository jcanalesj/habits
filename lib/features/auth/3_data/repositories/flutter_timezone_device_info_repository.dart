import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:habits/features/auth/1_domain/repositories/device_info_repository.dart';

/// Zona horaria IANA del dispositivo vía `flutter_timezone`. Si el plugin
/// no está disponible (tests, plataforma sin soporte) cae al nombre de zona
/// del runtime de Dart, que también es un string válido para las reglas.
class FlutterTimezoneDeviceInfoRepository implements DeviceInfoRepository {
  @override
  Future<String> currentTimezone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      if (info.identifier.isNotEmpty) return info.identifier;
    } catch (_) {
      // Sin plugin: usamos el fallback de abajo.
    }
    return DateTime.now().timeZoneName;
  }
}
