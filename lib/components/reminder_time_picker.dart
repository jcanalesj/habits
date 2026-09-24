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
  barrierColor: context.palette.scrim,
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
    final palette = context.palette;
    // En claro se conserva el violeta profundo de marca; en oscuro no tiene
    // contraste sobre la superficie, así que se usa el acento de la paleta.
    final accent = palette.primaryDeep;
    return Dialog(
      key: const ValueKey('reminder-time-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: palette.dialogSurface,
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
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.reminderPickerSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
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
                  style: TextStyle(
                    color: accent,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: accent,
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
                          side: BorderSide.none,
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
  Widget build(BuildContext context) {
    final palette = context.palette;
    // En claro, el relleno de campo es exactamente el tinte original
    // (primary al 5,5 %); en oscuro la rueda se apoya sobre `surface` para
    // que los números queden legibles.
    final fill = palette.isDark ? palette.surface : palette.inputFill;
    final accent = palette.primaryDeep;
    return Container(
      width: 104,
      decoration: BoxDecoration(
        color: fill,
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
              style: TextStyle(
                color: accent,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: palette.tint(color, selected ? .18 : .09),
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
}
