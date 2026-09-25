import 'package:habits/localization/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habits/theme/app_theme.dart';

enum HabitIconCategory { wellbeing, health, learning, activity, general }

@immutable
class HabitIconDefinition {
  const HabitIconDefinition({
    required this.id,
    required this.assetPath,
    required this.label,
    required this.category,
    required this.legacyEmoji,
  });
  final String id, assetPath, label, legacyEmoji;
  final HabitIconCategory category;
}

abstract final class HabitIconCatalog {
  static const fallbackId = 'check';
  static const availableIcons = <HabitIconDefinition>[
    HabitIconDefinition(
      id: 'water_drop',
      assetPath: 'assets/icons/habits/water_drop.svg',
      label: 'Agua',
      category: HabitIconCategory.health,
      legacyEmoji: '💧',
    ),
    HabitIconDefinition(
      id: 'running',
      assetPath: 'assets/icons/habits/running.svg',
      label: 'Ejercicio',
      category: HabitIconCategory.activity,
      legacyEmoji: '🏃',
    ),
    HabitIconDefinition(
      id: 'dumbbell',
      assetPath: 'assets/icons/habits/dumbbell.svg',
      label: 'Fuerza',
      category: HabitIconCategory.activity,
      legacyEmoji: '🏋️',
    ),
    HabitIconDefinition(
      id: 'meditation',
      assetPath: 'assets/icons/habits/meditation.svg',
      label: 'Meditación',
      category: HabitIconCategory.wellbeing,
      legacyEmoji: '🧘',
    ),
    HabitIconDefinition(
      id: 'sleep',
      assetPath: 'assets/icons/habits/sleep.svg',
      label: 'Descanso',
      category: HabitIconCategory.wellbeing,
      legacyEmoji: '😴',
    ),
    HabitIconDefinition(
      id: 'book',
      assetPath: 'assets/icons/habits/book.svg',
      label: 'Lectura',
      category: HabitIconCategory.learning,
      legacyEmoji: '📖',
    ),
    HabitIconDefinition(
      id: 'heart',
      assetPath: 'assets/icons/habits/heart.svg',
      label: 'Bienestar',
      category: HabitIconCategory.wellbeing,
      legacyEmoji: '💜',
    ),
    HabitIconDefinition(
      id: 'star',
      assetPath: 'assets/icons/habits/star.svg',
      label: 'Meta',
      category: HabitIconCategory.general,
      legacyEmoji: '✨',
    ),
    HabitIconDefinition(
      id: 'fruit',
      assetPath: 'assets/icons/habits/apple.svg',
      label: 'Alimentación',
      category: HabitIconCategory.health,
      legacyEmoji: '🥗',
    ),
    HabitIconDefinition(
      id: 'pill',
      assetPath: 'assets/icons/habits/pill.svg',
      label: 'Medicación',
      category: HabitIconCategory.health,
      legacyEmoji: '💊',
    ),
    HabitIconDefinition(
      id: 'paw',
      assetPath: 'assets/icons/habits/paw.svg',
      label: 'Mascota',
      category: HabitIconCategory.general,
      legacyEmoji: '🐾',
    ),
    HabitIconDefinition(
      id: 'cup',
      assetPath: 'assets/icons/habits/cup.svg',
      label: 'Bebida',
      category: HabitIconCategory.health,
      legacyEmoji: '☕',
    ),
    HabitIconDefinition(
      id: fallbackId,
      assetPath: 'assets/icons/habits/check.svg',
      label: 'General',
      category: HabitIconCategory.general,
      legacyEmoji: '✓',
    ),
  ];

  static HabitIconDefinition getById(String? id) => availableIcons.firstWhere(
    (icon) => icon.id == id,
    orElse: () => availableIcons.last,
  );
  static String getAsset(String? id) => getById(id).assetPath;
  static bool contains(String? id) =>
      availableIcons.any((icon) => icon.id == id);
  static String? idForLegacyEmoji(String emoji) {
    for (final icon in availableIcons) {
      if (icon.legacyEmoji == emoji) return icon.id;
    }
    return null;
  }
}

class HabitIcon extends StatelessWidget {
  const HabitIcon({super.key, this.iconId, this.legacyEmoji, this.size = 30});
  final String? iconId, legacyEmoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (iconId == null && (legacyEmoji?.isNotEmpty ?? false)) {
      return Text(legacyEmoji!, style: TextStyle(fontSize: size * .78));
    }
    final definition = HabitIconCatalog.getById(iconId);
    return Semantics(
      image: true,
      label: definition.localizedLabel(context.l10n),
      child: SvgPicture.asset(
        definition.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Icon(
          Icons.check_circle_outline_rounded,
          size: size,
          color: context.palette.primary,
        ),
      ),
    );
  }
}

class HabitIconPicker extends StatelessWidget {
  const HabitIconPicker({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final icon in HabitIconCatalog.availableIcons)
          Semantics(
            button: true,
            selected: selectedId == icon.id,
            label: icon.label,
            child: InkWell(
              key: ValueKey('habit-icon-${icon.id}'),
              onTap: () => onSelected(icon.id),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedId == icon.id
                      ? palette.primarySoft
                      : palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: selectedId == icon.id
                      ? Border.all(color: palette.primary, width: 2)
                      : null,
                ),
                child: HabitIcon(iconId: icon.id),
              ),
            ),
          ),
      ],
    );
  }
}

/// Nombre accesible del icono en el idioma del usuario. La etiqueta del
/// catálogo es solo la de respaldo en español.
extension HabitIconDefinitionL10n on HabitIconDefinition {
  String localizedLabel(AppLocalizations l10n) => switch (id) {
    'water_drop' => l10n.iconWater,
    'running' => l10n.iconExercise,
    'dumbbell' => l10n.iconStrength,
    'meditation' => l10n.iconMeditation,
    'sleep' => l10n.iconRest,
    'book' => l10n.iconReading,
    'heart' => l10n.iconWellbeing,
    'star' => l10n.iconGoal,
    'fruit' => l10n.iconFood,
    'pill' => l10n.iconMedication,
    'paw' => l10n.iconPet,
    'cup' => l10n.iconDrink,
    'check' => l10n.iconGeneral,
    _ => label,
  };
}
