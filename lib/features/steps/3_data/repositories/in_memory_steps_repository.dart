import 'dart:async';

import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';

class InMemoryStepsRepository implements StepsRepository {
  InMemoryStepsRepository({
    StepsConfig? config,
    Iterable<StepsDay> seeded = const [],
  }) : _config = config ?? const StepsConfig() {
    for (final day in seeded) {
      days[day.day] = day;
    }
  }

  StepsConfig _config;
  final days = <LogicalDate, StepsDay>{};
  final _configController = StreamController<StepsConfig>.broadcast();
  final _daysController = StreamController<void>.broadcast();

  StepsConfig get config => _config;

  @override
  Stream<StepsConfig> watchConfig() async* {
    yield _config;
    yield* _configController.stream;
  }

  @override
  Future<void> saveConfig(StepsConfig config) async {
    _config = config;
    _configController.add(config);
  }

  @override
  Stream<List<StepsDay>> watchDaysBetween(
    LogicalDate from,
    LogicalDate to,
  ) async* {
    List<StepsDay> select() => [
      for (final day in days.values)
        if (day.day.isAtOrAfter(from) && day.day.isAtOrBefore(to)) day,
    ];
    yield select();
    yield* _daysController.stream.map((_) => select());
  }

  @override
  Future<void> upsertDay(StepsDay day) async {
    days[day.day] = day;
    _daysController.add(null);
  }

  void dispose() {
    _configController.close();
    _daysController.close();
  }
}

class InMemoryStepLedgerStore implements StepLedgerStore {
  Map<String, Object?>? json;

  @override
  Map<String, Object?>? load() => json;

  @override
  Future<void> save(Map<String, Object?> json) async => this.json = json;
}
