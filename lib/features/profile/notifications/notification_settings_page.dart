import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/components/habit_icon_catalog.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
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
    final selected = await showTimePicker(
      context: context,
      initialTime: _timeOf(habit.reminderTime),
      helpText: context.l10n.notificationChooseTime,
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.profileSave,
    );
    if (selected == null) return;
    await _update(habit, _serialize(selected));
  }

  Future<void> _update(Habit habit, String? reminder) async {
    setState(() => _saving.add(habit.id));
    final result = await ref
        .read(updateHabitUsecaseProvider)
        .execute(
          original: habit,
          updated: habit.copyWith(reminderTime: reminder),
        );
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
        AsyncError() => Center(child: Text(context.l10n.errorSaveFailed)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(List<Habit> habits) {
    final l10n = context.l10n;
    final enabledCount = habits
        .where((habit) => habit.reminderTime != null)
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0E9FF), Color(0xFFFFF2FA)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white),
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
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: _surfaceDecoration(),
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
                      style: const TextStyle(color: AppColors.textSecondary),
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
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        if (habits.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: _surfaceDecoration(),
            child: Column(
              children: [
                const UserAvatar(size: 86),
                const SizedBox(height: 14),
                Text(
                  l10n.profileNoHabits,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: _surfaceDecoration(),
            child: Column(
              children: [
                for (var index = 0; index < habits.length; index++) ...[
                  _ReminderTile(
                    habit: habits[index],
                    saving: _saving.contains(habits[index].id),
                    onTap: () => _chooseTime(habits[index]),
                    onEnabledChanged: (enabled) => enabled
                        ? _chooseTime(habits[index])
                        : _update(habits[index], null),
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
            color: const Color(0xFFF0EAFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(PhosphorIconsBold.clock, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.notificationTimezoneHint,
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
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.habit,
    required this.saving,
    required this.onTap,
    required this.onEnabledChanged,
  });

  final Habit habit;
  final bool saving;
  final VoidCallback onTap;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = habit.reminderTime != null;
    final color = Color(habit.colorValue);
    return InkWell(
      onTap: saving ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
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
                      color: enabled ? color : AppColors.textSecondary,
                      fontWeight: enabled ? FontWeight.w700 : FontWeight.w400,
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
      ),
    );
  }
}

class _BellBox extends StatelessWidget {
  const _BellBox();

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppColors.pink.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Icon(
      PhosphorIconsFill.bellRinging,
      color: AppColors.pink,
      size: 27,
    ),
  );
}

BoxDecoration _surfaceDecoration() => BoxDecoration(
  color: Colors.white.withValues(alpha: .84),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: Colors.white),
);
