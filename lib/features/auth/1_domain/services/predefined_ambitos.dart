import 'package:habits/features/auth/0_entity/entity.dart';

/// Ámbitos que la app siembra al crear el perfil (doc funcional §4.4).
/// Los ids coinciden con los que las Security Rules aceptan como
/// predefinidos; `general` es además el destino de reasignación cuando se
/// elimina otro ámbito y no puede borrarse.
abstract final class PredefinedAmbitos {
  static const generalId = 'general';

  static List<PredefinedAmbito> forLocale(String locale) {
    final en = locale.toLowerCase().startsWith('en');
    return [
      PredefinedAmbito(
        id: generalId,
        name: 'General',
        emoji: '✨',
        colorValue: 0xFF7C5CE0,
        order: 0,
      ),
      PredefinedAmbito(
        id: 'salud',
        name: en ? 'Health' : 'Salud',
        emoji: '💜',
        colorValue: 0xFF8B5CF6,
        order: 1,
      ),
      PredefinedAmbito(
        id: 'mente',
        name: en ? 'Mind' : 'Mente',
        emoji: '🧠',
        colorValue: 0xFFF16A8F,
        order: 2,
      ),
      PredefinedAmbito(
        id: 'desarrollo',
        name: en ? 'Growth' : 'Desarrollo',
        emoji: '🌿',
        colorValue: 0xFF34B379,
        order: 3,
      ),
      PredefinedAmbito(
        id: 'energia',
        name: en ? 'Energy' : 'Energía',
        emoji: '🏋️',
        colorValue: 0xFFF59E0B,
        order: 4,
      ),
    ];
  }
}
