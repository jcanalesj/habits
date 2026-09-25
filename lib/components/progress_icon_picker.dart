import 'package:habits/localization/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habits/theme/app_theme.dart';

@immutable
class ProgressIconDefinition {
  const ProgressIconDefinition({
    required this.id,
    required this.emptyAssetPath,
    required this.filledAssetPath,
    required this.label,
  });
  final String id, emptyAssetPath, filledAssetPath, label;
}

abstract final class ProgressIconCatalog {
  static const fallbackId = 'water_drop';
  static const individualIconLimit = 8;
  static const options = <ProgressIconDefinition>[
    ProgressIconDefinition(
      id: 'water_drop',
      emptyAssetPath: 'assets/icons/progress/constanza_water_drop_empty.svg',
      filledAssetPath: 'assets/icons/progress/constanza_water_drop_thin.svg',
      label: 'Gota de agua',
    ),
    ProgressIconDefinition(
      id: 'star',
      emptyAssetPath: 'assets/icons/progress/constanza_star_empty.svg',
      filledAssetPath: 'assets/icons/progress/constanza_star.svg',
      label: 'Estrella',
    ),
    ProgressIconDefinition(
      id: 'fruit',
      emptyAssetPath: 'assets/icons/progress/constanza_fruit_apple_empty.svg',
      filledAssetPath: 'assets/icons/progress/constanza_fruit_apple.svg',
      label: 'Fruta',
    ),
    ProgressIconDefinition(
      id: 'pill',
      emptyAssetPath: 'assets/icons/progress/constanza_pill_empty.svg',
      filledAssetPath: 'assets/icons/progress/constanza_pill.svg',
      label: 'Pastilla',
    ),
    ProgressIconDefinition(
      id: 'paw',
      emptyAssetPath: 'assets/icons/progress/constanza_dog_paw_empty_v2.svg',
      filledAssetPath: 'assets/icons/progress/constanza_dog_paw_v2.svg',
      label: 'Huella',
    ),
    ProgressIconDefinition(
      id: 'brush',
      emptyAssetPath: 'assets/icons/progress/constanza_cepillo_gris_vacio.png',
      filledAssetPath: 'assets/icons/progress/constanza_brush.png',
      label: 'Cepillo',
    ),
  ];

  static ProgressIconDefinition getById(String? id) => options.firstWhere(
    (item) => item.id == id,
    orElse: () => options.firstWhere((item) => item.id == fallbackId),
  );
  static ProgressIconDefinition byId(String? id) => getById(id);
  static bool contains(String? id) => options.any((item) => item.id == id);
}

class HabitProgressIcon extends StatelessWidget {
  const HabitProgressIcon({
    super.key,
    required this.iconId,
    required this.completed,
    this.size = 24,
  });
  final String iconId;
  final bool completed;
  final double size;
  @override
  Widget build(BuildContext context) {
    final icon = ProgressIconCatalog.getById(iconId);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final assetPath = completed ? icon.filledAssetPath : icon.emptyAssetPath;
    final image = assetPath.endsWith('.svg')
        ? SvgPicture.asset(
            assetPath,
            key: ValueKey(assetPath),
            width: size,
            height: size,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => SizedBox.square(dimension: size),
          )
        : Image.asset(
            assetPath,
            key: ValueKey(assetPath),
            width: size,
            height: size,
            fit: BoxFit.contain,
          );
    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 280),
      reverseDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .72, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: image,
    );
  }
}

class ProgressIconPicker extends StatelessWidget {
  const ProgressIconPicker({
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
        for (final option in ProgressIconCatalog.options)
          Semantics(
            button: true,
            selected: selectedId == option.id,
            label: option.localizedLabel(context.l10n),
            child: InkWell(
              key: ValueKey('progress-icon-${option.id}'),
              onTap: () => onSelected(option.id),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedId == option.id
                      ? palette.primarySoft
                      : palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: selectedId == option.id
                      ? Border.all(color: palette.primary, width: 2)
                      : null,
                ),
                child: HabitProgressIcon(
                  iconId: option.id,
                  completed: selectedId == option.id,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Nombre accesible del icono de progreso en el idioma del usuario.
extension ProgressIconDefinitionL10n on ProgressIconDefinition {
  String localizedLabel(AppLocalizations l10n) => switch (id) {
    'water_drop' => l10n.progressIconWaterDrop,
    'star' => l10n.progressIconStar,
    'fruit' => l10n.progressIconFruit,
    'pill' => l10n.progressIconPill,
    'paw' => l10n.progressIconPaw,
    'brush' => l10n.progressIconBrush,
    _ => label,
  };
}
