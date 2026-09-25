import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nombres con los que el tema viaja a Firestore y a SharedPreferences.
abstract final class ThemeModeCodec {
  static const system = 'system';
  static const light = 'light';
  static const dark = 'dark';

  static String encode(ThemeMode mode) => switch (mode) {
    // `system` solo existe para migrar instalaciones antiguas. La app ofrece
    // exclusivamente claro y oscuro, por lo que nunca vuelve a persistirlo.
    ThemeMode.system => light,
    ThemeMode.light => light,
    ThemeMode.dark => dark,
  };

  static ThemeMode? decode(String? value) => switch (value) {
    system => ThemeMode.light,
    light => ThemeMode.light,
    dark => ThemeMode.dark,
    _ => null,
  };
}

/// Copia local del tema elegido. Se lee antes del primer frame para que la
/// app no parpadee en claro antes de pasar a oscuro.
abstract interface class ThemeModePreferences {
  ThemeMode get mode;
  Future<void> setMode(ThemeMode mode);
}

class SharedThemeModePreferences implements ThemeModePreferences {
  SharedThemeModePreferences(this._preferences);

  static const key = 'theme_mode';
  final SharedPreferences _preferences;

  @override
  ThemeMode get mode =>
      ThemeModeCodec.decode(_preferences.getString(key)) ?? ThemeMode.light;

  @override
  Future<void> setMode(ThemeMode mode) =>
      _preferences.setString(key, ThemeModeCodec.encode(mode));
}

class MemoryThemeModePreferences implements ThemeModePreferences {
  MemoryThemeModePreferences([this._mode = ThemeMode.light]);

  ThemeMode _mode;

  @override
  ThemeMode get mode => _mode;

  @override
  Future<void> setMode(ThemeMode mode) async => _mode = mode;
}

final themeModePreferencesProvider = Provider<ThemeModePreferences>(
  (ref) => MemoryThemeModePreferences(),
);

/// Tema activo. Igual que la animación de bienvenida: la copia local manda
/// al arrancar y el perfil remoto la sincroniza entre dispositivos.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  StreamSubscription<ThemeMode?>? _remoteSubscription;

  @override
  ThemeMode build() {
    ref.onDispose(() {
      _remoteSubscription?.cancel();
    });
    ref.listen(authControllerProvider, (_, auth) {
      _watchRemote(auth.value?.id);
    }, fireImmediately: true);
    return ref.watch(themeModePreferencesProvider).mode;
  }

  void _watchRemote(String? userId) {
    unawaited(_remoteSubscription?.cancel());
    _remoteSubscription = null;
    if (userId == null) return;
    _remoteSubscription = ref
        .read(userProfileRepositoryProvider)
        .watchThemeMode(userId)
        .listen((mode) {
          if (mode == null) {
            // Perfil anterior a esta preferencia: se sube la copia local.
            unawaited(_persistRemote(userId, state));
            return;
          }
          if (mode == state) return;
          _applyMode(mode);
        });
  }

  void setMode(ThemeMode mode) {
    final supportedMode = mode == ThemeMode.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    _applyMode(supportedMode);
    final userId = ref.read(authControllerProvider).value?.id;
    if (userId != null) unawaited(_persistRemote(userId, supportedMode));
  }

  /// Tema al cerrar sesión: el siguiente usuario del dispositivo no hereda
  /// la preferencia visual del anterior. Al entrar, su perfil manda.
  void resetForSignOut() => _applyMode(ThemeMode.light);

  void _applyMode(ThemeMode mode) {
    state = mode;
    unawaited(ref.read(themeModePreferencesProvider).setMode(mode));
  }

  Future<void> _persistRemote(String userId, ThemeMode mode) async {
    try {
      await ref
          .read(userProfileRepositoryProvider)
          .updateThemeMode(userId, mode);
    } catch (error, stackTrace) {
      // La copia local ya está guardada: un fallo de red o de reglas no debe
      // convertir un ajuste visual en un error visible.
      debugPrint('No se pudo sincronizar themeMode: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
