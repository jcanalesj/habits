import 'dart:convert';

import 'package:habits/features/steps/1_domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado del contador acumulado en `shared_preferences`, por usuario.
class SharedStepLedgerStore implements StepLedgerStore {
  SharedStepLedgerStore(this._preferences, {required String userId})
    : _key = 'pedometer_ledger_$userId';

  final SharedPreferences _preferences;
  final String _key;

  @override
  Map<String, Object?>? load() {
    final raw = _preferences.getString(_key);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).cast<String, Object?>();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Map<String, Object?> json) =>
      _preferences.setString(_key, jsonEncode(json));
}
