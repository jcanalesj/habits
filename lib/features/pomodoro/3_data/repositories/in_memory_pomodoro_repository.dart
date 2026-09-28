import 'dart:async';

import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/pomodoro/0_entity/entity.dart';
import 'package:habits/features/pomodoro/1_domain/domain.dart';

class InMemoryPomodoroRepository implements PomodoroRepository {
  InMemoryPomodoroRepository({PomodoroConfig? config})
    : _config = config ?? const PomodoroConfig();

  PomodoroConfig _config;
  final _sessions = <PomodoroSession>[];
  final _configController = StreamController<PomodoroConfig>.broadcast();
  final _sessionsController = StreamController<void>.broadcast();
  int _sequence = 0;

  List<PomodoroSession> get sessions => List.unmodifiable(_sessions);

  @override
  Stream<PomodoroConfig> watchConfig() async* {
    yield _config;
    yield* _configController.stream;
  }

  @override
  Future<void> saveConfig(PomodoroConfig config) async {
    _config = config;
    _configController.add(config);
  }

  @override
  Stream<List<PomodoroSession>> watchSessionsBetween(
    LogicalDate from,
    LogicalDate to,
  ) async* {
    List<PomodoroSession> select() =>
        (_sessions
            .where(
              (session) =>
                  session.day.isAtOrAfter(from) && session.day.isAtOrBefore(to),
            )
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt)));
    yield select();
    yield* _sessionsController.stream.map((_) => select());
  }

  @override
  Future<void> addSession({
    required LogicalDate day,
    required DateTime startedAt,
    required int durationMinutes,
    String? label,
  }) async {
    _sessions.add(
      PomodoroSession(
        id: 'session-${++_sequence}',
        day: day,
        startedAt: startedAt,
        durationMinutes: durationMinutes,
        label: label,
      ),
    );
    _sessionsController.add(null);
  }

  @override
  Future<void> deleteAllSessions() async {
    _sessions.clear();
    _sessionsController.add(null);
  }

  void dispose() {
    _configController.close();
    _sessionsController.close();
  }
}

class InMemoryPomodoroStateStore implements PomodoroStateStore {
  PomodoroState? state;

  @override
  PomodoroState? load() => state;

  @override
  Future<void> save(PomodoroState? state) async => this.state = state;
}
