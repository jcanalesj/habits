import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/pomodoro/0_entity/entity.dart';

abstract class PomodoroRepository {
  /// Ajustes guardados; los valores por defecto si aún no hay documento.
  Stream<PomodoroConfig> watchConfig();
  Future<void> saveConfig(PomodoroConfig config);

  /// Sesiones completadas entre dos días lógicos (ambos incluidos).
  Stream<List<PomodoroSession>> watchSessionsBetween(
    LogicalDate from,
    LogicalDate to,
  );
  Future<void> addSession({
    required LogicalDate day,
    required DateTime startedAt,
    required int durationMinutes,
    String? label,
  });
  Future<void> deleteAllSessions();
}

/// Persistencia LOCAL del temporizador en marcha (el instante de fin y la
/// fase). No va a Firestore: es estado del dispositivo.
abstract class PomodoroStateStore {
  PomodoroState? load();
  Future<void> save(PomodoroState? state);
}
