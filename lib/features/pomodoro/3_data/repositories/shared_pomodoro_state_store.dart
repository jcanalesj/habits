import 'dart:convert';

import 'package:habits/features/pomodoro/0_entity/entity.dart';
import 'package:habits/features/pomodoro/1_domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda el temporizador en `shared_preferences`, por usuario.
class SharedPomodoroStateStore implements PomodoroStateStore {
  SharedPomodoroStateStore(this._preferences, {required String userId})
    : _key = 'pomodoro_state_$userId';

  final SharedPreferences _preferences;
  final String _key;

  @override
  PomodoroState? load() {
    final raw = _preferences.getString(_key);
    if (raw == null) return null;
    try {
      return PomodoroState.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(PomodoroState? state) async {
    if (state == null) {
      await _preferences.remove(_key);
      return;
    }
    await _preferences.setString(_key, jsonEncode(state.toJson()));
  }
}
