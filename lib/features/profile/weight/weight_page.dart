import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/app_notice.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:habits/features/profile/weight/weight_entry.dart';
import 'package:habits/features/profile/weight/weight_onboarding_dialog.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';
import 'package:habits/features/profile/weight/weight_providers.dart';
import 'package:habits/legal_links.dart';
import 'package:habits/local_preferences.dart';
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
      useSafeArea: false,
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

  Future<void> _resetWeightData() async {
    if (_saving) return;
    final userId = ref.read(authRepositoryProvider).currentUser?.id;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: context.palette.scrim,
      builder: (_) => const _ResetWeightDataDialog(),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref.read(weightRepositoryProvider).resetAllData();
      if (userId != null) {
        await ref
            .read(sharedPreferencesProvider)
            ?.remove(weightInvitationHiddenKey(userId));
      }
      ref.read(weightInvitationSessionProvider).reset();
      if (!mounted) return;
      AppNotice.show(
        context,
        message: context.l10n.weightDataDeleted,
        type: AppNoticeType.success,
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppNotice.show(
        context,
        message: context.l10n.errorSaveFailed,
        type: AppNoticeType.error,
      );
    }
  }

  Future<bool> _askHealthConsent() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: context.palette.scrim,
      builder: (context) => const _WeightConsentDialog(),
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
      useSafeArea: false,
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
    final previous = entries.length > 1 ? entries[1].kilograms : null;
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _WeightHeroCard(
                  initial: initial,
                  previous: previous,
                  current: current,
                  goal: goal,
                  format: _weight,
                ),
                const SizedBox(height: 26),
                _ChartCard(
                  entries: chartEntries,
                  goal: goal,
                  format: _weight,
                  range: _range,
                  onRangeSelected: (value) => setState(() => _range = value),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _WeightMetricCard(
                        key: const ValueKey('weight-edit-goals'),
                        icon: PhosphorIconsBold.target,
                        color: AppColors.lilac,
                        label: context.l10n.weightGoal,
                        value: goal == null ? '—' : '${_weight(goal)} kg',
                        detail: current == null || goal == null
                            ? null
                            : '${context.l10n.weightRemaining} ${_weight((current - goal).abs())} kg',
                        onTap: () => _editObjectives(profile, current),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _WeightMetricCard(
                        key: const ValueKey('weight-calories-card'),
                        icon: PhosphorIconsFill.fire,
                        color: AppColors.pink,
                        label: context.l10n.weightDailyCaloriesTitle,
                        value: profile?.recommendedCalories == null
                            ? '—'
                            : NumberFormat.decimalPattern(
                                Localizations.localeOf(context).languageCode,
                              ).format(profile!.recommendedCalories),
                        detail: profile?.recommendedCalories == null
                            ? null
                            : context.l10n.weightForYourGoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const ValueKey('weight-modify-goals'),
                    onPressed: () => _editObjectives(profile, current),
                    icon: const Icon(PhosphorIconsBold.pencilSimple, size: 17),
                    label: Text(context.l10n.weightModifyGoals),
                  ),
                ),
                const SizedBox(height: 24),
                _HistoryCard(
                  entries: _showAllHistory ? entries : entries.take(3).toList(),
                  allEntries: entries,
                  format: _weight,
                  onDelete: _deleteEntry,
                  showViewAll: entries.length > 3 && !_showAllHistory,
                  onViewAll: () => setState(() => _showAllHistory = true),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('register-weight'),
                    onPressed: _saving ? null : () => _addMeasurement(current),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
                        : const Icon(PhosphorIconsBold.plusCircle),
                    label: Text(
                      context.l10n.weightRegister,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  key: const ValueKey('reset-weight-data'),
                  onPressed: _saving ? null : _resetWeightData,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF5A67),
                  ),
                  icon: const Icon(PhosphorIconsBold.trash, size: 18),
                  label: Text(
                    context.l10n.weightResetData,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WeightConsentDialog extends StatelessWidget {
  const _WeightConsentDialog();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return Dialog(
      key: const ValueKey('weight-consent-dialog'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: palette.dialogSurface,
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/cat.png',
                      width: 148,
                      height: 104,
                      fit: BoxFit.contain,
                      semanticLabel: l10n.weightConsentCatLabel,
                    ),
                    Positioned(
                      right: -4,
                      bottom: 4,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: palette.primarySoft,
                          shape: BoxShape.circle,
                          border: Border.all(color: palette.surface, width: 3),
                        ),
                        child: Icon(
                          PhosphorIconsBold.shieldCheck,
                          color: palette.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.weightConsentTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsBold.lockKey,
                        color: palette.primary,
                        size: 21,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          l10n.weightConsentBody,
                          style: TextStyle(
                            color: palette.isDark
                                ? palette.textPrimary.withValues(alpha: .84)
                                : palette.textSecondary,
                            height: 1.42,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      openExternalLink(context, LegalLinks.privacyPolicy),
                  icon: const Icon(PhosphorIconsBold.arrowSquareOut, size: 17),
                  label: Text(l10n.weightConsentPrivacy),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    key: const ValueKey('weight-consent-accept'),
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(PhosphorIconsBold.checkCircle),
                    label: Text(l10n.weightConsentAccept),
                    style: FilledButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  key: const ValueKey('weight-consent-decline'),
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: palette.textSecondary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                  child: Text(l10n.weightConsentDecline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetWeightDataDialog extends StatelessWidget {
  const _ResetWeightDataDialog();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    const danger = Color(0xFFFF5A67);
    return Dialog(
      key: const ValueKey('reset-weight-data-dialog'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          color: palette.dialogSurface,
          borderRadius: BorderRadius.circular(30),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/gatotriste.png',
                  width: 142,
                  height: 116,
                  fit: BoxFit.contain,
                  semanticLabel: l10n.sadCatImageLabel,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.weightResetTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.weightResetBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.isDark
                        ? palette.textPrimary.withValues(alpha: .82)
                        : palette.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    key: const ValueKey('confirm-reset-weight-data'),
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: danger,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: danger.withValues(alpha: .45),
                      disabledForegroundColor: Colors.white70,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const Icon(PhosphorIconsBold.trash),
                    label: Text(l10n.weightResetConfirm),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: palette.isDark
                        ? palette.primaryDeep
                        : palette.primary,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
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

class _WeightHeroCard extends StatelessWidget {
  const _WeightHeroCard({
    required this.initial,
    required this.previous,
    required this.current,
    required this.goal,
    required this.format,
  });

  final double? initial;
  final double? previous;
  final double? current;
  final double? goal;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final delta = current == null || previous == null
        ? null
        : current! - previous!;
    final remaining = current == null || goal == null
        ? null
        : (current! - goal!).abs();
    final total = initial == null || goal == null
        ? null
        : (initial! - goal!).abs();
    final progress = total == null || total == 0 || remaining == null
        ? 0.0
        : (1 - remaining / total).clamp(0.0, 1.0);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.tint(palette.primary, .06),
            palette.tint(AppColors.pink, .06),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.weightEncouragementTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.weightEncouragementBody,
                        style: TextStyle(
                          color: palette.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/gatogym.png',
                  width: 142,
                  height: 116,
                  fit: BoxFit.contain,
                  semanticLabel: context.l10n.gymCatImageLabel,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: palette.isDark ? 1 : .9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _HeroWeightValue(
                    label: context.l10n.weightCurrent,
                    value: current == null ? '—' : '${format(current!)} kg',
                    detail: delta == null
                        ? null
                        : '${delta <= 0 ? '↓' : '↑'} ${format(delta.abs())} kg ${context.l10n.weightSinceLast}',
                    detailColor: delta != null && delta <= 0
                        ? AppColors.green
                        : AppColors.orange,
                  ),
                ),
                Container(
                  width: 1,
                  height: 82,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: palette.divider,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroWeightValue(
                        label: context.l10n.weightGoal,
                        value: goal == null ? '—' : '${format(goal!)} kg',
                        detail: remaining == null
                            ? null
                            : '${context.l10n.weightRemaining} ${format(remaining)} kg',
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: progress,
                          backgroundColor: palette.primary.withValues(
                            alpha: .12,
                          ),
                          color: palette.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroWeightValue extends StatelessWidget {
  const _HeroWeightValue({
    required this.label,
    required this.value,
    this.detail,
    this.detailColor,
  });

  final String label;
  final String value;
  final String? detail;
  final Color? detailColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: palette.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 4),
          Text(
            detail!,
            style: TextStyle(
              color: detailColor ?? palette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _WeightMetricCard extends StatelessWidget {
  const _WeightMetricCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.detail,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface.withValues(alpha: palette.isDark ? 1 : .9),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 128),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.tint(color, .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        detail!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  PhosphorIconsBold.caretRight,
                  color: palette.textSecondary,
                  size: 17,
                ),
            ],
          ),
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
    required this.range,
    required this.onRangeSelected,
  });
  final List<WeightEntry> entries;
  final double? goal;
  final String Function(double) format;
  final _WeightRange range;
  final ValueChanged<_WeightRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final chronological = entries.take(12).toList().reversed.toList();
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
      decoration: _surfaceDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.weightEvolution,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.weightEvolutionSubtitle,
                      style: TextStyle(color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
              _RangeSelector(selected: range, onSelected: onRangeSelected),
            ],
          ),
          const SizedBox(height: 14),
          if (entries.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: _EmptyBlock(
                icon: PhosphorIconsBold.chartLine,
                text: context.l10n.weightChartEmpty,
              ),
            )
          else
            SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _WeightChartPainter(
                  palette: palette,
                  entries: chronological,
                  goal: goal,
                  goalLabel: goal == null
                      ? null
                      : context.l10n.weightGoalLabel(format(goal!)),
                  firstDate: DateFormat(
                    'd MMM',
                    locale,
                  ).format(chronological.first.recordedAt),
                  lastDate: DateFormat(
                    'd MMM',
                    locale,
                  ).format(chronological.last.recordedAt),
                  currentLabel: '${format(chronological.last.kilograms)} kg',
                  todayLabel: context.l10n.weightToday,
                ),
                child: const SizedBox.expand(),
              ),
            ),
        ],
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
    required this.currentLabel,
    required this.todayLabel,
  });
  final AppPalette palette;
  final List<WeightEntry> entries;
  final double? goal;
  final String? goalLabel;
  final String firstDate;
  final String lastDate;
  final String currentLabel;
  final String todayLabel;

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
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        final previous = points[i - 1];
        final middleX = (previous.dx + point.dx) / 2;
        path.cubicTo(
          middleX,
          previous.dy,
          middleX,
          point.dy,
          point.dx,
          point.dy,
        );
      }
    }
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, plot.bottom)
      ..lineTo(points.first.dx, plot.bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader =
            ui.Gradient.linear(Offset(0, plot.top), Offset(0, plot.bottom), [
              palette.primary.withValues(alpha: .22),
              palette.primary.withValues(alpha: .02),
            ]),
    );
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
    final lastPoint = points.last;
    final bubbleText = '$currentLabel\n$todayLabel';
    final bubblePainter = TextPainter(
      text: TextSpan(
        text: bubbleText,
        style: TextStyle(
          color: palette.onPrimary,
          fontSize: 11,
          height: 1.2,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final bubbleWidth = bubblePainter.width + 18;
    final bubbleHeight = bubblePainter.height + 12;
    final bubbleLeft = (lastPoint.dx - bubbleWidth / 2).clamp(
      plot.left,
      plot.right - bubbleWidth,
    );
    final bubbleTop = math.max(plot.top, lastPoint.dy - bubbleHeight - 15);
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleLeft, bubbleTop, bubbleWidth, bubbleHeight),
      const Radius.circular(9),
    );
    canvas.drawRRect(bubbleRect, Paint()..color = palette.primary);
    bubblePainter.paint(
      canvas,
      Offset(
        bubbleLeft + (bubbleWidth - bubblePainter.width) / 2,
        bubbleTop + 6,
      ),
    );
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
      oldDelegate.lastDate != lastDate ||
      oldDelegate.currentLabel != currentLabel ||
      oldDelegate.todayLabel != todayLabel;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entries,
    required this.allEntries,
    required this.format,
    required this.onDelete,
    required this.showViewAll,
    required this.onViewAll,
  });
  final List<WeightEntry> entries;
  final List<WeightEntry> allEntries;
  final String Function(double) format;
  final ValueChanged<WeightEntry> onDelete;
  final bool showViewAll;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _EmptyBlock(
        icon: PhosphorIconsBold.scales,
        text: context.l10n.weightHistoryEmpty,
      );
    }
    final palette = context.palette;
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 10, 6),
      decoration: _surfaceDecoration(palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.weightHistory,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              if (showViewAll)
                TextButton.icon(
                  onPressed: onViewAll,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(PhosphorIconsBold.caretRight, size: 16),
                  label: Text(context.l10n.weightViewAll),
                ),
            ],
          ),
          for (var index = 0; index < entries.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _historyDate(
                            entries[index].recordedAt,
                            now,
                            locale,
                            context.l10n.weightToday,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat.Hm(
                            locale,
                          ).format(entries[index].recordedAt),
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${format(entries[index].kilograms)} kg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (_deltaFor(entries[index]) case final delta?) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: (delta <= 0 ? AppColors.green : AppColors.orange)
                            .withValues(alpha: .11),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${delta <= 0 ? '↓' : '↑'} ${delta > 0 ? '+' : ''}${format(delta)} kg',
                        style: TextStyle(
                          color: delta <= 0
                              ? AppColors.green
                              : AppColors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  PopupMenuButton<String>(
                    key: ValueKey('delete-weight-${entries[index].id}'),
                    tooltip: context.l10n.weightDeleteEntry,
                    icon: Icon(
                      PhosphorIconsBold.dotsThreeVertical,
                      color: palette.textSecondary,
                      size: 20,
                    ),
                    onSelected: (_) => onDelete(entries[index]),
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              PhosphorIconsBold.trash,
                              color: AppColors.pink,
                              size: 19,
                            ),
                            const SizedBox(width: 9),
                            Text(context.l10n.delete),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (index != entries.length - 1)
              Divider(height: 1, color: palette.divider),
          ],
        ],
      ),
    );
  }

  double? _deltaFor(WeightEntry entry) {
    final index = allEntries.indexWhere(
      (candidate) => candidate.id == entry.id,
    );
    if (index < 0 || index >= allEntries.length - 1) return null;
    return entry.kilograms - allEntries[index + 1].kilograms;
  }

  String _historyDate(
    DateTime date,
    DateTime now,
    String locale,
    String today,
  ) {
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final formatted = DateFormat('d MMMM', locale).format(date);
    return isToday ? '$today, $formatted' : formatted;
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
