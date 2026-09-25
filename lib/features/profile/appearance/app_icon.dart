import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/local_preferences.dart';

/// Iconos de la app disponibles. El `name` es el identificador que entienden
/// los canales nativos (MainActivity.kt y AppDelegate.swift).
enum AppIconOption {
  classic,
  crown,
  yarn;

  bool get isPremium => this != classic;

  String get previewAsset => 'assets/images/app_icons/$name.png';
}

abstract interface class AppIconService {
  Future<AppIconOption> current();
  Future<void> set(AppIconOption icon);
}

/// Cambia el icono del launcher: `activity-alias` en Android e iconos
/// alternativos del catálogo en iOS.
class PlatformAppIconService implements AppIconService {
  static const _channel = MethodChannel('constanza/app_icon');

  @override
  Future<AppIconOption> current() async {
    try {
      final id = await _channel.invokeMethod<String>('current');
      return AppIconOption.values.firstWhere(
        (icon) => icon.name == id,
        orElse: () => AppIconOption.classic,
      );
    } on MissingPluginException {
      // Web, escritorio y tests: solo existe el icono por defecto.
      return AppIconOption.classic;
    }
  }

  @override
  Future<void> set(AppIconOption icon) =>
      _channel.invokeMethod<void>('set', {'id': icon.name});
}

final appIconServiceProvider = Provider<AppIconService>(
  (ref) => PlatformAppIconService(),
);

/// Icono elegido. Se guarda en las preferencias del dispositivo (no en
/// Firestore: el icono es de cada móvil) y el sistema lo aplica cuando puede;
/// en Android, al pasar la app a segundo plano.
final appIconProvider = AsyncNotifierProvider<AppIconController, AppIconOption>(
  AppIconController.new,
);

class AppIconController extends AsyncNotifier<AppIconOption> {
  @override
  Future<AppIconOption> build() {
    ref.listen(isPremiumProvider, (_, _) => _enforceEntitlement());
    return _restore().then((icon) {
      Future.microtask(_enforceEntitlement);
      return icon;
    });
  }

  static const _key = 'app_icon';

  AppIconOption? get _stored {
    final id = ref.read(sharedPreferencesProvider)?.getString(_key);
    return AppIconOption.values.where((icon) => icon.name == id).firstOrNull;
  }

  /// La preferencia manda: si el sistema no llegó a aplicarla (la app murió
  /// antes de tiempo), se vuelve a pedir.
  Future<AppIconOption> _restore() async {
    final service = ref.read(appIconServiceProvider);
    final system = await service.current();
    final stored = _stored;
    if (stored == null) return system;
    if (stored != system) {
      try {
        await service.set(stored);
      } catch (error) {
        debugPrint('No se pudo reaplicar el icono guardado: $error');
      }
    }
    return stored;
  }

  /// Sin Premium solo vale el icono
  /// clásico: si había uno Premium puesto, se restaura el de por defecto.
  Future<void> _enforceEntitlement() async {
    // Sin sesión o con la suscripción aún cargando no se sabe nada: mejor
    // no tocar el icono que quitárselo a quien sí paga.
    if (ref.read(authControllerProvider).value == null) return;
    final subscription = ref.read(isPremiumProvider);
    if (subscription.isLoading || !subscription.hasValue) return;
    if (subscription.requireValue) return;
    final icon = await future;
    if (!icon.isPremium) return;
    try {
      await select(AppIconOption.classic);
    } catch (error) {
      debugPrint('No se pudo restaurar el icono clásico: $error');
    }
  }

  Future<void> select(AppIconOption icon) async {
    await ref.read(appIconServiceProvider).set(icon);
    await ref.read(sharedPreferencesProvider)?.setString(_key, icon.name);
    state = AsyncData(icon);
  }
}
