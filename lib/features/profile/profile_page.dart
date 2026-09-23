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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ProfileMetric(
                    icon: PhosphorIconsFill.fire,
                    color: AppColors.orange,
                    value: '${summary?.streak.displayStreak ?? 0}',
                    label: l10n.profileCurrentStreak,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _ProfileMetric(
                    icon: PhosphorIconsFill.checkCircle,
                    color: AppColors.green,
                    value: '${summary?.habits.length ?? 0}',
                    label: l10n.profileActiveHabits,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _ProfileMetric(
                    icon: PhosphorIconsFill.shieldCheck,
                    color: AppColors.lilac,
                    value: '${summary?.wildcards.available ?? 0}',
                    label: l10n.profileProtectors,
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
                  title: l10n.profileWeightTitle,
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
                  onTap: () => context.go('/habits/manage'),
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
    return Column(
      children: [
        Text(
          l10n.navProfile,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        Semantics(
          button: true,
          label: l10n.chooseAvatar,
          child: GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const UserAvatar(size: 132),
                ),
                Positioned(
                  right: -2,
                  bottom: 5,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x337C5CE0),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      PhosphorIconsBold.camera,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: onAvatarTap,
          child: Text(
            l10n.profileChangePhoto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const ValueKey('profile-edit-name'),
              onPressed: onEdit,
              tooltip: l10n.profileEdit,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .75),
                foregroundColor: AppColors.primary,
              ),
              icon: const Icon(PhosphorIconsBold.pencilSimple, size: 20),
            ),
          ],
        ),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 96,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: .90),
          color.withValues(alpha: .10),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: .16)),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: .07),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
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
