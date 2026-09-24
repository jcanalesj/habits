import 'package:flutter/material.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

Future<TimeOfDay?> showReminderTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) => showDialog<TimeOfDay>(
  context: context,
  barrierColor: AppColors.textPrimary.withValues(alpha: .58),
  builder: (context) => _ReminderTimeDialog(initialTime: initialTime),
);

class _ReminderTimeDialog extends StatefulWidget {
  const _ReminderTimeDialog({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_ReminderTimeDialog> createState() => _ReminderTimeDialogState();
}

class _ReminderTimeDialogState extends State<_ReminderTimeDialog> {
  late int _hour = widget.initialTime.hour;
  late int _minute = widget.initialTime.minute;
  late final FixedExtentScrollController _hourController =
      FixedExtentScrollController(initialItem: _hour);
  late final FixedExtentScrollController _minuteController =
      FixedExtentScrollController(initialItem: _minute);

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  void _selectPreset(int hour) {
    setState(() {
      _hour = hour;
      _minute = 0;
    });
    _hourController.animateToItem(
      hour,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    _minuteController.animateToItem(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      key: const ValueKey('reminder-time-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: const Color(0xFFFCFAFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const UserAvatar(size: 76),
              const SizedBox(height: 12),
              Text(
                l10n.reminderPickerTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.reminderPickerSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientStart.withValues(alpha: .16),
                      AppColors.gradientEnd.withValues(alpha: .10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  '${_twoDigits(_hour)}:${_twoDigits(_minute)}',
                  key: const ValueKey('reminder-selected-time'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryDeep,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 168,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NumberWheel(
                      key: const ValueKey('reminder-hour-wheel'),
                      controller: _hourController,
                      count: 24,
                      onChanged: (value) => setState(() => _hour = value),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: AppColors.primaryDeep,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _NumberWheel(
                      key: const ValueKey('reminder-minute-wheel'),
                      controller: _minuteController,
                      count: 60,
                      onChanged: (value) => setState(() => _minute = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _PresetButton(
                      icon: PhosphorIconsFill.sunHorizon,
                      label: l10n.reminderPickerMorning,
                      color: AppColors.green,
                      selected: _hour == 9 && _minute == 0,
                      onTap: () => _selectPreset(9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PresetButton(
                      icon: PhosphorIconsFill.sun,
                      label: l10n.reminderPickerAfternoon,
                      color: AppColors.orange,
                      selected: _hour == 15 && _minute == 0,
                      onTap: () => _selectPreset(15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PresetButton(
                      icon: PhosphorIconsFill.moon,
                      label: l10n.reminderPickerNight,
                      color: AppColors.blue,
                      selected: _hour == 21 && _minute == 0,
                      onTap: () => _selectPreset(21),
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: FilledButton.icon(
                        key: const ValueKey('save-reminder-time'),
                        onPressed: () => Navigator.pop(
                          context,
                          TimeOfDay(hour: _hour, minute: _minute),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: const Icon(PhosphorIconsBold.check, size: 19),
                        label: Text(l10n.reminderPickerSave),
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

class _NumberWheel extends StatelessWidget {
  const _NumberWheel({
    super.key,
    required this.controller,
    required this.count,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    width: 104,
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: .055),
      borderRadius: BorderRadius.circular(24),
    ),
    child: ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 54,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 1.8,
      perspective: .004,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: count,
        builder: (context, index) => Center(
          child: Text(
            index.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: AppColors.primaryDeep,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ),
  );
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: selected ? .18 : .09),
        borderRadius: BorderRadius.circular(18),
        border: selected
            ? Border.all(color: color.withValues(alpha: .45))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}
