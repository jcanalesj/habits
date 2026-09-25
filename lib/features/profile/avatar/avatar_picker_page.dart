import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/avatar/avatar.dart';
import 'package:habits/features/profile/avatar/avatar_providers.dart';
import 'package:habits/features/profile/premium/premium_gate.dart';
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
    'hazel' => context.l10n.avatarHazel,
    'cookie' => context.l10n.avatarCookie,
    _ => key,
  };

  Future<void> _tap(ProfileAvatar avatar) async {
    if (!avatar.isSelectable) {
      final allowed = await requestPremiumAccess(
        context,
        ref,
        dialogBuilder: (context) {
          final palette = context.palette;
          return Dialog(
            key: const ValueKey('premium-avatar-dialog'),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: palette.dialogSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CatMascot(size: 126, avatarId: avatar.id),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: palette.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: palette.dialogSurface,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          PhosphorIconsFill.lock,
                          color: palette.onPrimary,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.avatarPremiumTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.avatarPremiumBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.primarySoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIconsFill.sparkle, color: palette.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.avatarPremiumBenefitTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                context.l10n.avatarPremiumBenefitBody,
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(context.l10n.premiumNotNow),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          key: const ValueKey('avatar-view-premium-plans'),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            context.l10n.premiumViewPlans,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (!allowed || !mounted) return;
    }
    if (_saving || avatar.id == _selectedId) return;
    final previousId = _selectedId;
    setState(() {
      _selectedId = avatar.id;
      _saving = true;
    });
    HapticFeedback.selectionClick();
    try {
      await selectAvatar(ref, avatar.id);
    } catch (_) {
      if (mounted) {
        setState(() => _selectedId = previousId);
        AppNotice.show(
          context,
          message: context.l10n.errorSaveFailed,
          type: AppNoticeType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storedId =
        ref.watch(selectedAvatarIdProvider).value ?? AvatarCatalog.defaultId;
    _selectedId ??= storedId;
    final hasPremium = ref.watch(premiumAccessProvider);
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
              style: TextStyle(
                color: context.palette.textSecondary,
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
                  locked: !avatar.isSelectable && !hasPremium,
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
    required this.locked,
    required this.onTap,
  });
  final ProfileAvatar avatar;
  final String name;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
              ? palette.primarySoft
              : palette.surface.withValues(alpha: palette.isDark ? 1 : .78),
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
                  color: selected ? palette.primary : palette.border,
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
                            circular: true,
                            avatarId: avatar.id,
                          ),
                        ),
                        if (locked)
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: palette.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              PhosphorIconsFill.lock,
                              color: palette.primary,
                            ),
                          ),
                        if (selected)
                          Positioned(
                            right: 2,
                            top: 2,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: palette.primary,
                              child: Icon(
                                PhosphorIconsBold.check,
                                color: palette.onPrimary,
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
                        ? context.l10n.avatarPremium
                        : context.l10n.avatarAvailable,
                    style: TextStyle(
                      color: selected ? palette.primary : palette.textSecondary,
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
