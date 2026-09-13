import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          l10n.profileAppearance,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
        children: [
          _AppearanceHero(),
          const SizedBox(height: 24),
          _SectionTitle(l10n.appearancePreview),
          const SizedBox(height: 10),
          const _PreviewCard(),
          const SizedBox(height: 26),
          _SectionTitle(l10n.appearanceExperience),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingRow(
                icon: PhosphorIconsBold.sparkle,
                color: AppColors.primary,
                title: l10n.profileWelcomeAnimation,
                subtitle: l10n.profileWelcomeAnimationHint,
                trailing: Switch.adaptive(
                  value: ref.watch(welcomeAnimationEnabledProvider),
                  onChanged: ref
                      .read(welcomeAnimationEnabledProvider.notifier)
                      .setEnabled,
                ),
              ),
              const Divider(height: 1, indent: 72),
              _SettingRow(
                icon: PhosphorIconsBold.waveSine,
                color: AppColors.blue,
                title: l10n.appearanceReducedMotion,
                subtitle: l10n.appearanceReducedMotionHint,
                trailing: _StatusPill(
                  label: reduceMotion
                      ? l10n.appearanceActive
                      : l10n.appearanceInactive,
                  active: reduceMotion,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SectionTitle(l10n.appearanceTheme),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SettingRow(
                icon: PhosphorIconsFill.sun,
                color: AppColors.orange,
                title: l10n.appearanceLightTheme,
                subtitle: l10n.appearanceLightThemeHint,
                trailing: const Icon(
                  PhosphorIconsFill.checkCircle,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),
              const Divider(height: 1, indent: 72),
              _SettingRow(
                icon: PhosphorIconsBold.moon,
                color: AppColors.lilac,
                title: l10n.appearanceDarkTheme,
                subtitle: l10n.appearanceComingSoon,
                muted: true,
                trailing: _SoonPill(label: l10n.appearanceSoon),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _SectionTitle(l10n.appearanceAppIcon),
          const SizedBox(height: 5),
          Text(
            l10n.appearanceAppIconHint,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _AppIconChoices(),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(PhosphorIconsBold.info, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.appearanceSystemHint,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFEDE5FF), Color(0xFFFFF0FA)],
      ),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white),
    ),
    child: Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const UserAvatar(size: 84),
            Positioned(
              right: -3,
              bottom: -3,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIconsFill.palette,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.appearanceHeroTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.appearanceHeroBody,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(26),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/cards/card1.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: .30),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Constanza',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 21,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pequeñas acciones, grandes cambios.',
                      style: TextStyle(color: Colors.white, height: 1.3),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              UserAvatar(size: 62),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AppIconChoices extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _IconChoice(
          label: context.l10n.appearanceClassic,
          selected: true,
          child: const UserAvatar(size: 58, circular: false),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _IconChoice(
          label: context.l10n.appearanceSoon,
          child: const Icon(
            PhosphorIconsBold.moonStars,
            color: AppColors.lilac,
            size: 34,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _IconChoice(
          label: context.l10n.appearanceSoon,
          child: const Icon(
            PhosphorIconsBold.sparkle,
            color: AppColors.pink,
            size: 34,
          ),
        ),
      ),
    ],
  );
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.label,
    required this.child,
    this.selected = false,
  });

  final String label;
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: selected ? .95 : .65),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: selected ? AppColors.primary : Colors.white,
        width: selected ? 2 : 1,
      ),
    ),
    child: Column(
      children: [
        SizedBox.square(dimension: 58, child: Center(child: child)),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .84),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white),
    ),
    child: Column(children: children),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.muted = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool muted;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: muted ? .62 : 1,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: (active ? AppColors.green : AppColors.textSecondary).withValues(
        alpha: .10,
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: active ? AppColors.green : AppColors.textSecondary,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );
}

class _SoonPill extends StatelessWidget {
  const _SoonPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF0EAFF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
  );
}
