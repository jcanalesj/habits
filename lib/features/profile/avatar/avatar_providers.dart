import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/avatar/avatar.dart';

final selectedAvatarIdProvider = StreamProvider<String>((ref) {
  final userId = ref.watch(authControllerProvider).value?.id;
  if (userId == null) return Stream.value(AvatarCatalog.defaultId);
  return ref
      .watch(userProfileRepositoryProvider)
      .watchAvatarId(userId)
      .map((id) => AvatarCatalog.byId(id).id);
});

Future<void> selectAvatar(WidgetRef ref, String avatarId) async {
  final userId =
      ref.read(authControllerProvider).value?.id ??
      ref.read(authRepositoryProvider).currentUser?.id;
  final avatar = AvatarCatalog.byId(avatarId);
  final hasAccess = avatar.isSelectable || ref.read(premiumAccessProvider);
  if (userId == null || !hasAccess) return;
  await ref
      .read(userProfileRepositoryProvider)
      .updateAvatarId(userId, avatar.id);
}
