import 'package:habits/features/steps/1_domain/domain.dart';

/// [StepsLiveNotification] en memoria para tests y escenarios simulados.
class FakeStepsLiveNotification implements StepsLiveNotification {
  FakeStepsLiveNotification({
    this.supported = true,
    this.enabled = false,
    this.result = StepsLiveNotificationResult.started,
  });

  bool supported;
  bool enabled;

  /// Respuesta de [start].
  StepsLiveNotificationResult result;

  final started = <StepsLiveNotificationConfig>[];
  final updated = <StepsLiveNotificationConfig>[];
  int stopCount = 0;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<StepsLiveNotificationResult> start(
    StepsLiveNotificationConfig config,
  ) async {
    started.add(config);
    if (result == StepsLiveNotificationResult.started) enabled = true;
    return result;
  }

  @override
  Future<void> update(StepsLiveNotificationConfig config) async {
    if (enabled) updated.add(config);
  }

  @override
  Future<void> stop() async {
    stopCount++;
    enabled = false;
  }
}
