import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/appearance/app_icon.dart';
import 'package:habits/features/profile/appearance/theme_mode_preferences.dart';
import 'package:habits/features/profile/premium/premium_gate.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  static const freeMessageLimit = 1;

  Future<void> _selectTheme(
    BuildContext context,
    WidgetRef ref, {
    required ThemeMode mode,
  }) async {
    if (mode == ThemeMode.dark) {
      final allowed = await requestPremiumAccess(
        context,
        ref,
        dialogBuilder: (_) => const _PremiumDarkThemeDialog(),
      );
      if (!allowed) return;
    }
    ref.read(themeModeProvider.notifier).setMode(mode);
  }

  Future<void> _selectAppIcon(
    BuildContext context,
    WidgetRef ref,
    AppIconOption icon,
  ) async {
    if (icon == ref.read(appIconProvider).value) return;
    if (icon.isPremium) {
      final allowed = await requestPremiumAccess(
        context,
        ref,
        dialogBuilder: (_) => const _PremiumAppIconDialog(),
      );
      if (!allowed || !context.mounted) return;
    }
    final l10n = context.l10n;
    try {
      await ref.read(appIconProvider.notifier).select(icon);
      if (!context.mounted) return;
      AppNotice.show(
        context,
        message: l10n.appIconChanged,
        type: AppNoticeType.success,
      );
    } catch (error) {
      debugPrint('No se pudo cambiar el icono: $error');
      if (!context.mounted) return;
      AppNotice.show(
        context,
        message: l10n.appIconChangeFailed,
        type: AppNoticeType.error,
      );
    }
  }

  Future<void> _editMessage(
    BuildContext context,
    WidgetRef ref, {
    int? index,
    String initialValue = '',
  }) async {
    final message = await showDialog<String>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (context) => _MotivationMessageDialog(
        initialValue: initialValue,
        editing: index != null,
      ),
    );
    if (message == null || message.isEmpty) return;
    final notifier = ref.read(customMotivationMessagesProvider.notifier);
    index == null ? notifier.add(message) : notifier.update(index, message);
  }

  Future<void> _addMessage(
    BuildContext context,
    WidgetRef ref, {
    required int messageCount,
  }) async {
    if (messageCount >= freeMessageLimit) {
      final allowed = await requestPremiumAccess(
        context,
        ref,
        dialogBuilder: (_) => const _PremiumMessageLimitDialog(),
      );
      if (!allowed) return;
    }
    if (context.mounted) await _editMessage(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.palette;
    final messages = ref.watch(customMotivationMessagesProvider);
    final isPremium = ref.watch(premiumSubscribedProvider);
    final themeMode = ref.watch(themeModeProvider);
    void addMessage() =>
        _addMessage(context, ref, messageCount: messages.length);
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
          _MotivationPreview(
            message: messages.isEmpty
                ? l10n.personalizationDefaultPreview
                : messages.first,
          ),
          const SizedBox(height: 26),
          _SectionTitle(l10n.personalizationYourMessages),
          const SizedBox(height: 4),
          Text(
            l10n.personalizationYourMessagesHint,
            style: TextStyle(color: palette.textSecondary),
          ),
          const SizedBox(height: 12),
          if (messages.isEmpty)
            _EmptyMessages(onAdd: addMessage)
          else ...[
            for (var index = 0; index < messages.length; index++) ...[
              _MessageTile(
                message: messages[index],
                onEdit: () => _editMessage(
                  context,
                  ref,
                  index: index,
                  initialValue: messages[index],
                ),
                onDelete: () => ref
                    .read(customMotivationMessagesProvider.notifier)
                    .remove(index),
              ),
              if (index != messages.length - 1) const SizedBox(height: 9),
            ],
            const SizedBox(height: 12),
            _AddButton(onPressed: addMessage),
          ],
          const SizedBox(height: 28),
          _SectionTitle(l10n.personalizationAppearance),
          const SizedBox(height: 10),
          _Card(
            children: [
              _SettingRow(
                icon: PhosphorIconsBold.sparkle,
                color: palette.primary,
                title: l10n.profileWelcomeAnimation,
                subtitle: l10n.profileWelcomeAnimationHint,
                trailing: Switch.adaptive(
                  key: const ValueKey('welcome-animation-switch'),
                  value: ref.watch(welcomeAnimationEnabledProvider),
                  onChanged: ref
                      .read(welcomeAnimationEnabledProvider.notifier)
                      .setEnabled,
                ),
              ),
              const Divider(height: 1, indent: 72),
              _SettingRow(
                icon: themeMode == ThemeMode.dark
                    ? PhosphorIconsBold.moon
                    : PhosphorIconsBold.sun,
                color: AppColors.lilac,
                title: l10n.appearanceTheme,
                subtitle: l10n.appearanceThemeHint,
                trailing: const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: _ThemeModeSelector(
                  value: themeMode,
                  isPremium: isPremium,
                  onChanged: (mode) => _selectTheme(context, ref, mode: mode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionTitle(l10n.appearanceAppIcon),
          const SizedBox(height: 4),
          Text(
            l10n.appearanceAppIconHint,
            style: TextStyle(color: palette.textSecondary),
          ),
          const SizedBox(height: 12),
          _Card(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: _AppIconSelector(
                  value:
                      ref.watch(appIconProvider).value ?? AppIconOption.classic,
                  onChanged: (icon) => _selectAppIcon(context, ref, icon),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumMessageLimitDialog extends StatelessWidget {
  const _PremiumMessageLimitDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      key: const ValueKey('premium-message-limit-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: palette.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/premium.png',
                width: 150,
                height: 112,
                fit: BoxFit.contain,
                semanticLabel: l10n.premiumCatImageLabel,
              ),
              Text(
                l10n.premiumMessageLimitTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.premiumMessageLimitBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.premiumNotNow),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: FilledButton(
                        key: const ValueKey('message-view-premium-plans'),
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          l10n.premiumViewPlans,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotivationMessageDialog extends StatefulWidget {
  const _MotivationMessageDialog({
    required this.initialValue,
    required this.editing,
  });

  final String initialValue;
  final bool editing;

  @override
  State<_MotivationMessageDialog> createState() =>
      _MotivationMessageDialogState();
}

class _MotivationMessageDialogState extends State<_MotivationMessageDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  late String _message = widget.initialValue;

  bool get _canSave => _message.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      key: const ValueKey('motivation-message-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: palette.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: palette.isDark
                        ? [palette.primarySoft, palette.tint(AppColors.pink)]
                        : const [Color(0xFFE7DCFF), Color(0xFFFFE9F5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  PhosphorIconsFill.quotes,
                  color: palette.primary,
                  size: 31,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.editing
                    ? l10n.personalizationEditMessage
                    : l10n.personalizationAddMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.personalizationMessageHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textSecondary),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const ValueKey('motivation-message-field'),
                controller: _controller,
                autofocus: true,
                maxLength: 100,
                minLines: 3,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) => setState(() => _message = value),
                decoration: InputDecoration(
                  hintText: l10n.personalizationDefaultPreview,
                  counterText: '${_message.characters.length}/100',
                  filled: true,
                  fillColor: palette.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: palette.primary.withValues(alpha: .16),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: palette.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                            : palette.textSecondary.withValues(alpha: .18),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                      ),
                      child: FilledButton.icon(
                        key: const ValueKey('save-motivation-message'),
                        onPressed: _canSave
                            ? () => Navigator.pop(context, _message.trim())
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: const Icon(PhosphorIconsBold.check, size: 19),
                        label: Text(l10n.profileSave),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotivationPreview extends StatelessWidget {
  const _MotivationPreview({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 138,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette.isDark
              ? [palette.primarySoft, palette.tint(AppColors.green, .14)]
              : const [Color(0xFFE7DCFF), Color(0xFFDFF7F1)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border, width: 2),
      ),
      child: Row(
        children: [
          const Expanded(child: UserAvatar(size: 122)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: .88),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration(context),
    child: Column(
      children: [
        const Icon(PhosphorIconsFill.quotes, color: AppColors.lilac, size: 34),
        const SizedBox(height: 8),
        Text(
          context.l10n.personalizationNoMessages,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.palette.textSecondary),
        ),
        const SizedBox(height: 12),
        _AddButton(onPressed: onAdd),
      ],
    ),
  );
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      key: const ValueKey('add-motivation-message'),
      onPressed: onPressed,
      icon: const Icon(PhosphorIconsBold.plus),
      label: Text(context.l10n.personalizationAddMessage),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: context.palette.primary, width: 1.5),
      ),
    ),
  );
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.onEdit,
    required this.onDelete,
  });
  final String message;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
    decoration: _cardDecoration(context),
    child: Row(
      children: [
        const Icon(PhosphorIconsFill.quotes, color: AppColors.lilac),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: onEdit,
          tooltip: context.l10n.edit,
          icon: Icon(
            PhosphorIconsBold.pencilSimple,
            color: context.palette.primary,
          ),
        ),
        IconButton(
          onPressed: onDelete,
          tooltip: context.l10n.delete,
          icon: const Icon(PhosphorIconsBold.trash, color: AppColors.pink),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    decoration: _cardDecoration(context),
    child: Column(children: children),
  );
}

BoxDecoration _cardDecoration(BuildContext context) {
  final palette = context.palette;
  return BoxDecoration(
    color: palette.surface.withValues(alpha: palette.isDark ? 1 : .84),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: palette.border),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: context.palette.tint(color),
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
                style: TextStyle(color: context.palette.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    ),
  );
}

/// Selector de tema: claro y oscuro en tarjetas
/// iguales, con una miniatura que anticipa el resultado. La opción activa se
/// resalta con el acento y una marca; el resto se atenúa sin desaparecer.
class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.value,
    required this.isPremium,
    required this.onChanged,
  });

  final ThemeMode value;
  final bool isPremium;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _ThemeModeOption(
            key: const ValueKey('theme-mode-light'),
            mode: ThemeMode.light,
            icon: PhosphorIconsBold.sun,
            label: l10n.appearanceLightTheme,
            selected: value == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeModeOption(
            key: const ValueKey('theme-mode-dark'),
            mode: ThemeMode.dark,
            icon: PhosphorIconsBold.moon,
            label: l10n.appearanceDarkTheme,
            selected: value == ThemeMode.dark,
            premium: !isPremium,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ),
      ],
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    super.key,
    required this.mode,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.premium = false,
  });

  final ThemeMode mode;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = selected ? palette.primary : palette.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            decoration: BoxDecoration(
              color: selected ? palette.primarySoft : palette.surfaceMuted,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? palette.primary : palette.divider,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeMiniature(mode: mode, selected: selected),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: foreground, size: 15),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 12.5,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (premium) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          PhosphorIconsFill.crown,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumDarkThemeDialog extends StatelessWidget {
  const _PremiumDarkThemeDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      key: const ValueKey('premium-dark-theme-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: palette.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/premium.png',
                width: 190,
                height: 150,
                fit: BoxFit.contain,
                semanticLabel: l10n.premiumCatImageLabel,
              ),
              Text(
                l10n.premiumDarkThemeTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.premiumDarkThemeBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 150,
                height: 238,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: .55),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withValues(alpha: .2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/dark_theme_premium_preview.png',
                  key: const ValueKey('dark-theme-premium-preview'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  semanticLabel: l10n.premiumDarkThemePreviewLabel,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.premiumNotNow),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: FilledButton(
                        key: const ValueKey('dark-theme-view-premium-plans'),
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          l10n.premiumViewPlans,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppIconSelector extends StatelessWidget {
  const _AppIconSelector({required this.value, required this.onChanged});

  final AppIconOption value;
  final ValueChanged<AppIconOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        for (final icon in AppIconOption.values) ...[
          if (icon != AppIconOption.values.first) const SizedBox(width: 8),
          Expanded(
            child: _AppIconTile(
              key: ValueKey('app-icon-${icon.name}'),
              icon: icon,
              label: switch (icon) {
                AppIconOption.classic => l10n.appearanceClassic,
                AppIconOption.crown => l10n.appIconCrown,
                AppIconOption.yarn => l10n.appIconYarn,
              },
              selected: value == icon,
              premium: icon.isPremium,
              onTap: () => onChanged(icon),
            ),
          ),
        ],
      ],
    );
  }
}

class _AppIconTile extends StatelessWidget {
  const _AppIconTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.premium,
    required this.onTap,
  });

  final AppIconOption icon;
  final String label;
  final bool selected;
  final bool premium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = selected ? palette.primary : palette.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
            decoration: BoxDecoration(
              color: selected ? palette.primarySoft : palette.surfaceMuted,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? palette.primary : palette.divider,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      // Mismo redondeo relativo que la máscara de iOS.
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        icon.previewAsset,
                        width: 62,
                        height: 62,
                        excludeFromSemantics: true,
                      ),
                    ),
                    // La corona marca siempre los iconos Premium, también
                    // cuando ya se tiene acceso o están seleccionados.
                    if (premium)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: _IconBadge(
                          icon: PhosphorIconsFill.crown,
                          gradient: true,
                        ),
                      ),
                    if (selected)
                      const Positioned(
                        bottom: -6,
                        right: -6,
                        child: _IconBadge(icon: PhosphorIconsBold.check),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.gradient = false});

  final IconData icon;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: gradient ? null : palette.primary,
        gradient: gradient
            ? const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              )
            : null,
        shape: BoxShape.circle,
        border: Border.all(color: palette.surface, width: 2),
      ),
      child: Icon(
        icon,
        size: 11,
        color: gradient ? Colors.white : palette.onPrimary,
      ),
    );
  }
}

class _PremiumAppIconDialog extends StatelessWidget {
  const _PremiumAppIconDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    Widget preview(AppIconOption icon) => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: .22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          icon.previewAsset,
          width: 104,
          height: 104,
          excludeFromSemantics: true,
        ),
      ),
    );
    return Dialog(
      key: const ValueKey('premium-app-icon-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: palette.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                image: true,
                label: l10n.premiumAppIconPreviewLabel,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: -.08,
                      child: preview(AppIconOption.crown),
                    ),
                    const SizedBox(width: 14),
                    Transform.rotate(
                      angle: .08,
                      child: preview(AppIconOption.yarn),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                l10n.premiumAppIconTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.premiumAppIconBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.premiumNotNow),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: FilledButton(
                        key: const ValueKey('app-icon-view-premium-plans'),
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          l10n.premiumViewPlans,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Miniatura de pantalla: fondo, una tarjeta y una barra de acento con los
/// colores reales de la paleta que representa.
class _ThemeMiniature extends StatelessWidget {
  const _ThemeMiniature({required this.mode, required this.selected});

  final ThemeMode mode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final current = context.palette;
    final light = AppPalette.light;
    final dark = AppPalette.dark;
    final child = switch (mode) {
      ThemeMode.light => _MiniScreen(palette: light),
      ThemeMode.dark => _MiniScreen(palette: dark),
      ThemeMode.system => _MiniScreen(palette: light),
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AspectRatio(
          aspectRatio: 1.35,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: current.divider),
                borderRadius: BorderRadius.circular(11),
              ),
              child: child,
            ),
          ),
        ),
        if (selected)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: current.primary,
                shape: BoxShape.circle,
                border: Border.all(color: current.surface, width: 2),
              ),
              child: Icon(
                PhosphorIconsBold.check,
                size: 11,
                color: current.onPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniScreen extends StatelessWidget {
  const _MiniScreen({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: palette.background,
    child: Padding(
      padding: const EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 5,
            decoration: BoxDecoration(
              color: palette.textPrimary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.border),
              ),
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    width: 18,
                    decoration: BoxDecoration(
                      color: palette.textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
