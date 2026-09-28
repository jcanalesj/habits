import 'package:flutter/services.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';

/// [PedometerSource] sobre los canales nativos declarados en
/// `AppDelegate.swift` (Core Motion) y `MainActivity.kt` (TYPE_STEP_COUNTER).
class PlatformPedometerSource implements PedometerSource {
  PlatformPedometerSource({MethodChannel? methods, EventChannel? events})
    : _methods = methods ?? const MethodChannel('constanza/pedometer'),
      _events = events ?? const EventChannel('constanza/pedometer/updates');

  final MethodChannel _methods;
  final EventChannel _events;

  static PedometerPermission _permission(Object? value) => switch (value) {
    'granted' => PedometerPermission.granted,
    'denied' => PedometerPermission.denied,
    _ => PedometerPermission.notDetermined,
  };

  @override
  Future<bool> isAvailable() async {
    try {
      return await _methods.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<PedometerPermission> permissionStatus() async =>
      _permission(await _methods.invokeMethod<String>('permissionStatus'));

  @override
  Future<PedometerPermission> requestPermission() async =>
      _permission(await _methods.invokeMethod<String>('requestPermission'));

  @override
  Stream<PedometerSample> updates({required DateTime dayStartUtc}) => _events
      .receiveBroadcastStream({'fromMs': dayStartUtc.millisecondsSinceEpoch})
      .map((event) => _sample((event as Map).cast<String, Object?>()));

  @override
  Future<PedometerSample?> query(DateTime fromUtc, DateTime toUtc) async {
    try {
      final result = await _methods.invokeMethod<Map>('query', {
        'fromMs': fromUtc.millisecondsSinceEpoch,
        'toMs': toUtc.millisecondsSinceEpoch,
      });
      if (result == null) return null;
      return _sample(result.cast<String, Object?>());
    } on MissingPluginException {
      return null;
    } on PlatformException {
      // Android no implementa `query`: el historial lo pone Firestore.
      return null;
    }
  }

  static PedometerSample _sample(Map<String, Object?> data) {
    final atMs = (data['atMs'] as num?)?.toInt();
    final distance = (data['distanceMeters'] as num?)?.round();
    return PedometerSample(
      at: atMs == null
          ? DateTime.now().toUtc()
          : DateTime.fromMillisecondsSinceEpoch(atMs, isUtc: true),
      steps: (data['steps'] as num?)?.toInt(),
      counter: (data['counter'] as num?)?.toInt(),
      distanceMeters: distance,
    );
  }
}
