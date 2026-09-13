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
  static const _quickEmojis = [
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
  static const _palette = [
    AppColors.lilac,
    AppColors.pink,
    AppColors.green,
    AppColors.orange,
    AppColors.blue,
    AppColors.primary,
  ];
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController(text: '💧');
  final _unitController = TextEditingController();
  final _displayGoalController = TextEditingController();

  String? _ambitoId;
  int _colorValue = 0xFF8B5CF6;
  Periodicity _periodicity = Periodicity.daily;
  TimeOfDay? _reminder;
  HabitTrackingType _trackingType = HabitTrackingType.single;
  int _targetCount = 2;
  String _progressIconId = ProgressIconCatalog.fallbackId;

  /// Objetivo con el que se cargó el hábito, para saber si cambió.
  Periodicity? _originalPeriodicity;
  Habit? _loaded;
  bool _saving = false;
  bool _prefilled = false;
  Set<HabitValidationError> _errors = const {};

  static String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _unitController.dispose();
    _displayGoalController.dispose();
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
    _trackingType = habit.trackingType;
    _targetCount = habit.targetCount;
    _unitController.text = habit.unit ?? '';
    _displayGoalController.text = habit.displayGoal ?? '';
    _progressIconId = habit.progressIconId;
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

  bool get _canCreate {
    if (_ambitoId == null || _emojiController.text.trim().isEmpty) return false;
    final errors = HabitValidation.validateHabit(
      name: _nameController.text,
      emoji: _emojiController.text,
      periodicity: _periodicity,
      reminderTime: _reminderText,
    );
    if (errors.isNotEmpty) return false;
    return _trackingType != HabitTrackingType.repetitions || _targetCount >= 2;
  }

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

  void _notify(String message, {AppNoticeType type = AppNoticeType.success}) {
    if (!mounted) return;
    AppNotice.show(context, message: message, type: type);
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
            // El icono principal vuelve a ser un emoji. iconId se reserva
            // para compatibilidad con documentos creados por versiones
            // anteriores del selector SVG.
            iconId: null,
            reminderTime: _reminderText,
            trackingType: _trackingType,
            targetCount: _trackingType == HabitTrackingType.single
                ? 1
                : _targetCount,
            unit: _nullableText(_unitController.text),
            displayGoal: _nullableText(_displayGoalController.text),
            progressIconId: _progressIconId,
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
        _notify(l10n.errorSaveFailed, type: AppNoticeType.error);
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
            iconId: null,
            colorValue: _colorValue,
            ambitoId: original.ambitoId,
            reminderTime: _reminderText,
            trackingType: _trackingType,
            targetCount: _trackingType == HabitTrackingType.single
                ? 1
                : _targetCount,
            unit: _nullableText(_unitController.text),
            displayGoal: _nullableText(_displayGoalController.text),
            progressIconId: _progressIconId,
          ),
        );
    switch (result) {
      case UpdateHabitValidationFailed(:final errors):
        setState(() => _errors = errors);
        return false;
      case UpdateHabitFailed():
        _notify(l10n.errorSaveFailed, type: AppNoticeType.error);
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
            _notify(l10n.errorSaveFailed, type: AppNoticeType.error);
            return false;
        }
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.textPrimary.withValues(alpha: .48),
      builder: (context) => _DeleteHabitDialog(
        habitName: _nameController.text,
        emoji: _emojiController.text,
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
      _notify(l10n.errorSaveFailed, type: AppNoticeType.error);
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
                  emojis: _quickEmojis,
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
                _Label(l10n.habitTrackingQuestion),
                SegmentedButton<HabitTrackingType>(
                  segments: [
                    ButtonSegment(
                      value: HabitTrackingType.single,
                      label: Text(l10n.habitTrackingOnce),
                    ),
                    ButtonSegment(
                      value: HabitTrackingType.repetitions,
                      label: Text(l10n.habitTrackingSeveral),
                    ),
                  ],
                  selected: {_trackingType},
                  onSelectionChanged: (value) =>
                      setState(() => _trackingType = value.first),
                ),
                if (_trackingType == HabitTrackingType.repetitions) ...[
                  const SizedBox(height: 20),
                  _Label(l10n.habitTargetCount),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _targetCount > 2
                            ? () => setState(() => _targetCount--)
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      SizedBox(
                        width: 72,
                        child: Text(
                          '$_targetCount',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: _targetCount < 999
                            ? () => setState(() => _targetCount++)
                            : null,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _unitController,
                    maxLength: 24,
                    decoration: InputDecoration(
                      labelText: l10n.habitUnitOptional,
                      hintText: l10n.habitUnitHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _displayGoalController,
                    maxLength: 32,
                    decoration: InputDecoration(
                      labelText: l10n.habitDisplayGoalOptional,
                      hintText: l10n.habitDisplayGoalHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Label(l10n.habitProgressIcon),
                  Text(
                    l10n.habitProgressIconSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProgressIconPicker(
                    selectedId: _progressIconId,
                    onSelected: (id) => setState(() => _progressIconId = id),
                  ),
                ],
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
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _nameController,
            builder: (context, value, child) => GradientButton(
              label: widget.isEditing ? l10n.saveHabit : l10n.createHabit,
              isLoading: _saving,
              trailingArrow: false,
              onPressed: widget.isEditing || _canCreate
                  ? () => _save(today)
                  : null,
            ),
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

class _DeleteHabitDialog extends StatelessWidget {
  const _DeleteHabitDialog({required this.habitName, required this.emoji});

  final String habitName;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: const Color(0xFFFFFCFD),
          elevation: 0,
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDEF),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 42)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.deleteHabitConfirmTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      habitName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFE05262),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F4FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            color: AppColors.primary,
                            size: 23,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.deleteHabitConfirmBody,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: .35),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6675),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 19,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  l10n.delete,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  tooltip: l10n.cancel,
                  onPressed: () => Navigator.pop(context, false),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F1F8),
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
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

  static const _allEmojis = [
    '💧',
    '🥤',
    '☕',
    '🍵',
    '🥛',
    '🍎',
    '🍊',
    '🍋',
    '🥑',
    '🥗',
    '🥦',
    '🍽️',
    '💊',
    '🪥',
    '🧴',
    '🩺',
    '❤️',
    '💜',
    '🧠',
    '🧘',
    '🌿',
    '🌱',
    '🌻',
    '☀️',
    '🌙',
    '⭐',
    '✨',
    '🔥',
    '💪',
    '🏋️',
    '🏃',
    '🚶',
    '🚴',
    '🏊',
    '⚽',
    '🏀',
    '🎾',
    '🧗',
    '👟',
    '😴',
    '🛏️',
    '⏰',
    '📖',
    '📚',
    '✍️',
    '📝',
    '🎓',
    '💻',
    '🎨',
    '🎸',
    '🎹',
    '🎧',
    '💬',
    '📵',
    '🧹',
    '🧺',
    '🏠',
    '💰',
    '📅',
    '✅',
    '🎯',
    '🏆',
    '🐶',
    '🐱',
    '🐾',
    '🌍',
    '✈️',
    '🙏',
    '😊',
    '🫶',
    '🍓',
    '🍇',
    '🍉',
    '🍌',
    '🍒',
    '🥝',
    '🥕',
    '🌽',
    '🥒',
    '🍅',
    '🥚',
    '🐟',
    '🍗',
    '🍚',
    '🍞',
    '🥣',
    '🫗',
    '🧃',
    '🚰',
    '🫖',
    '🧼',
    '🚿',
    '🛁',
    '🧽',
    '🧖',
    '🦷',
    '👁️',
    '👂',
    '🫁',
    '🫀',
    '🩹',
    '🌡️',
    '⚕️',
    '🧬',
    '🧍',
    '🤸',
    '⛹️',
    '🤾',
    '🏌️',
    '🏄',
    '🚣',
    '⛷️',
    '🏂',
    '🛹',
    '🛼',
    '🥊',
    '🥋',
    '🏓',
    '🏸',
    '🏐',
    '🏉',
    '⚾',
    '🥎',
    '🏹',
    '🎣',
    '♟️',
    '🧩',
    '🎲',
    '🎮',
    '🕹️',
    '📓',
    '📔',
    '📕',
    '📗',
    '📘',
    '📙',
    '📑',
    '🔖',
    '🖊️',
    '🖍️',
    '📐',
    '🔬',
    '🔭',
    '🧮',
    '🗣️',
    '🔤',
    '💡',
    '🧑‍💻',
    '📊',
    '📈',
    '📋',
    '📌',
    '📧',
    '☎️',
    '⌛',
    '⏱️',
    '🗓️',
    '🗂️',
    '🔑',
    '🛒',
    '🧾',
    '🎁',
    '🪴',
    '🌳',
    '🌲',
    '🌵',
    '🍀',
    '🌷',
    '🌹',
    '🪻',
    '🍂',
    '♻️',
    '🐕',
    '🐈',
    '🐇',
    '🐦',
    '🐠',
    '🐢',
    '🐴',
    '🦋',
    '🐝',
    '🚗',
    '🚌',
    '🚆',
    '🚇',
    '🚲',
    '🛴',
    '🗺️',
    '🧳',
    '🏕️',
    '🏖️',
    '⛰️',
    '🌅',
    '📷',
    '🎬',
    '🎤',
    '🎻',
    '🥁',
    '🪡',
    '🧶',
    '🔨',
    '🪛',
    '🕯️',
    '🧘‍♀️',
    '🧘‍♂️',
    '🤍',
    '💚',
    '💙',
    '🧡',
    '💛',
    '💖',
    '🌈',
    '☁️',
    '🌊',
    '🎉',
    '🚀',
    '🔔',
    '🔕',
    '🛑',
    '➕',
    '➖',
  ];

  Widget _item(String emoji, {VoidCallback? onTap}) => Semantics(
    button: true,
    selected: emoji == selected,
    label: emoji,
    child: InkWell(
      key: ValueKey('habit-emoji-$emoji'),
      onTap: onTap ?? () => onSelected(emoji),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: emoji == selected
              ? AppColors.primary.withValues(alpha: .14)
              : Colors.black.withValues(alpha: .035),
          borderRadius: BorderRadius.circular(14),
          border: emoji == selected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    ),
  );

  Future<void> _showAll(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .62,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Text(
                  context.l10n.habitEmojiLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _allEmojis.length,
                  itemBuilder: (_, index) {
                    final emoji = _allEmojis[index];
                    return _item(
                      emoji,
                      onTap: () => Navigator.pop(sheetContext, emoji),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final emoji in emojis) _item(emoji)],
      ),
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: () => _showAll(context),
        icon: const Icon(Icons.add_reaction_outlined),
        label: Text(context.l10n.seeAll),
      ),
    ],
  );
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
