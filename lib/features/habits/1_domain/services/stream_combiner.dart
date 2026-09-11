import 'dart:async';

/// Combina el último valor de N streams en uno solo (combineLatest).
/// Emite en cuanto todos han emitido al menos una vez y después con cada
/// cambio de cualquiera. Los errores se propagan.
Stream<R> combineLatestN<R>(
  List<Stream<dynamic>> streams,
  R Function(List<dynamic> values) combine,
) {
  late final StreamController<R> controller;
  final subscriptions = <StreamSubscription<dynamic>>[];
  final values = List<dynamic>.filled(streams.length, null);
  final seen = List<bool>.filled(streams.length, false);

  void emit() {
    if (seen.every((it) => it)) controller.add(combine(values));
  }

  controller = StreamController<R>(
    onListen: () {
      for (var i = 0; i < streams.length; i++) {
        final index = i;
        subscriptions.add(
          streams[index].listen((value) {
            values[index] = value;
            seen[index] = true;
            emit();
          }, onError: controller.addError),
        );
      }
    },
    onCancel: () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      subscriptions.clear();
    },
  );
  return controller.stream;
}
