import 'package:habits/features/steps/0_entity/entity.dart';

/// Contador de pasos del propio dispositivo. Es la única pieza que habla con
/// el canal nativo; el resto del dominio trabaja con [PedometerSample].
abstract class PedometerSource {
  Future<bool> isAvailable();
  Future<PedometerPermission> permissionStatus();
  Future<PedometerPermission> requestPermission();

  /// Lecturas en vivo. En iOS son los pasos desde [dayStartUtc] (también los
  /// dados con la app cerrada); en Android, el acumulado del sensor.
  Stream<PedometerSample> updates({required DateTime dayStartUtc});

  /// Pasos entre dos instantes, si la plataforma guarda historial (iOS
  /// conserva siete días). Null cuando no está soportado.
  Future<PedometerSample?> query(DateTime fromUtc, DateTime toUtc);
}
