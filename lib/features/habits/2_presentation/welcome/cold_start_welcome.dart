import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/localization/gen/app_localizations.dart';

/// Configuración preparada para conectarse más adelante a Ajustes.
final welcomeAnimationEnabledProvider = Provider<bool>((ref) => true);

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

  static String message(AppLocalizations l10n, int index) {
    final messages = [
      l10n.welcomeMessage1,
      l10n.welcomeMessage2,
      l10n.welcomeMessage3,
      l10n.welcomeMessage4,
      l10n.welcomeMessage5,
      l10n.welcomeMessage6,
    ];
    return messages[index % messages.length];
  }
}
