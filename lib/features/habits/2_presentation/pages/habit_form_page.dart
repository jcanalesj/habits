import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Alta y edición de un hábito.
///
/// Dos detalles que vienen del motor de la fase 5:
///  - el objetivo se expresa como "X veces por periodo", sin días concretos;
///  - un cambio de objetivo NO altera el periodo en curso, así que la
///    pantalla avisa de la fecha efectiva ANTES de guardar (§10).
class HabitFormPage extends ConsumerStatefulWidget {
  const HabitFormPage({super.key, this.habitId});

  /// Null para crear, id del hábito para editar.
  final String? habitId;

  bool get isEditing => habitId != null;

  @override
  ConsumerState<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends ConsumerState<HabitFormPage> {
  static const _palette = [
    AppColors.lilac,
    AppColors.pink,
    AppColors.green,
    AppColors.orange,
    AppColors.blue,
    AppColors.primary,
  ];
  static const _emojis = [
    '💧',
    '📖',
    '🏋️',
    '🧘',
    '🏃',
    '💬',
    '🥗',
    '😴',
    '🎸',
    '🧠',
    '✍️',
    '🌿',
  ];

  final _nameController = TextEditingController();
  final _emojiController = TextEditingController(text: '💧');

  String? _ambitoId;
  int _colorValue = 0xFF8B5CF6;
  Periodicity _periodicity = Periodicity.daily;
  TimeOfDay? _reminder;

  /// Objetivo con el que se cargó el hábito, para saber si cambió.
  Periodicity? _originalPeriodicity;
  Habit? _loaded;
  bool _saving = false;
  bool _prefilled = false;
  Set<HabitValidationError> _errors = const {};

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _prefillFrom(Habit habit, LogicalDate today) {
    if (_prefilled) return;
    _prefilled = true;
    _loaded = habit;
    _nameController.text = habit.name;
    _emojiController.text = habit.emoji;
    _ambitoId = habit.ambitoId;
    _colorValue = habit.colorValue;
    _periodicity = habit.periodicityOn(today);
    _originalPeriodicity = _periodicity;
    final reminder = habit.reminderTime;
    if (reminder != null) {
      final parts = reminder.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          _reminder = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
  }

  String? get _reminderText => _reminder == null
      ? null
      : '${_reminder!.hour.toString().padLeft(2, '0')}:'
            '${_reminder!.minute.toString().padLeft(2, '0')}';

  String _errorFor(AppLocalizations l10n) {
    if (_errors.contains(HabitValidationError.nameRequired)) {
      return l10n.errorNameRequired;
    }
    if (_errors.contains(HabitValidationError.nameTooLong)) {
      return l10n.errorNameTooLong;
    }
    if (_errors.contains(HabitValidationError.emojiRequired)) {
      return l10n.errorEmojiRequired;
    }
    if (_errors.contains(HabitValidationError.invalidTimesPerPeriod)) {
      return l10n.errorTimesInvalid;
    }
    return l10n.errorReminderInvalid;
  }

  /// Aviso de cuándo entrará en vigor el cambio de objetivo, o null si no
  /// hay cambio pendiente.
  String? _deferredNotice(LogicalDate today) {
    final original = _originalPeriodicity;
    if (original == null || original == _periodicity) return null;
    final effectiveFrom = ref
        .read(changeHabitPeriodicityUsecaseProvider)
        .previewEffectiveDate(_periodicity, today);
    return context.l10n.frequencyChangeDeferred(effectiveFrom.key);
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save(LogicalDate today) async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      final ok = widget.isEditing
          ? await _saveExisting(today, l10n)
          : await _create(today, l10n);
      if (!ok || !mounted) return;
      _notify(widget.isEditing ? l10n.habitSaved : l10n.habitCreated);
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _create(LogicalDate today, AppLocalizations l10n) async {
    final result = await ref
        .read(createHabitUsecaseProvider)
        .execute(
          HabitDraft(
            name: _nameController.text,
            ambitoId: _ambitoId ?? Ambito.generalId,
            periodicity: _periodicity,
            colorValue: _colorValue,
            emoji: _emojiController.text,
            reminderTime: _reminderText,
          ),
          today: today,
        );
    switch (result) {
      case CreateHabitSuccess():
        return true;
      case CreateHabitValidationFailed(:final errors):
        setState(() => _errors = errors);
        return false;
      case CreateHabitFailed():
        _notify(l10n.errorSaveFailed);
        return false;
    }
  }

  Future<bool> _saveExisting(LogicalDate today, AppLocalizations l10n) async {
    final original = _loaded;
    if (original == null) return false;

    // Los campos simples van por UpdateHabitUsecase; el objetivo tiene su
    // propio usecase porque implica calcular la fecha efectiva y respetar el
    // periodo en curso.
    final result = await ref
        .read(updateHabitUsecaseProvider)
        .execute(
          original: original,
          updated: original.copyWith(
            // La identidad del hábito no se edita: cambiar nombre o ámbito
            // equivale a crear un hábito distinto.
            name: original.name,
            emoji: _emojiController.text,
            colorValue: _colorValue,
            ambitoId: original.ambitoId,
            reminderTime: _reminderText,
          ),
        );
    switch (result) {
      case UpdateHabitValidationFailed(:final errors):
        setState(() => _errors = errors);
        return false;
      case UpdateHabitFailed():
        _notify(l10n.errorSaveFailed);
        return false;
      case UpdateHabitSuccess(:final habit):
        if (_periodicity == _originalPeriodicity) return true;
        final change = await ref
            .read(changeHabitPeriodicityUsecaseProvider)
            .execute(habit: habit, next: _periodicity, today: today);
        switch (change) {
          case ChangePeriodicityScheduled():
          case ChangePeriodicityUnchanged():
            return true;
          case ChangePeriodicityInvalid(:final errors):
            setState(() => _errors = errors);
            return false;
          case ChangePeriodicityFailed():
            _notify(l10n.errorSaveFailed);
            return false;
        }
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteHabitConfirmTitle),
        content: Text(l10n.deleteHabitConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(deleteHabitUsecaseProvider)
        .execute(widget.habitId!);
    if (!mounted) return;
    if (result is DeleteHabitSuccess) {
      _notify(l10n.habitDeleted);
      Navigator.of(context).pop();
    } else {
      _notify(l10n.errorSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = ref.watch(todayProvider);
    final ambitos = ref.watch(ambitosProvider).value ?? const <Ambito>[];

    if (widget.isEditing && !_prefilled) {
      final habit = ref.watch(habitByIdProvider(widget.habitId!));
      switch (habit) {
        case AsyncData(:final value):
          if (value == null) {
            return _Scaffold(
              title: l10n.editHabitTitle,
              child: Center(child: Text(l10n.habitNotFound)),
            );
          }
          _prefillFrom(value, today);
        case AsyncError():
          return _Scaffold(
            title: l10n.editHabitTitle,
            child: Center(child: Text(l10n.errorSaveFailed)),
          );
        case _:
          return _Scaffold(
            title: l10n.editHabitTitle,
            child: const Center(child: CircularProgressIndicator()),
          );
      }
    }

    _ambitoId ??= ambitos.isEmpty ? Ambito.generalId : ambitos.first.id;

    return _Scaffold(
      title: widget.isEditing ? l10n.editHabitTitle : l10n.newHabitTitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isEditing) ...[
                  _Label(l10n.habitNameLabel),
                  AuthTextField(
                    controller: _nameController,
                    hint: l10n.habitNameHint,
                    icon: Icons.edit_rounded,
                    errorText: _errors.isEmpty ? null : _errorFor(l10n),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _nameController.text,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.habitIdentityLockedHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _Label(l10n.habitEmojiLabel),
                _EmojiPicker(
                  emojis: _emojis,
                  selected: _emojiController.text,
                  onSelected: (emoji) =>
                      setState(() => _emojiController.text = emoji),
                ),
                const SizedBox(height: 20),
                _Label(l10n.habitColorLabel),
                _ColorPicker(
                  palette: _palette,
                  selected: _colorValue,
                  onSelected: (value) => setState(() => _colorValue = value),
                ),
              ],
            ),
          ),
          if (!widget.isEditing) ...[
            const SizedBox(height: 16),
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(l10n.habitAmbitoLabel),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final ambito in ambitos)
                        ChoiceChip(
                          avatar: Text(ambito.emoji),
                          label: Text(ambito.name),
                          selected: _ambitoId == ambito.id,
                          onSelected: (_) =>
                              setState(() => _ambitoId = ambito.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(l10n.habitPeriodicityLabel),
                PeriodicityField(
                  value: _periodicity,
                  onChanged: (value) => setState(() => _periodicity = value),
                  deferredNotice: _deferredNotice(today),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(l10n.habitReminderLabel),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _reminderText == null
                            ? l10n.habitReminderNone
                            : l10n.habitReminderSet(_reminderText!),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (_reminder != null)
                      IconButton(
                        onPressed: () => setState(() => _reminder = null),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    IconButton.filledTonal(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              _reminder ?? const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (picked != null) {
                          setState(() => _reminder = picked);
                        }
                      },
                      icon: const Icon(Icons.schedule_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: widget.isEditing ? l10n.saveHabit : l10n.createHabit,
            isLoading: _saving,
            trailingArrow: false,
            onPressed: () => _save(today),
          ),
          if (widget.isEditing) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.deleteHabit),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(top: false, child: child),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  const _EmojiPicker({
    required this.emojis,
    required this.selected,
    required this.onSelected,
  });

  final List<String> emojis;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final emoji in emojis)
          GestureDetector(
            onTap: () => onSelected(emoji),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: emoji == selected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: emoji == selected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
      ],
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.palette,
    required this.selected,
    required this.onSelected,
  });

  final List<Color> palette;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final color in palette)
          GestureDetector(
            onTap: () => onSelected(color.toARGB32()),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: color.toARGB32() == selected
                    ? Border.all(color: AppColors.textPrimary, width: 3)
                    : null,
              ),
              child: color.toARGB32() == selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
