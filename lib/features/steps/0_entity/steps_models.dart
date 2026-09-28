import 'package:habits/features/habits/0_entity/logical_date.dart';

/// Ajustes de la herramienta Pasos.
class StepsConfig {
  const StepsConfig({this.goal = defaultGoal, this.consented = false});

  final int goal;

  /// Consentimiento explícito para usar el sensor de movimiento.
  final bool consented;

  static const defaultGoal = 8000;
  static const minGoal = 500;
  static const maxGoal = 30000;
  static const goalStep = 500;

  bool get isValid => goal >= minGoal && goal <= maxGoal;

  StepsConfig copyWith({int? goal, bool? consented}) => StepsConfig(
    goal: goal ?? this.goal,
    consented: consented ?? this.consented,
  );

  @override
  bool operator ==(Object other) =>
      other is StepsConfig &&
      other.goal == goal &&
      other.consented == consented;

  @override
  int get hashCode => Object.hash(goal, consented);
}

/// Total de pasos de un día lógico, tal y como se guarda en la cuenta.
class StepsDay {
  const StepsDay({required this.day, required this.steps, this.distanceMeters});

  final LogicalDate day;
  final int steps;

  /// Distancia medida por el sensor (iOS); null si hay que estimarla.
  final int? distanceMeters;

  @override
  bool operator ==(Object other) =>
      other is StepsDay &&
      other.day == day &&
      other.steps == steps &&
      other.distanceMeters == distanceMeters;

  @override
  int get hashCode => Object.hash(day, steps, distanceMeters);
}

enum PedometerPermission { granted, denied, notDetermined }

/// Una lectura del contador nativo.
///
/// - iOS (Core Motion): [steps] son los pasos desde el instante pedido
///   (el inicio del día), con [distanceMeters] medida por el sistema.
/// - Android (`TYPE_STEP_COUNTER`): [counter] es el acumulado desde el último
///   arranque del dispositivo; [StepLedger] lo convierte en pasos del día.
class PedometerSample {
  const PedometerSample({
    required this.at,
    this.steps,
    this.counter,
    this.distanceMeters,
  });

  final DateTime at;
  final int? steps;
  final int? counter;
  final int? distanceMeters;

  bool get isCumulative => counter != null;
}
