enum PomodoroPhase { work, shortBreak, longBreak }

enum PomodoroStatus { idle, running, paused }

/// Estado del temporizador. Se basa en un INSTANTE DE FIN, no en ticks
/// acumulados: así sobrevive a cerrar la app y a que el reloj del sistema
/// duerma. Con la fase en pausa lo que se guarda es lo que queda.
class PomodoroState {
  const PomodoroState({
    required this.phase,
    required this.status,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.completedInCycle,
    this.endAtUtc,
    this.label = '',
  });

  const PomodoroState.initial(int workMinutes)
    : this(
        phase: PomodoroPhase.work,
        status: PomodoroStatus.idle,
        totalSeconds: workMinutes * 60,
        remainingSeconds: workMinutes * 60,
        completedInCycle: 0,
      );

  final PomodoroPhase phase;
  final PomodoroStatus status;

  /// Duración de la fase actual.
  final int totalSeconds;

  /// Lo que queda. En marcha se deriva de [endAtUtc]; en pausa o parado es
  /// el valor guardado.
  final int remainingSeconds;

  /// Pomodoros de concentración completados en el ciclo actual (0..n-1).
  final int completedInCycle;

  /// Instante de fin mientras está en marcha.
  final DateTime? endAtUtc;

  /// "¿En qué trabajas?": etiqueta de la sesión.
  final String label;

  bool get isRunning => status == PomodoroStatus.running;
  bool get isPaused => status == PomodoroStatus.paused;
  bool get isIdle => status == PomodoroStatus.idle;
  bool get isWork => phase == PomodoroPhase.work;

  double get progress =>
      totalSeconds == 0 ? 0 : 1 - remainingSeconds / totalSeconds;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    PomodoroStatus? status,
    int? totalSeconds,
    int? remainingSeconds,
    int? completedInCycle,
    DateTime? endAtUtc,
    bool clearEndAt = false,
    String? label,
  }) => PomodoroState(
    phase: phase ?? this.phase,
    status: status ?? this.status,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    completedInCycle: completedInCycle ?? this.completedInCycle,
    endAtUtc: clearEndAt ? null : (endAtUtc ?? this.endAtUtc),
    label: label ?? this.label,
  );

  Map<String, Object?> toJson() => {
    'phase': phase.name,
    'status': status.name,
    'totalSeconds': totalSeconds,
    'remainingSeconds': remainingSeconds,
    'completedInCycle': completedInCycle,
    'endAtMs': endAtUtc?.millisecondsSinceEpoch,
    'label': label,
  };

  static PomodoroState? fromJson(Map<String, Object?> json) {
    try {
      final endAtMs = json['endAtMs'] as int?;
      return PomodoroState(
        phase: PomodoroPhase.values.byName(json['phase'] as String),
        status: PomodoroStatus.values.byName(json['status'] as String),
        totalSeconds: json['totalSeconds'] as int,
        remainingSeconds: json['remainingSeconds'] as int,
        completedInCycle: json['completedInCycle'] as int,
        endAtUtc: endAtMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(endAtMs, isUtc: true),
        label: (json['label'] as String?) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is PomodoroState &&
      other.phase == phase &&
      other.status == status &&
      other.totalSeconds == totalSeconds &&
      other.remainingSeconds == remainingSeconds &&
      other.completedInCycle == completedInCycle &&
      other.endAtUtc == endAtUtc &&
      other.label == label;

  @override
  int get hashCode => Object.hash(
    phase,
    status,
    totalSeconds,
    remainingSeconds,
    completedInCycle,
    endAtUtc,
    label,
  );
}
