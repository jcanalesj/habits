import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/legal_links.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_onboarding_dialog.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';
import 'package:habits/features/profile/weight/weight_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

enum _WeightRange {
  week('1S', 7),
  month('1M', 30),
  quarter('3M', 90),
  year('1A', 365);

  const _WeightRange(this.label, this.days);
  final String label;
  final int days;

  List<WeightEntry> filter(List<WeightEntry> entries) {
    if (entries.isEmpty) return entries;
    final limit = entries.first.recordedAt.subtract(Duration(days: days));
    return entries.where((entry) => !entry.recordedAt.isBefore(limit)).toList();
  }
}

class WeightPage extends ConsumerStatefulWidget {
  const WeightPage({super.key});

  @override
  ConsumerState<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends ConsumerState<WeightPage> {
  bool _saving = false;
  bool _onboardingPrompted = false;
  _WeightRange _range = _WeightRange.month;
  bool _showAllHistory = false;

  String _weight(double value) {
    final digits = value == value.roundToDouble() ? 0 : 1;
    return value.toStringAsFixed(digits);
  }

  Future<double?> _askWeight({double? initial, required bool goal}) async {
    return showDialog<double>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (context) => _WeightInputDialog(
        initialValue: initial == null ? '' : _weight(initial),
        goal: goal,
      ),
    );
  }

  Future<void> _addMeasurement(double? current) async {
    final value = await _askWeight(initial: current, goal: false);
    if (value == null) return;
    await _save(
      () => ref.read(weightRepositoryProvider).addEntry(value, DateTime.now()),
    );
  }

  Future<void> _editObjectives(WeightProfile? profile, double? current) async {
    final initialProfile = profile == null || current == null
        ? profile
        : WeightProfile(
            currentKg: current,
            goalKg: profile.goalKg,
            age: profile.age,
            heightCm: profile.heightCm,
            sex: profile.sex,
            activityLevel: profile.activityLevel,
            goalType: profile.goalType,
            recommendedCalories: profile.recommendedCalories,
          );
    final updated = await showDialog<WeightProfile>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          WeightOnboardingDialog(initialProfile: initialProfile),
    );
    if (updated == null || !mounted) return;
    await _save(() => ref.read(weightRepositoryProvider).saveProfile(updated));
  }

  Future<void> _save(Future<void> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await action();
      if (mounted) {
        AppNotice.show(
          context,
          message: context.l10n.weightSaved,
          type: AppNoticeType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppNotice.show(
          context,
          message: context.l10n.errorSaveFailed,
          type: AppNoticeType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteEntry(WeightEntry entry) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (context) => AlertDialog(
        title: Text(l10n.weightDeleteConfirmTitle),
        content: Text(l10n.weightDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: const ValueKey('confirm-delete-weight'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(weightRepositoryProvider).deleteEntry(entry.id);
      if (!mounted) return;
      AppNotice.show(context, message: l10n.weightEntryDeleted);
    } catch (_) {
      if (!mounted) return;
      AppNotice.show(
        context,
        message: l10n.errorSaveFailed,
        type: AppNoticeType.error,
      );
    }
  }

  Future<bool> _askHealthConsent() async {
    final l10n = context.l10n;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: context.palette.scrim,
      builder: (context) => AlertDialog(
        key: const ValueKey('weight-consent-dialog'),
        title: Text(l10n.weightConsentTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.weightConsentBody),
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () =>
                  openExternalLink(context, LegalLinks.privacyPolicy),
              child: Text(l10n.weightConsentPrivacy),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const ValueKey('weight-consent-decline'),
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.weightConsentDecline),
          ),
          FilledButton(
            key: const ValueKey('weight-consent-accept'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.weightConsentAccept),
          ),
        ],
      ),
    );
    return accepted ?? false;
  }

  Future<void> _showOnboarding() async {
    if (_onboardingPrompted || !mounted) return;
    _onboardingPrompted = true;
    // Datos de salud (RGPD art. 9): consentimiento explícito antes de
    // pedir nada. Sin él no se guarda ningún dato y se sale de la sección.
    final consented = await _askHealthConsent();
    if (!mounted) return;
    if (!consented) {
      Navigator.of(context).maybePop();
      return;
    }
    final profile = await showDialog<WeightProfile>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WeightOnboardingDialog(),
    );
    if (profile == null || !mounted) return;
    await _save(
      () => ref
          .read(weightRepositoryProvider)
          .completeOnboarding(profile, DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(weightEntriesProvider);
    final goalAsync = ref.watch(weightGoalProvider);
    final profileAsync = ref.watch(weightProfileProvider);
    final goal = goalAsync.value;
    final entries = entriesAsync.value ?? const <WeightEntry>[];
    final current = entries.firstOrNull?.kilograms;
    final initial = entries.lastOrNull?.kilograms;
    final initialDate = entries.lastOrNull?.recordedAt;
    final profile = profileAsync.value;
    final chartEntries = _range.filter(entries);
    final loadError =
        entriesAsync.error ?? goalAsync.error ?? profileAsync.error;
    final loading =
        (entriesAsync.isLoading && !entriesAsync.hasValue) ||
        (goalAsync.isLoading && !goalAsync.hasValue) ||
        (profileAsync.isLoading && !profileAsync.hasValue);

    if (!loading &&
        loadError == null &&
        entries.isEmpty &&
        profileAsync.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboarding());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          context.l10n.weightTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: loadError != null
          ? _WeightLoadError(
              onRetry: () {
                ref.invalidate(weightEntriesProvider);
                ref.invalidate(weightGoalProvider);
                ref.invalidate(weightProfileProvider);
              },
            )
          : loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              children: [
                _WeightGoalBanner(
                  goal: goal,
                  format: _weight,
                  onEdit: () => _editObjectives(profile, current),
                ),
                const SizedBox(height: 14),
                _WeightSummary(
                  initial: initial,
                  initialDate: initialDate,
                  current: current,
                  goal: goal,
                  calories: profile?.recommendedCalories,
                  format: _weight,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : () => _addMeasurement(current),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: _saving
                        ? SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              color: context.palette.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(PhosphorIconsBold.plus),
                    label: Text(context.l10n.weightRegister),
                  ),
                ),
                const SizedBox(height: 26),
                _SectionHeader(
                  title: context.l10n.weightEvolution,
                  trailing: _RangeSelector(
                    selected: _range,
                    onSelected: (value) => setState(() => _range = value),
                  ),
                ),
                const SizedBox(height: 10),
                _ChartCard(entries: chartEntries, goal: goal, format: _weight),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: context.l10n.weightHistory,
                  action: entries.length > 3 && !_showAllHistory
                      ? context.l10n.weightViewAll
                      : null,
                  onAction: () => setState(() => _showAllHistory = true),
                ),
                const SizedBox(height: 10),
                _HistoryCard(
                  entries: _showAllHistory ? entries : entries.take(3).toList(),
                  format: _weight,
                  onDelete: _deleteEntry,
                ),
              ],
            ),
    );
  }
}

class _WeightLoadError extends StatelessWidget {
  const _WeightLoadError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            PhosphorIconsBold.cloudSlash,
            color: AppColors.lilac,
            size: 48,
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.weightLoadError,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.palette.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(PhosphorIconsBold.arrowClockwise),
            label: Text(context.l10n.weightRetry),
          ),
        ],
      ),
    ),
  );
}

class _WeightInputDialog extends StatefulWidget {
  const _WeightInputDialog({required this.initialValue, required this.goal});
  final String initialValue;
  final bool goal;

  @override
  State<_WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends State<_WeightInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _value =>
      double.tryParse(_controller.text.trim().replaceAll(',', '.'));
  bool get _valid => _value != null && _value! >= 20 && _value! <= 400;

  void _adjust(double amount) {
    final next = ((_value ?? 70) + amount).clamp(20, 400).toDouble();
    _controller.text = next.toStringAsFixed(1);
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    HapticFeedback.selectionClick();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: palette.dialogSurface,
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: palette.tint(AppColors.blue),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: const Icon(
                        PhosphorIconsFill.scales,
                        color: AppColors.blue,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.goal
                          ? l10n.weightGoalDialog
                          : l10n.weightLogDialog,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      widget.goal
                          ? l10n.weightGoalDialogHint
                          : l10n.weightLogDialogHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 108,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9,.]'),
                                ),
                              ],
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                              decoration: InputDecoration(
                                hintText: '70.0',
                                suffixText: 'kg',
                                suffixStyle: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                                filled: true,
                                fillColor: palette.inputFill,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: palette.primary.withValues(
                                      alpha: .22,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: palette.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 52,
                            child: Column(
                              children: [
                                Expanded(
                                  child: _WeightStepperButton(
                                    icon: PhosphorIconsBold.caretUp,
                                    onPressed: () => _adjust(.1),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: _WeightStepperButton(
                                    icon: PhosphorIconsBold.caretDown,
                                    onPressed: () => _adjust(-.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.weightValidRange,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _valid
                                ? () => Navigator.pop(context, _value)
                                : null,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(l10n.profileSave),
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
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: palette.surfaceMuted,
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

class _WeightStepperButton extends StatelessWidget {
  const _WeightStepperButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.tint(palette.primary, .07),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Center(child: Icon(icon, color: palette.textPrimary, size: 22)),
      ),
    );
  }
}

class _WeightGoalBanner extends StatelessWidget {
  const _WeightGoalBanner({
    required this.goal,
    required this.format,
    required this.onEdit,
  });
  final double? goal;
  final String Function(double) format;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.tint(palette.primary, .07),
            palette.tint(AppColors.lilac),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: palette.surface.withValues(
                alpha: palette.isDark ? 1 : .88,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              PhosphorIconsBold.target,
              color: palette.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.weightPlanTitle,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  goal == null ? '—' : '${format(goal!)} kg',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              backgroundColor: palette.surface.withValues(
                alpha: palette.isDark ? 1 : .72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            ),
            icon: const Icon(PhosphorIconsFill.pencilSimple, size: 18),
            label: Text(context.l10n.weightModifyGoals),
          ),
        ],
      ),
    );
  }
}

class _WeightSummary extends StatelessWidget {
  const _WeightSummary({
    required this.initial,
    required this.initialDate,
    required this.current,
    required this.goal,
    required this.calories,
    required this.format,
  });

  final double? initial;
  final DateTime? initialDate;
  final double? current;
  final double? goal;
  final int? calories;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      decoration: _surfaceDecoration(palette),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _SummaryValue(
                  value: initial,
                  label: context.l10n.weightInitial,
                  detail: initialDate == null
                      ? null
                      : DateFormat.yMMMd(
                          Localizations.localeOf(context).languageCode,
                        ).format(initialDate!),
                  format: format,
                ),
                const VerticalDivider(width: 1),
                _SummaryValue(
                  value: current,
                  label: context.l10n.weightCurrent,
                  highlighted: true,
                  detail: current == null || initial == null
                      ? null
                      : '${current! >= initial! ? '↗' : '↘'} ${current! >= initial! ? '+' : ''}${format(current! - initial!)} kg\n${context.l10n.weightSinceStart}',
                  format: format,
                ),
                const VerticalDivider(width: 1),
                _SummaryValue(
                  value: goal,
                  label: context.l10n.weightGoal,
                  detail: current == null || goal == null
                      ? null
                      : '${format((current! - goal!).abs())} kg\n${context.l10n.weightToGoal}',
                  format: format,
                ),
              ],
            ),
          ),
          if (calories != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: palette.tint(palette.primary, .07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsFill.lightning,
                    size: 21,
                    color: palette.primary,
                  ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      context.l10n.weightDailyCalories(calories!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.primary,
                        fontSize: 17,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.value,
    required this.label,
    required this.format,
    this.detail,
    this.highlighted = false,
  });
  final double? value;
  final String label;
  final String Function(double) format;
  final String? detail;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: highlighted
            ? BoxDecoration(
                color: palette.tint(palette.primary, .06),
                borderRadius: BorderRadius.circular(18),
              )
            : null,
        child: Column(
          children: [
            Text(
              value == null ? '—' : '${format(value!)} kg',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
            if (detail != null) ...[
              const SizedBox(height: 4),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: highlighted ? palette.primary : palette.textSecondary,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.entries,
    required this.goal,
    required this.format,
  });
  final List<WeightEntry> entries;
  final double? goal;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return _EmptyBlock(
        icon: PhosphorIconsBold.chartLine,
        text: context.l10n.weightChartEmpty,
      );
    }
    final palette = context.palette;
    final chronological = entries.take(12).toList().reversed.toList();
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(10, 18, 10, 10),
      decoration: _surfaceDecoration(palette),
      child: CustomPaint(
        painter: _WeightChartPainter(
          palette: palette,
          entries: chronological,
          goal: goal,
          goalLabel: goal == null
              ? null
              : context.l10n.weightGoalLabel(format(goal!)),
          firstDate: DateFormat(
            'dd/MM',
            locale,
          ).format(chronological.first.recordedAt),
          lastDate: DateFormat(
            'dd/MM',
            locale,
          ).format(chronological.last.recordedAt),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter({
    required this.palette,
    required this.entries,
    required this.goal,
    required this.goalLabel,
    required this.firstDate,
    required this.lastDate,
  });
  final AppPalette palette;
  final List<WeightEntry> entries;
  final double? goal;
  final String? goalLabel;
  final String firstDate;
  final String lastDate;

  @override
  void paint(Canvas canvas, Size size) {
    final values = entries.map((entry) => entry.kilograms).toList();
    if (goal case final value?) values.add(value);
    var minValue = values.reduce(math.min);
    var maxValue = values.reduce(math.max);
    if ((maxValue - minValue).abs() < 1) {
      minValue -= 1;
      maxValue += 1;
    } else {
      minValue -= .6;
      maxValue += .6;
    }
    final plot = Rect.fromLTRB(36, 8, size.width - 8, size.height - 25);
    double y(double value) =>
        plot.bottom -
        ((value - minValue) / (maxValue - minValue)) * plot.height;

    final grid = Paint()
      ..color = palette.primary.withValues(alpha: .09)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final lineY = plot.top + plot.height * i / 3;
      canvas.drawLine(
        Offset(plot.left, lineY),
        Offset(plot.right, lineY),
        grid,
      );
      _paintLabel(
        canvas,
        (maxValue - (maxValue - minValue) * i / 3).toStringAsFixed(0),
        Offset(0, lineY - 7),
      );
    }
    if (goal case final value?) {
      final goalPaint = Paint()
        ..color = AppColors.green.withValues(alpha: .65)
        ..strokeWidth = 1.5;
      final goalY = y(value);
      for (double x = plot.left; x < plot.right; x += 9) {
        canvas.drawLine(
          Offset(x, goalY),
          Offset(math.min(x + 5, plot.right), goalY),
          goalPaint,
        );
      }
      final label = _labelPainter(goalLabel!, color: AppColors.green);
      label.paint(canvas, Offset(plot.right - label.width, goalY - 17));
    }
    final path = Path();
    final points = <Offset>[];
    for (var i = 0; i < entries.length; i++) {
      final x = entries.length == 1
          ? 0.0
          : plot.left + plot.width * i / (entries.length - 1);
      final point = Offset(x, y(entries[i].kilograms));
      points.add(point);
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = palette.primary
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = palette.surface);
      canvas.drawCircle(point, 3.5, Paint()..color = palette.primary);
    }
    _paintLabel(canvas, firstDate, Offset(plot.left, plot.bottom + 7));
    final lastPainter = _labelPainter(lastDate);
    lastPainter.paint(
      canvas,
      Offset(plot.right - lastPainter.width, plot.bottom + 7),
    );
  }

  TextPainter _labelPainter(String text, {Color? color}) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color ?? palette.textSecondary, fontSize: 10),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();

  void _paintLabel(Canvas canvas, String text, Offset offset, {Color? color}) {
    _labelPainter(text, color: color).paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      oldDelegate.palette != palette ||
      oldDelegate.entries != entries ||
      oldDelegate.goal != goal ||
      oldDelegate.goalLabel != goalLabel ||
      oldDelegate.firstDate != firstDate ||
      oldDelegate.lastDate != lastDate;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entries,
    required this.format,
    required this.onDelete,
  });
  final List<WeightEntry> entries;
  final String Function(double) format;
  final ValueChanged<WeightEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _EmptyBlock(
        icon: PhosphorIconsBold.scales,
        text: context.l10n.weightHistoryEmpty,
      );
    }
    final palette = context.palette;
    return Container(
      decoration: _surfaceDecoration(palette),
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.tint(AppColors.blue, .11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  PhosphorIconsBold.scales,
                  color: AppColors.blue,
                ),
              ),
              title: Text(
                '${format(entries[index].kilograms)} kg',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                DateFormat.yMMMd(
                  Localizations.localeOf(context).languageCode,
                ).format(entries[index].recordedAt),
              ),
              trailing: IconButton(
                key: ValueKey('delete-weight-${entries[index].id}'),
                tooltip: context.l10n.weightDeleteEntry,
                icon: Icon(
                  PhosphorIconsBold.trash,
                  color: palette.textSecondary,
                  size: 20,
                ),
                onPressed: () => onDelete(entries[index]),
              ),
            ),
            if (index != entries.length - 1)
              const Divider(height: 1, indent: 72),
          ],
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: _surfaceDecoration(palette),
      child: Column(
        children: [
          Icon(icon, color: AppColors.lilac, size: 38),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
    this.trailing,
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
      ?trailing,
    ],
  );
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onSelected});
  final _WeightRange selected;
  final ValueChanged<_WeightRange> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.tint(palette.primary, .06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final range in _WeightRange.values)
            InkWell(
              onTap: () => onSelected(range),
              borderRadius: BorderRadius.circular(15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: range == selected
                      ? palette.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  range.label,
                  style: TextStyle(
                    color: range == selected
                        ? palette.onPrimary
                        : palette.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

BoxDecoration _surfaceDecoration(AppPalette palette) => BoxDecoration(
  color: palette.surface.withValues(alpha: palette.isDark ? 1 : .86),
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: palette.border),
);
