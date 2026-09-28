/// Ajustes del temporizador. Todo en minutos.
class PomodoroConfig {
  const PomodoroConfig({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.pomodorosPerCycle = 4,
    this.autoStartBreaks = false,
    this.autoStartWork = false,
    this.sound = true,
    this.vibration = true,
  });

  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int pomodorosPerCycle;
  final bool autoStartBreaks;
  final bool autoStartWork;
  final bool sound;
  final bool vibration;

  static const workRange = (15, 60);
  static const shortBreakRange = (3, 15);
  static const longBreakRange = (10, 30);
  static const perCycleRange = (2, 6);

  bool get isValid =>
      workMinutes >= workRange.$1 &&
      workMinutes <= workRange.$2 &&
      shortBreakMinutes >= shortBreakRange.$1 &&
      shortBreakMinutes <= shortBreakRange.$2 &&
      longBreakMinutes >= longBreakRange.$1 &&
      longBreakMinutes <= longBreakRange.$2 &&
      pomodorosPerCycle >= perCycleRange.$1 &&
      pomodorosPerCycle <= perCycleRange.$2;

  PomodoroConfig copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? pomodorosPerCycle,
    bool? autoStartBreaks,
    bool? autoStartWork,
    bool? sound,
    bool? vibration,
  }) => PomodoroConfig(
    workMinutes: workMinutes ?? this.workMinutes,
    shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
    longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
    pomodorosPerCycle: pomodorosPerCycle ?? this.pomodorosPerCycle,
    autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
    autoStartWork: autoStartWork ?? this.autoStartWork,
    sound: sound ?? this.sound,
    vibration: vibration ?? this.vibration,
  );

  @override
  bool operator ==(Object other) =>
      other is PomodoroConfig &&
      other.workMinutes == workMinutes &&
      other.shortBreakMinutes == shortBreakMinutes &&
      other.longBreakMinutes == longBreakMinutes &&
      other.pomodorosPerCycle == pomodorosPerCycle &&
      other.autoStartBreaks == autoStartBreaks &&
      other.autoStartWork == autoStartWork &&
      other.sound == sound &&
      other.vibration == vibration;

  @override
  int get hashCode => Object.hash(
    workMinutes,
    shortBreakMinutes,
    longBreakMinutes,
    pomodorosPerCycle,
    autoStartBreaks,
    autoStartWork,
    sound,
    vibration,
  );
}
