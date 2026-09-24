import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  static const freeMessageLimit = 1;

  Future<void> _editMessage(
    BuildContext context,
    WidgetRef ref, {
    int? index,
    String initialValue = '',
  }) async {
    final message = await showDialog<String>(
      context: context,
      barrierColor: AppColors.textPrimary.withValues(alpha: .58),
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
    required bool isPremium,
  }) async {
    if (!isPremium && messageCount >= freeMessageLimit) {
      await showDialog<void>(
        context: context,
        barrierColor: AppColors.textPrimary.withValues(alpha: .62),
        builder: (_) => const _PremiumMessageLimitDialog(),
      );
      return;
    }
    if (context.mounted) await _editMessage(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final messages = ref.watch(customMotivationMessagesProvider);
    final isPremium = ref.watch(isPremiumProvider).value ?? false;
    void addMessage() => _addMessage(
      context,
      ref,
      messageCount: messages.length,
      isPremium: isPremium,
    );
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
            style: const TextStyle(color: AppColors.textSecondary),
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
                color: AppColors.primary,
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
                icon: PhosphorIconsBold.moon,
                color: AppColors.lilac,
                title: l10n.appearanceDarkTheme,
                subtitle: l10n.appearanceComingSoon,
                muted: true,
                trailing: _SoonPill(label: l10n.appearanceSoon),
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
    return Dialog(
      key: const ValueKey('premium-message-limit-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: const Color(0xFFFCFAFF),
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
                width: 190,
                height: 150,
                fit: BoxFit.contain,
                semanticLabel: l10n.premiumCatImageLabel,
              ),
              Text(
                l10n.premiumMessageLimitTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.premiumMessageLimitBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
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
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
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
    return Dialog(
      key: const ValueKey('motivation-message-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: const Color(0xFFFCFAFF),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE7DCFF), Color(0xFFFFE9F5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  PhosphorIconsFill.quotes,
                  color: AppColors.primary,
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
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.personalizationMessageHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
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
                  fillColor: AppColors.primary.withValues(alpha: .055),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: .16),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
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
                            : AppColors.textSecondary.withValues(alpha: .18),
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
  Widget build(BuildContext context) => Container(
    height: 138,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFE7DCFF), Color(0xFFDFF7F1)],
      ),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Row(
      children: [
        const Expanded(child: UserAvatar(size: 122)),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .88),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
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

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        const Icon(PhosphorIconsFill.quotes, color: AppColors.lilac, size: 34),
        const SizedBox(height: 8),
        Text(
          context.l10n.personalizationNoMessages,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
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
        side: const BorderSide(color: AppColors.primary, width: 1.5),
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
    decoration: _cardDecoration(),
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
          icon: const Icon(
            PhosphorIconsBold.pencilSimple,
            color: AppColors.primary,
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
    decoration: _cardDecoration(),
    child: Column(children: children),
  );
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white.withValues(alpha: .84),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: Colors.white),
);

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
