import 'dart:async';

/// Combina el último valor de cuatro streams en uno solo (combineLatest).
/// Emite en cuanto los cuatro han emitido al menos una vez y después con
/// cada cambio de cualquiera. Los errores se propagan.
Stream<R> combineLatest4<A, B, C, D, R>(
  Stream<A> streamA,
  Stream<B> streamB,
  Stream<C> streamC,
  Stream<D> streamD,
  R Function(A a, B b, C c, D d) combine,
) {
  late final StreamController<R> controller;
  final subscriptions = <StreamSubscription<dynamic>>[];
  late A a;
  late B b;
  late C c;
  late D d;
  var hasA = false, hasB = false, hasC = false, hasD = false;

  void emit() {
    if (hasA && hasB && hasC && hasD) controller.add(combine(a, b, c, d));
  }

  controller = StreamController<R>(
    onListen: () {
      subscriptions.addAll([
        streamA.listen((v) {
          a = v;
          hasA = true;
          emit();
        }, onError: controller.addError),
        streamB.listen((v) {
          b = v;
          hasB = true;
          emit();
        }, onError: controller.addError),
        streamC.listen((v) {
          c = v;
          hasC = true;
          emit();
        }, onError: controller.addError),
        streamD.listen((v) {
          d = v;
          hasD = true;
          emit();
        }, onError: controller.addError),
      ]);
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
