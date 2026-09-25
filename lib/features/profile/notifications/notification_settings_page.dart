import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/app_lifecycle.dart';
import 'package:habits/components/app_error_view.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/components/habit_icon_catalog.dart';
import 'package:habits/components/reminder_time_picker.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/notifications/reminder_permission.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/premium/premium_gate.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  final Set<String> _saving = {};

  TimeOfDay _timeOf(String? value) {
    final parts = value?.split(':');
    if (parts?.length == 2) {
      return TimeOfDay(
        hour: int.tryParse(parts![0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _serialize(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

  Future<void> _chooseTime(Habit habit) async {
    if (_saving.contains(habit.id)) return;
    final selected = await showReminderTimePicker(
      context: context,
      initialTime: _timeOf(habit.reminderTime),
    );
    if (selected == null) return;
    await _save(habit, habit.copyWith(reminderTime: _serialize(selected)));
    if (!mounted) return;
    await ensureReminderPermission(context, ref);
  }

  Future<void> _requestPermission() async {
    final l10n = context.l10n;
    final result = await ref
        .read(notificationsRepositoryProvider)
        .requestPermission();
    // Refresca el permiso mostrado y hace que la Home reprograme los avisos:
    // sin esto, concederlo no programaba nada hasta el siguiente cambio.
    ref.read(systemStateTickProvider.notifier).bump();
    if (!mounted) return;
    if (result == NotificationPermission.denied) {
      // Android e iOS solo preguntan una vez: a partir de ahí hay que ir a
      // los ajustes del sistema, así que se dice en lugar de reintentar.
      AppNotice.show(
        context,
        message: l10n.notificationsDeniedHint,
        type: AppNoticeType.error,
      );
    }
  }

  Future<void> _editMessage(Habit habit) async {
    if (_saving.contains(habit.id)) return;
    final allowed = await requestPremiumAccess(
      context,
      ref,
      dialogBuilder: (_) => const _PremiumReminderMessageDialog(),
    );
    if (!allowed || !mounted) return;
    final message = await showDialog<String>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (_) => _ReminderMessageDialog(
        habitName: habit.name,
        initialValue: habit.reminderMessage ?? '',
      ),
    );
    if (message == null) return;
    await _save(habit, habit.copyWith(reminderMessage: message));
  }

  Future<void> _save(Habit habit, Habit updated) async {
    setState(() => _saving.add(habit.id));
    final result = await ref
        .read(updateHabitUsecaseProvider)
        .execute(original: habit, updated: updated);
    if (!mounted) return;
    setState(() => _saving.remove(habit.id));
    AppNotice.show(
      context,
      message: result is UpdateHabitSuccess
          ? context.l10n.notificationReminderSaved
          : context.l10n.errorSaveFailed,
      type: result is UpdateHabitSuccess
          ? AppNoticeType.success
          : AppNoticeType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          context.l10n.profileNotifications,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: switch (habitsAsync) {
        AsyncData(:final value) => _body(value),
        AsyncError(:final error) => AppErrorView(
          error: error,
          onRetry: () => ref.invalidate(activeHabitsProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(List<Habit> habits) {
    final l10n = context.l10n;
    final palette = context.palette;
    final isPremium = ref.watch(premiumAccessProvider);
    final enabledCount = habits
        .where((habit) => habit.reminderTime != null)
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: palette.isDark
                  ? [palette.primarySoft, palette.tint(AppColors.pink, .14)]
                  : const [Color(0xFFF0E9FF), Color(0xFFFFF2FA)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const UserAvatar(size: 82),
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.pink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        PhosphorIconsFill.bell,
                        color: Colors.white,
                        size: 19,
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
                      l10n.notificationHeroTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.notificationHeroBody,
                      style: TextStyle(
                        color: palette.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Sin permiso del sistema, las horas que configure aquí no sonarían
        // nunca. Mejor decirlo arriba y dar el botón que dejar que lo
        // descubra por su cuenta.
        if (ref.watch(notificationPermissionProvider).value ==
            NotificationPermission.denied) ...[
          _PermissionCard(onRequest: _requestPermission),
          const SizedBox(height: 14),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: _surfaceDecoration(palette),
          child: Row(
            children: [
              const _BellBox(),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notificationActiveSummary(enabledCount),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      l10n.notificationActiveSummaryHint,
                      style: TextStyle(color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.profileReminderSettings,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(
          l10n.notificationHabitListHint,
          style: TextStyle(color: palette.textSecondary),
        ),
        const SizedBox(height: 12),
        if (habits.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: _surfaceDecoration(palette),
            child: Column(
              children: [
                const UserAvatar(size: 86),
                const SizedBox(height: 14),
                Text(
                  l10n.profileNoHabits,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: _surfaceDecoration(palette),
            child: Column(
              children: [
                for (var index = 0; index < habits.length; index++) ...[
                  _ReminderTile(
                    habit: habits[index],
                    saving: _saving.contains(habits[index].id),
                    onTap: () => _chooseTime(habits[index]),
                    onEnabledChanged: (enabled) => enabled
                        ? _chooseTime(habits[index])
                        : _save(
                            habits[index],
                            habits[index].copyWith(reminderTime: null),
                          ),
                    onMessageTap: () => _editMessage(habits[index]),
                    isPremium: isPremium,
                  ),
                  if (index != habits.length - 1)
                    const Divider(height: 1, indent: 76, endIndent: 16),
                ],
              ],
            ),
          ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.primarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIconsBold.clock, color: palette.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.notificationTimezoneHint,
                  style: TextStyle(color: palette.textSecondary, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.habit,
    required this.saving,
    required this.onTap,
    required this.onEnabledChanged,
    required this.onMessageTap,
    required this.isPremium,
  });

  final Habit habit;
  final bool saving;
  final VoidCallback onTap;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onMessageTap;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = habit.reminderTime != null;
    final color = Color(habit.colorValue);
    return InkWell(
      onTap: saving ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.tint(color),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: HabitIcon(
                    iconId: habit.iconId,
                    legacyEmoji: habit.emoji,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        enabled
                            ? context.l10n.notificationEveryDayAt(
                                habit.reminderTime!,
                              )
                            : context.l10n.habitReminderNone,
                        style: TextStyle(
                          color: enabled ? color : palette.textSecondary,
                          fontWeight: enabled
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (saving)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Switch.adaptive(value: enabled, onChanged: onEnabledChanged),
              ],
            ),
            if (enabled) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 62),
                child: Material(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    key: ValueKey('reminder-message-${habit.id}'),
                    onTap: saving ? null : onMessageTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIconsBold.chatText,
                            color: palette.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.notificationCustomMessage,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  habit.reminderMessage ??
                                      context
                                          .l10n
                                          .notificationDefaultMessageHint,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
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
                                color: Colors.white,
                                size: 13,
                              ),
                            )
                          else
                            Icon(
                              PhosphorIconsBold.pencilSimple,
                              color: palette.primary,
                              size: 19,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReminderMessageDialog extends StatefulWidget {
  const _ReminderMessageDialog({
    required this.habitName,
    required this.initialValue,
  });
  final String habitName;
  final String initialValue;

  @override
  State<_ReminderMessageDialog> createState() => _ReminderMessageDialogState();
}

class _ReminderMessageDialogState extends State<_ReminderMessageDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

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
      key: const ValueKey('reminder-message-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: palette.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                PhosphorIconsFill.chatTeardropText,
                color: palette.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.notificationCustomMessageTitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.notificationCustomMessageBody(widget.habitName),
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 18),
            TextField(
              key: const ValueKey('reminder-message-field'),
              controller: _controller,
              autofocus: true,
              maxLength: 120,
              minLines: 3,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.reminderNotificationBody,
                filled: true,
                fillColor: palette.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('save-reminder-message'),
                    onPressed: () =>
                        Navigator.pop(context, _controller.text.trim()),
                    icon: const Icon(PhosphorIconsBold.check, size: 18),
                    label: Text(l10n.profileSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumReminderMessageDialog extends StatelessWidget {
  const _PremiumReminderMessageDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      key: const ValueKey('premium-reminder-message-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: palette.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
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
              l10n.premiumReminderMessageTitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.premiumReminderMessageBody,
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
                  child: FilledButton(
                    key: const ValueKey('reminder-message-view-premium-plans'),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      l10n.premiumViewPlans,
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
  }
}

class _BellBox extends StatelessWidget {
  const _BellBox();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: palette.tint(AppColors.pink),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        PhosphorIconsFill.bellRinging,
        color: AppColors.pink,
        size: 27,
      ),
    );
  }
}

BoxDecoration _surfaceDecoration(AppPalette palette) => BoxDecoration(
  color: palette.surface.withValues(alpha: palette.isDark ? 1 : .84),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: palette.border),
);

/// Aviso de que el sistema tiene las notificaciones bloqueadas.
class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _surfaceDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsBold.bellSlash, color: palette.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.notificationsDisabledTitle,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.notificationsDisabledBody,
            style: TextStyle(color: palette.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRequest,
            child: Text(l10n.notificationsEnableAction),
          ),
        ],
      ),
    );
  }
}
