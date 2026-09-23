import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/app_bottom_nav_bar.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/widgets/sign_out_button.dart';
import 'package:habits/features/habits/2_presentation/controllers/home_controller.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    var editedName = currentName;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.profileEdit),
        content: TextFormField(
          initialValue: currentName,
          onChanged: (value) => editedName = value,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: context.l10n.profileName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.profileSave),
          ),
        ],
      ),
    );
    final name = editedName.trim();
    if (saved != true || name.isEmpty || name == currentName) return;
    await ref.read(authControllerProvider.notifier).updateDisplayName(name);
    if (context.mounted) _showSaved(context);
  }

  void _showSaved(BuildContext context) {
    AppNotice.show(
      context,
      message: context.l10n.profileChangesSaved,
      type: AppNoticeType.success,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final summary = ref.watch(homeControllerProvider).value;
    final timezone = ref.watch(profileTimezoneProvider).value ?? 'UTC';
    final name = ref.watch(userNameProvider);
    final l10n = context.l10n;
    final bottomClearance =
        AppBottomNavBar.contentClearance +
        MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 18, 20, bottomClearance),
          children: [
            _ProfileHero(
              name: name,
              email: user?.email ?? '',
              onEdit: () => _editProfile(context, ref, name),
              onAvatarTap: () => context.push('/profile/avatar'),
            ),
            const SizedBox(height: 24),
            _SectionLabel(l10n.profileYourProgress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ProfileMetric(
                    icon: PhosphorIconsFill.fire,
                    color: AppColors.orange,
                    value: '${summary?.streak.displayStreak ?? 0}',
                    label: l10n.profileCurrentStreak,
                    encouragement: l10n.profileStreakEncouragement,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _ProfileMetric(
                    icon: PhosphorIconsFill.checkCircle,
                    color: AppColors.green,
                    value: '${summary?.habits.length ?? 0}',
                    label: l10n.profileActiveHabits,
                    encouragement: l10n.profileHabitsEncouragement,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _ProfileMetric(
                    icon: PhosphorIconsFill.shieldCheck,
                    color: AppColors.lilac,
                    value: '${summary?.wildcards.available ?? 0}',
                    label: l10n.profileProtectors,
                    encouragement: l10n.profileProtectorEncouragement(
                      summary?.wildcards.available ?? 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionLabel(l10n.profileHealth),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _ProfileLink(
                  icon: PhosphorIconsBold.scales,
                  color: AppColors.blue,
                  title: l10n.weightTitle,
                  subtitle: l10n.profileWeightSubtitle,
                  onTap: () => context.push('/profile/weight'),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionLabel(l10n.profileManage),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _ProfileLink(
                  icon: PhosphorIconsBold.checkSquare,
                  color: AppColors.blue,
                  title: l10n.myHabits,
                  subtitle: l10n.profileMyHabitsSubtitle,
                  onTap: () => context.go('/habits'),
                ),
                _ProfileLink(
                  icon: PhosphorIconsBold.calendarDots,
                  color: AppColors.lilac,
                  title: l10n.habitCalendarsAction,
                  subtitle: l10n.profileCalendarsSubtitle,
                  onTap: () => context.push('/habit-calendars'),
                ),
                _ProfileLink(
                  icon: PhosphorIconsBold.chartBar,
                  color: AppColors.green,
                  title: l10n.navStats,
                  subtitle: l10n.profileStatsSubtitle,
                  onTap: () => context.go('/stats'),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionLabel(l10n.profilePreferences),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _ProfileLink(
                  icon: PhosphorIconsBold.clock,
                  color: AppColors.lilac,
                  title: l10n.profileTimezone,
                  subtitle: '${l10n.profileTimezoneSubtitle} · $timezone',
                  onTap: () => context.push('/profile/timezone'),
                ),
                _ProfileLink(
                  icon: PhosphorIconsBold.bell,
                  color: AppColors.pink,
                  title: l10n.profileNotifications,
                  subtitle: l10n.profileNotificationsSubtitle,
                  onTap: () => context.push('/profile/notifications'),
                ),
                _ProfileLink(
                  icon: PhosphorIconsBold.palette,
                  color: AppColors.lilac,
                  title: l10n.profileAppearance,
                  subtitle: l10n.profileAppearanceSubtitle,
                  onTap: () => context.push('/profile/appearance'),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 26),
            _SectionLabel(l10n.profileAccount),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _surfaceDecoration(22),
              child: Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: SignOutButton(),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    l10n.profileSignOutHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.onEdit,
    required this.onAvatarTap,
  });

  final String name;
  final String email;
  final VoidCallback onEdit;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: 204,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // El PNG conserva transparencia en sus esquinas redondeadas. Este
        // fondo evita que en el contorno asome el blanco del Scaffold.
        color: const Color(0xFF9E83EC),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/cards/21:00-23:00.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            color: Colors.white.withValues(alpha: .22),
            colorBlendMode: BlendMode.srcOver,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xAAF0EAFF),
                  Color(0x55F0EAFF),
                  Color(0x0FFFFFFF),
                ],
                stops: [0, .55, 1],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 82,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00EEE9FF), Color(0xA8EEE9FF)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      button: true,
                      label: l10n.chooseAvatar,
                      child: GestureDetector(
                        onTap: onAvatarTap,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const UserAvatar(size: 72),
                            ),
                            Positioned(
                              right: -3,
                              bottom: -3,
                              child: Container(
                                width: 29,
                                height: 29,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  PhosphorIconsFill.sparkle,
                                  size: 17,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppDimensions.screenTitleFontSize,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF514B70),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 3),
                    TextButton.icon(
                      onPressed: onEdit,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: .82),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        minimumSize: const Size(0, 38),
                      ),
                      icon: const Icon(
                        PhosphorIconsFill.pencilSimple,
                        size: 16,
                      ),
                      label: Text(
                        l10n.profileEdit,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '“${l10n.tagline}” 💜',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(color: Color(0xCCFFFFFF), blurRadius: 8)],
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      fontSize: 20,
    ),
  );
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.encouragement,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String encouragement;

  @override
  Widget build(BuildContext context) => Container(
    height: 152,
    padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .055),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withValues(alpha: .85)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            encouragement,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color.withValues(alpha: .95),
              fontSize: 9,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: _surfaceDecoration(24),
    child: Column(children: children),
  );
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          PhosphorIconsBold.caretRight,
          color: AppColors.textSecondary,
          size: 18,
        ),
      ),
      if (showDivider) const Divider(height: 1, indent: 70, endIndent: 16),
    ],
  );
}

BoxDecoration _surfaceDecoration(double radius) => BoxDecoration(
  color: Colors.white.withValues(alpha: .80),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: Colors.white.withValues(alpha: .88)),
);
