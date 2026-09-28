import 'package:habits/features/habits/0_entity/logical_date.dart';

/// Estado persistido del contador acumulado de Android.
class StepLedgerState {
  const StepLedgerState({this.lastCounter, this.dayKey, this.todaySteps = 0});

  /// Último valor del sensor (acumulado desde el arranque).
  final int? lastCounter;

  /// Día lógico al que pertenece [todaySteps].
  final String? dayKey;
  final int todaySteps;

  Map<String, Object?> toJson() => {
    'lastCounter': lastCounter,
    'dayKey': dayKey,
    'todaySteps': todaySteps,
  };

  static StepLedgerState fromJson(Map<String, Object?> json) => StepLedgerState(
    lastCounter: json['lastCounter'] as int?,
    dayKey: json['dayKey'] as String?,
    todaySteps: (json['todaySteps'] as int?) ?? 0,
  );

  @override
  bool operator ==(Object other) =>
      other is StepLedgerState &&
      other.lastCounter == lastCounter &&
      other.dayKey == dayKey &&
      other.todaySteps == todaySteps;

  @override
  int get hashCode => Object.hash(lastCounter, dayKey, todaySteps);
}

/// Convierte el contador acumulado del sensor en pasos del día. Dart puro.
///
/// Reglas:
///  - la primera lectura fija la referencia y no suma nada;
///  - si el contador baja, el móvil se ha reiniciado: todo lo leído es nuevo;
///  - al cambiar de día, la diferencia desde la última lectura se atribuye al
///    día actual (no se puede saber cuántos pasos fueron antes de medianoche
///    si la app estaba cerrada; es el compromiso documentado).
abstract final class StepLedger {
  static StepLedgerState apply(
    StepLedgerState state,
    int counter,
    LogicalDate today,
  ) {
    final last = state.lastCounter;
    if (last == null) {
      return StepLedgerState(
        lastCounter: counter,
        dayKey: today.key,
        todaySteps: state.dayKey == today.key ? state.todaySteps : 0,
      );
    }
    final delta = counter < last ? counter : counter - last;
    final sameDay = state.dayKey == today.key;
    return StepLedgerState(
      lastCounter: counter,
      dayKey: today.key,
      todaySteps: (sameDay ? state.todaySteps : 0) + delta,
    );
  }
}
