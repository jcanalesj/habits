import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/features/steps/0_entity/entity.dart';

/// Persistencia en la cuenta: objetivo, consentimiento y un total por día.
/// Es el histórico completo desde que se usa Constanza.
abstract class StepsRepository {
  Stream<StepsConfig> watchConfig();
  Future<void> saveConfig(StepsConfig config);

  Stream<List<StepsDay>> watchDaysBetween(LogicalDate from, LogicalDate to);
  Future<void> upsertDay(StepsDay day);
}

/// Estado local del contador acumulado (Android), por usuario.
abstract class StepLedgerStore {
  Map<String, Object?>? load();
  Future<void> save(Map<String, Object?> json);
}
