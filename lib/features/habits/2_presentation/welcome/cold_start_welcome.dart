import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:habits/localization/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class WelcomeAnimationPreferences {
  bool get enabled;
  Future<void> setEnabled(bool enabled);
}

class SharedWelcomeAnimationPreferences implements WelcomeAnimationPreferences {
  SharedWelcomeAnimationPreferences(this._preferences);

  static const _key = 'welcome_animation_enabled';
  final SharedPreferences _preferences;

  @override
  bool get enabled => _preferences.getBool(_key) ?? true;

  @override
  Future<void> setEnabled(bool enabled) => _preferences.setBool(_key, enabled);
}

class MemoryWelcomeAnimationPreferences implements WelcomeAnimationPreferences {
  bool _enabled = true;

  @override
  bool get enabled => _enabled;

  @override
  Future<void> setEnabled(bool enabled) async => _enabled = enabled;
}

final welcomeAnimationPreferencesProvider =
    Provider<WelcomeAnimationPreferences>(
      (ref) => MemoryWelcomeAnimationPreferences(),
    );

final welcomeAnimationEnabledProvider =
    NotifierProvider<WelcomeAnimationController, bool>(
      WelcomeAnimationController.new,
    );

final remoteWelcomeAnimationEnabledProvider = StreamProvider<bool>((ref) {
  final local = ref.watch(welcomeAnimationPreferencesProvider).enabled;
  final userId = ref.watch(authControllerProvider).value?.id;
  if (userId == null) return Stream.value(local);
  return ref
      .watch(userProfileRepositoryProvider)
      .watchWelcomeAnimationEnabled(userId)
      .map((remote) => remote ?? local);
});

final customMotivationMessagesProvider =
    NotifierProvider<CustomMotivationMessagesController, List<String>>(
      CustomMotivationMessagesController.new,
    );

final remoteCustomMotivationMessagesProvider = StreamProvider<List<String>>((
  ref,
) {
  final userId = ref.watch(authControllerProvider).value?.id;
  if (userId == null) return Stream.value(const []);
  return ref
      .watch(userProfileRepositoryProvider)
      .watchCustomMotivationMessages(userId);
});

final isPremiumProvider = StreamProvider<bool>((ref) {
  final userId = ref.watch(authControllerProvider).value?.id;
  if (userId == null) return Stream.value(false);
  return ref.watch(userProfileRepositoryProvider).watchIsPremium(userId);
});

class CustomMotivationMessagesController extends Notifier<List<String>> {
  StreamSubscription<List<String>>? _remoteSubscription;

  @override
  List<String> build() {
    ref.onDispose(() => _remoteSubscription?.cancel());
    ref.listen(authControllerProvider, (_, auth) {
      _watchRemote(auth.value?.id);
    }, fireImmediately: true);
    return const [];
  }

  void _watchRemote(String? userId) {
    unawaited(_remoteSubscription?.cancel());
    _remoteSubscription = null;
    if (userId == null) return;
    _remoteSubscription = ref
        .read(userProfileRepositoryProvider)
        .watchCustomMotivationMessages(userId)
        .listen((messages) => state = messages);
  }

  void add(String message) => _set([...state, message]);

  void update(int index, String message) => _set([
    for (var i = 0; i < state.length; i++) i == index ? message : state[i],
  ]);

  void remove(int index) => _set([
    for (var i = 0; i < state.length; i++)
      if (i != index) state[i],
  ]);

  void _set(List<String> messages) {
    state = messages;
    final userId = ref.read(authControllerProvider).value?.id;
    if (userId != null) unawaited(_persist(userId, messages));
  }

  Future<void> _persist(String userId, List<String> messages) async {
    try {
      await ref
          .read(userProfileRepositoryProvider)
          .updateCustomMotivationMessages(userId, messages);
    } catch (error, stackTrace) {
      debugPrint('No se pudieron sincronizar los mensajes: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

class WelcomeAnimationController extends Notifier<bool> {
  StreamSubscription<bool?>? _remoteSubscription;

  @override
  bool build() {
    ref.onDispose(() => _remoteSubscription?.cancel());
    ref.listen(authControllerProvider, (_, auth) {
      _watchRemote(auth.value?.id);
    }, fireImmediately: true);
    return ref.watch(welcomeAnimationPreferencesProvider).enabled;
  }

  void _watchRemote(String? userId) {
    unawaited(_remoteSubscription?.cancel());
    _remoteSubscription = null;
    if (userId == null) return;
    _remoteSubscription = ref
        .read(userProfileRepositoryProvider)
        .watchWelcomeAnimationEnabled(userId)
        .listen((enabled) {
          if (enabled == null) {
            unawaited(_persistRemote(userId, state));
            return;
          }
          state = enabled;
          unawaited(
            ref.read(welcomeAnimationPreferencesProvider).setEnabled(enabled),
          );
        });
  }

  void setEnabled(bool enabled) {
    state = enabled;
    unawaited(
      ref.read(welcomeAnimationPreferencesProvider).setEnabled(enabled),
    );
    final userId = ref.read(authControllerProvider).value?.id;
    if (userId != null) {
      unawaited(_persistRemote(userId, enabled));
    }
  }

  Future<void> _persistRemote(String userId, bool enabled) async {
    try {
      await ref
          .read(userProfileRepositoryProvider)
          .updateWelcomeAnimationEnabled(userId, enabled);
    } catch (error, stackTrace) {
      // La copia local ya se ha guardado. Si las reglas remotas aún no están
      // desplegadas, no se debe convertir un ajuste visual en un fallo global.
      debugPrint('No se pudo sincronizar welcomeAnimationEnabled: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

/// Estado en memoria del proceso. Se crea una vez con el [ProviderScope] raíz,
/// por lo que volver a Home o reanudar la app no vuelve a abrir la bienvenida.
final coldStartWelcomeSessionProvider = Provider<ColdStartWelcomeSession>(
  (ref) => ColdStartWelcomeSession(),
);

class ColdStartWelcomeSession {
  bool _pending = true;

  bool take({required bool enabled}) {
    if (!_pending) return false;
    _pending = false;
    return enabled;
  }
}

abstract final class WelcomeGreetingResolver {
  static String resolve(AppLocalizations l10n, String name, int hour) {
    if (hour < 12) return l10n.goodMorning(name);
    if (hour < 20) return l10n.goodAfternoon(name);
    return l10n.goodEvening(name);
  }
}

abstract final class WelcomeMessageSelector {
  static int randomIndex([Random? random]) => (random ?? Random()).nextInt(6);

  static List<String> messages(AppLocalizations l10n) => [
    l10n.welcomeMessage1,
    l10n.welcomeMessage2,
    l10n.welcomeMessage3,
    l10n.welcomeMessage4,
    l10n.welcomeMessage5,
    l10n.welcomeMessage6,
  ];

  static String message(AppLocalizations l10n, int index) {
    final availableMessages = messages(l10n);
    return availableMessages[index % availableMessages.length];
  }
}
