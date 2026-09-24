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
    final editedName = await showDialog<String>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (context) => _EditProfileDialog(initialName: currentName),
    );
    final name = editedName?.trim();
    if (name == null || name.isEmpty || name == currentName) return;
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
    final palette = context.palette;
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
                  onTap: () => context.push('/profile/habits'),
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
                  onTap: () => context.push('/profile/stats'),
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
              decoration: _surfaceDecoration(context, 22),
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
                      color: palette.textSecondary,
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

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );
  late final FocusNode _focusNode = FocusNode();
  late String _name = widget.initialName;

  bool get _canSave {
    final name = _name.trim();
    return name.isNotEmpty && name != widget.initialName;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    if (_canSave) Navigator.pop(context, _name);
  }

  void _clear() {
    _controller.clear();
    setState(() => _name = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      key: const ValueKey('edit-profile-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 54),
                padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
                decoration: BoxDecoration(
                  color: palette.dialogSurface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: palette.shadow,
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.profileEditPersonalTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.profileEditPersonalSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      key: const ValueKey('profile-name-field'),
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) => setState(() => _name = value),
                      onSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        labelText: l10n.profileName,
                        counterText: '${_name.characters.length}/40',
                        prefixIcon: const Icon(PhosphorIconsBold.user),
                        suffixIcon: _name.isEmpty
                            ? null
                            : IconButton(
                                key: const ValueKey('clear-profile-name'),
                                onPressed: _clear,
                                tooltip: l10n.clear,
                                icon: const Icon(PhosphorIconsBold.xCircle),
                              ),
                        filled: true,
                        fillColor: palette.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: palette.primary.withValues(alpha: .18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: palette.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          PhosphorIconsFill.sparkle,
                          color: AppColors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            l10n.profileEditNameHint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: palette.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: _canSave
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.gradientStart,
                                        AppColors.gradientEnd,
                                      ],
                                    )
                                  : null,
                              color: _canSave
                                  ? null
                                  : palette.textSecondary.withValues(
                                      alpha: .18,
                                    ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                            child: FilledButton.icon(
                              key: const ValueKey('save-profile-name'),
                              onPressed: _canSave ? _save : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide.none,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              icon: const Icon(
                                PhosphorIconsBold.check,
                                size: 19,
                              ),
                              label: Text(l10n.profileSave),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: palette.dialogSurface,
                  shape: BoxShape.circle,
                ),
                child: const UserAvatar(size: 104),
              ),
            ],
          ),
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
    final palette = context.palette;
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
                  decoration: BoxDecoration(
                    color: palette.surface,
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
                      color: palette.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.surface, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: palette.shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      PhosphorIconsBold.camera,
                      color: palette.onPrimary,
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
                backgroundColor: palette.surface.withValues(
                  alpha: palette.isDark ? 1 : .75,
                ),
                foregroundColor: palette.primary,
              ),
              icon: const Icon(PhosphorIconsBold.pencilSimple, size: 20),
            ),
          ],
        ),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.textSecondary,
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
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 96,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surface.withValues(alpha: palette.isDark ? 1 : .90),
            palette.isDark
                ? Color.alphaBlend(palette.tint(color, .10), palette.surface)
                : color.withValues(alpha: .10),
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
                  color: palette.tint(color, .16),
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
                style: TextStyle(
                  color: palette.textSecondary,
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
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: _surfaceDecoration(context, 24),
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
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 5,
          ),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: palette.tint(color, .11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: palette.textSecondary),
          ),
          trailing: Icon(
            PhosphorIconsBold.caretRight,
            color: palette.textSecondary,
            size: 18,
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 70, endIndent: 16),
      ],
    );
  }
}

BoxDecoration _surfaceDecoration(BuildContext context, double radius) {
  final palette = context.palette;
  return BoxDecoration(
    color: palette.surface.withValues(alpha: palette.isDark ? 1 : .80),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: palette.border),
  );
}
