import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda, por usuario y dispositivo, si ya se ha visto el tutorial de
/// primer uso. Igual que la invitación de peso: una copia local basta, no
/// merece la pena sincronizarlo con el perfil remoto.
abstract interface class OnboardingTourPreferences {
  bool isSeen(String userId);
  Future<void> markSeen(String userId);
}

class SharedOnboardingTourPreferences implements OnboardingTourPreferences {
  SharedOnboardingTourPreferences(this._preferences);

  final SharedPreferences _preferences;

  static String key(String userId) => 'onboarding_tour_seen_$userId';

  @override
  bool isSeen(String userId) => _preferences.getBool(key(userId)) ?? false;

  @override
  Future<void> markSeen(String userId) =>
      _preferences.setBool(key(userId), true);
}

class MemoryOnboardingTourPreferences implements OnboardingTourPreferences {
  MemoryOnboardingTourPreferences({this.seenByDefault = false});

  /// Con `true` el tutorial se da por visto para todos los usuarios. Es el
  /// valor cuando no hay persistencia (tests, plugin ausente): sin memoria
  /// entre arranques se repetiría en cada inicio.
  final bool seenByDefault;
  final Set<String> _seen = {};

  @override
  bool isSeen(String userId) => seenByDefault || _seen.contains(userId);

  @override
  Future<void> markSeen(String userId) async => _seen.add(userId);
}

/// Se sobrescribe en `main` con la copia en SharedPreferences. Por defecto
/// no se muestra el tutorial: así ninguna pantalla bajo prueba lo abre sin
/// pedirlo.
final onboardingTourPreferencesProvider = Provider<OnboardingTourPreferences>(
  (ref) => MemoryOnboardingTourPreferences(seenByDefault: true),
);

/// Estado en memoria del proceso: el tutorial se ofrece como mucho una vez
/// por arranque, aunque la Home se reconstruya desde cero.
final onboardingTourSessionProvider = Provider<OnboardingTourSession>(
  (ref) => OnboardingTourSession(),
);

class OnboardingTourSession {
  bool _pending = true;

  bool take() {
    if (!_pending) return false;
    _pending = false;
    return true;
  }
}
