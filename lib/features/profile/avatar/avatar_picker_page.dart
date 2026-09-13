import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/features/profile/avatar/avatar.dart';
import 'package:habits/features/profile/avatar/avatar_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class AvatarPickerPage extends ConsumerStatefulWidget {
  const AvatarPickerPage({super.key});

  @override
  ConsumerState<AvatarPickerPage> createState() => _AvatarPickerPageState();
}

class _AvatarPickerPageState extends ConsumerState<AvatarPickerPage> {
  String? _selectedId;
  bool _saving = false;

  String _name(String key) => switch (key) {
    'traveler' => context.l10n.avatarTraveler,
    'friendly' => context.l10n.avatarFriendly,
    'magic' => context.l10n.avatarMagic,
    'gamer' => context.l10n.avatarGamer,
    'zen' => context.l10n.avatarZen,
    'night' => context.l10n.avatarNight,
    'adventurer' => context.l10n.avatarAdventurer,
    'legendary' => context.l10n.avatarLegendary,
    _ => key,
  };

  Future<void> _tap(ProfileAvatar avatar) async {
    if (!avatar.isSelectable) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  PhosphorIconsFill.lock,
                  color: AppColors.primary,
                  size: 38,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.avatarLockedTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  context.l10n.avatarLockedBody,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.understood),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }
    if (_saving || avatar.id == _selectedId) return;
    setState(() {
      _selectedId = avatar.id;
      _saving = true;
    });
    HapticFeedback.selectionClick();
    try {
      await selectAvatar(ref, avatar.id);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storedId =
        ref.watch(selectedAvatarIdProvider).value ?? AvatarCatalog.defaultId;
    _selectedId ??= storedId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          context.l10n.chooseAvatar,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Text(
              context.l10n.chooseAvatarSubtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .78,
              ),
              itemCount: AvatarCatalog.items.length,
              itemBuilder: (context, index) {
                final avatar = AvatarCatalog.items[index];
                return _AvatarCard(
                  avatar: avatar,
                  name: _name(avatar.nameKey),
                  selected: avatar.id == _selectedId,
                  onTap: () => _tap(avatar),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.avatar,
    required this.name,
    required this.selected,
    required this.onTap,
  });
  final ProfileAvatar avatar;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !avatar.isSelectable;
    return Semantics(
      button: true,
      selected: selected,
      label: locked ? '$name, ${context.l10n.avatarLocked}' : name,
      child: AnimatedScale(
        scale: selected ? 1 : .985,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Material(
          color: selected
              ? const Color(0xFFF0EAFF)
              : Colors.white.withValues(alpha: .78),
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.white,
                  width: selected ? 2.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: locked ? .58 : 1,
                          child: CatMascot(
                            size: 118,
                            circular: false,
                            avatarId: avatar.id,
                          ),
                        ),
                        if (locked)
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              PhosphorIconsFill.lock,
                              color: AppColors.primary,
                            ),
                          ),
                        if (selected)
                          const Positioned(
                            right: 2,
                            top: 2,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                PhosphorIconsBold.check,
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selected
                        ? context.l10n.avatarSelected
                        : locked
                        ? context.l10n.avatarComingSoon
                        : context.l10n.avatarAvailable,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
