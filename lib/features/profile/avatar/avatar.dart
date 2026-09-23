enum AvatarStatus { available, selected, locked, owned, purchasable }

class ProfileAvatar {
  const ProfileAvatar({
    required this.id,
    required this.nameKey,
    required this.atlasIndex,
    required this.status,
    this.assetPath,
    this.displayScale = 1,
    this.price,
    this.currency,
  });

  final String id;
  final String nameKey;
  final int? atlasIndex;
  final AvatarStatus status;
  final String? assetPath;
  final double displayScale;
  final num? price;
  final String? currency;

  bool get isSelectable =>
      status == AvatarStatus.available ||
      status == AvatarStatus.selected ||
      status == AvatarStatus.owned;
}

abstract final class AvatarCatalog {
  static const defaultId = 'traveler';

  static const items = [
    ProfileAvatar(
      id: defaultId,
      nameKey: 'traveler',
      atlasIndex: null,
      status: AvatarStatus.available,
      assetPath: 'assets/images/avatars/1.png',
      displayScale: 1.06,
    ),
    ProfileAvatar(
      id: 'friendly',
      nameKey: 'friendly',
      atlasIndex: 0,
      status: AvatarStatus.available,
      assetPath: 'assets/images/avatars/2.png',
      displayScale: 1.06,
    ),
    ProfileAvatar(
      id: 'magic',
      nameKey: 'magic',
      atlasIndex: 1,
      status: AvatarStatus.available,
      assetPath: 'assets/images/avatars/3.png',
      displayScale: 1.08,
    ),
    ProfileAvatar(
      id: 'gamer',
      nameKey: 'gamer',
      atlasIndex: 2,
      status: AvatarStatus.available,
      assetPath: 'assets/images/avatars/4.png',
      displayScale: 1.06,
    ),
    ProfileAvatar(
      id: 'zen',
      nameKey: 'zen',
      atlasIndex: 3,
      status: AvatarStatus.locked,
      assetPath: 'assets/images/avatars/5.png',
      displayScale: 1.06,
    ),
    ProfileAvatar(
      id: 'night',
      nameKey: 'night',
      atlasIndex: 4,
      status: AvatarStatus.locked,
      assetPath: 'assets/images/avatars/6.png',
      displayScale: 1.03,
    ),
    ProfileAvatar(
      id: 'adventurer',
      nameKey: 'adventurer',
      atlasIndex: 5,
      status: AvatarStatus.locked,
      assetPath: 'assets/images/avatars/7.png',
      displayScale: 1.04,
    ),
    ProfileAvatar(
      id: 'legendary',
      nameKey: 'legendary',
      atlasIndex: 6,
      status: AvatarStatus.locked,
      assetPath: 'assets/images/avatars/8.png',
      displayScale: 1.03,
    ),
    ProfileAvatar(
      id: 'hazel',
      nameKey: 'hazel',
      atlasIndex: null,
      status: AvatarStatus.locked,
      assetPath: 'assets/images/avatars/10.png',
    ),
    ProfileAvatar(
      id: 'cookie',
      nameKey: 'cookie',
      atlasIndex: null,
      status: AvatarStatus.locked,
      assetPath: 'assets/images/avatars/9.png',
      displayScale: 1.04,
    ),
  ];

  static ProfileAvatar byId(String? id) =>
      items.firstWhere((avatar) => avatar.id == id, orElse: () => items.first);
}
