import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/profile/avatar/avatar.dart';
import 'package:habits/features/profile/avatar/avatar_providers.dart';
import 'package:habits/theme/app_theme.dart';

class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key, required this.size, this.circular = true});

  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context, WidgetRef ref) => CatMascot(
    size: size,
    circular: circular,
    avatarId:
        ref.watch(selectedAvatarIdProvider).value ?? AvatarCatalog.defaultId,
  );
}

/// Recorte reutilizable del gato de la identidad visual de la app.
class CatMascot extends StatelessWidget {
  static const _assetFillScale = 1.08;

  const CatMascot({
    super.key,
    required this.size,
    this.circular = true,
    this.avatarId = AvatarCatalog.defaultId,
  });

  final double size;
  final bool circular;
  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.palette.primarySoft,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size * .25),
      ),
      child: _image(),
    );
  }

  Widget _image() {
    final avatar = AvatarCatalog.byId(avatarId);
    if (avatar.assetPath case final assetPath?) {
      // Cada exportación deja un margen diferente. La escala definida en el
      // catálogo corrige las diferencias entre avatares y este factor común
      // elimina el margen transparente de los PNG para llenar el recorte.
      return Transform.scale(
        scale: avatar.displayScale * _assetFillScale,
        child: Center(
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
      );
    }
    if (avatar.atlasIndex case final index?) {
      final column = index % 4;
      final row = index ~/ 4;
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: -column * size,
            top: -row * size,
            width: size * 4,
            height: size * 2,
            child: Image.asset(
              'assets/images/cat-avatar-atlas.png',
              fit: BoxFit.fill,
            ),
          ),
        ],
      );
    }
    return Transform.scale(
      scale: 2.15,
      alignment: const Alignment(.62, .48),
      child: Image.asset(
        'assets/images/cards/9:00-12:00.png',
        fit: BoxFit.cover,
        alignment: const Alignment(.72, .46),
      ),
    );
  }
}
