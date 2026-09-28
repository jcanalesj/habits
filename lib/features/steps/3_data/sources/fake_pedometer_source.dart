import 'dart:async';

import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';

/// Contador simulado para tests: se le inyectan lecturas a mano.
class FakePedometerSource implements PedometerSource {
  FakePedometerSource({
    this.available = true,
    this.permission = PedometerPermission.granted,
    this.grantOnRequest = true,
    this.history = const {},
  });

  bool available;
  PedometerPermission permission;
  bool grantOnRequest;
  int requestCount = 0;
  DateTime? lastDayStart;

  /// Historial por instante de inicio consultado (solo iOS lo tiene).
  final Map<DateTime, int> history;

  final _controller = StreamController<PedometerSample>.broadcast();

  void emit(PedometerSample sample) => _controller.add(sample);

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<PedometerPermission> permissionStatus() async => permission;

  @override
  Future<PedometerPermission> requestPermission() async {
    requestCount++;
    if (grantOnRequest) permission = PedometerPermission.granted;
    return permission;
  }

  @override
  Stream<PedometerSample> updates({required DateTime dayStartUtc}) {
    lastDayStart = dayStartUtc;
    return _controller.stream;
  }

  @override
  Future<PedometerSample?> query(DateTime fromUtc, DateTime toUtc) async {
    final steps = history[fromUtc];
    if (steps == null) return null;
    return PedometerSample(at: toUtc, steps: steps);
  }

  void dispose() => _controller.close();
}
