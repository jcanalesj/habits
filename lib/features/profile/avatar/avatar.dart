enum AvatarStatus { available, selected, locked, owned, purchasable }

class ProfileAvatar {
  const ProfileAvatar({
    required this.id,
    required this.nameKey,
    required this.atlasIndex,
    required this.status,
    this.price,
    this.currency,
  });

  final String id;
  final String nameKey;
  final int? atlasIndex;
  final AvatarStatus status;
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
    ),
    ProfileAvatar(
      id: 'friendly',
      nameKey: 'friendly',
      atlasIndex: 0,
      status: AvatarStatus.available,
    ),
    ProfileAvatar(
      id: 'magic',
      nameKey: 'magic',
      atlasIndex: 1,
      status: AvatarStatus.locked,
    ),
    ProfileAvatar(
      id: 'gamer',
      nameKey: 'gamer',
      atlasIndex: 2,
      status: AvatarStatus.locked,
    ),
    ProfileAvatar(
      id: 'zen',
      nameKey: 'zen',
      atlasIndex: 3,
      status: AvatarStatus.locked,
    ),
    ProfileAvatar(
      id: 'night',
      nameKey: 'night',
      atlasIndex: 4,
      status: AvatarStatus.locked,
    ),
    ProfileAvatar(
      id: 'adventurer',
      nameKey: 'adventurer',
      atlasIndex: 5,
      status: AvatarStatus.locked,
    ),
    ProfileAvatar(
      id: 'legendary',
      nameKey: 'legendary',
      atlasIndex: 6,
      status: AvatarStatus.locked,
    ),
  ];

  static ProfileAvatar byId(String? id) =>
      items.firstWhere((avatar) => avatar.id == id, orElse: () => items.first);
}
