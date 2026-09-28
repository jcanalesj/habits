import 'package:flutter/material.dart';
import 'package:habits/features/pomodoro/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Ajustes del temporizador en hoja inferior. Devuelve la configuración
/// nueva o null si se cierra sin guardar.
Future<PomodoroConfig?> showPomodoroSettingsSheet(
  BuildContext context, {
  required PomodoroConfig initial,
}) => showModalBottomSheet<PomodoroConfig>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  backgroundColor: context.palette.surfaceElevated,
  builder: (_) => _SettingsSheet(initial: initial),
);

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({required this.initial});
  final PomodoroConfig initial;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late PomodoroConfig _config = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pomodoroSettingsTitle,
              style: textTheme.titleLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _StepperRow(
              label: l10n.pomodoroSettingWork,
              value: _config.workMinutes,
              unit: l10n.pomodoroMinutesLabel,
              range: PomodoroConfig.workRange,
              step: 5,
              color: AppColors.flame,
              onChanged: (value) => setState(
                () => _config = _config.copyWith(workMinutes: value),
              ),
            ),
            _StepperRow(
              label: l10n.pomodoroSettingShortBreak,
              value: _config.shortBreakMinutes,
              unit: l10n.pomodoroMinutesLabel,
              range: PomodoroConfig.shortBreakRange,
              step: 1,
              color: AppColors.green,
              onChanged: (value) => setState(
                () => _config = _config.copyWith(shortBreakMinutes: value),
              ),
            ),
            _StepperRow(
              label: l10n.pomodoroSettingLongBreak,
              value: _config.longBreakMinutes,
              unit: l10n.pomodoroMinutesLabel,
              range: PomodoroConfig.longBreakRange,
              step: 5,
              color: AppColors.blue,
              onChanged: (value) => setState(
                () => _config = _config.copyWith(longBreakMinutes: value),
              ),
            ),
            _StepperRow(
              label: l10n.pomodoroSettingPerCycle,
              value: _config.pomodorosPerCycle,
              range: PomodoroConfig.perCycleRange,
              step: 1,
              color: palette.primary,
              onChanged: (value) => setState(
                () => _config = _config.copyWith(pomodorosPerCycle: value),
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pomodoroSettingAutoBreaks),
              value: _config.autoStartBreaks,
              onChanged: (value) => setState(
                () => _config = _config.copyWith(autoStartBreaks: value),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pomodoroSettingAutoWork),
              value: _config.autoStartWork,
              onChanged: (value) => setState(
                () => _config = _config.copyWith(autoStartWork: value),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pomodoroSettingSound),
              value: _config.sound,
              onChanged: (value) =>
                  setState(() => _config = _config.copyWith(sound: value)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.pomodoroSettingVibration),
              value: _config.vibration,
              onChanged: (value) =>
                  setState(() => _config = _config.copyWith(vibration: value)),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('pomodoro-settings-save'),
              onPressed: _config.isValid
                  ? () => Navigator.pop(context, _config)
                  : null,
              child: Text(l10n.pomodoroSettingsSave),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.range,
    required this.step,
    required this.color,
    required this.onChanged,
    this.unit,
  });

  final String label;
  final int value;
  final String? unit;
  final (int, int) range;
  final int step;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final canDecrease = value - step >= range.$1;
    final canIncrease = value + step <= range.$2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _RoundButton(
            icon: PhosphorIconsBold.minus,
            color: color,
            onPressed: canDecrease ? () => onChanged(value - step) : null,
          ),
          SizedBox(
            width: 74,
            child: Text(
              unit == null ? '$value' : '$value ${unit!.substring(0, 3)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _RoundButton(
            icon: PhosphorIconsBold.plus,
            color: color,
            onPressed: canIncrease ? () => onChanged(value + step) : null,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: palette.tint(color, .12),
        foregroundColor: color,
        disabledBackgroundColor: palette.surfaceMuted,
        disabledForegroundColor: palette.textHint,
        minimumSize: const Size(40, 40),
      ),
    );
  }
}
