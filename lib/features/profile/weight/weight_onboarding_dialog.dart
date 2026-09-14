import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class WeightOnboardingDialog extends StatefulWidget {
  const WeightOnboardingDialog({super.key, this.initialProfile});

  final WeightProfile? initialProfile;

  @override
  State<WeightOnboardingDialog> createState() => _WeightOnboardingDialogState();
}

class _WeightOnboardingDialogState extends State<WeightOnboardingDialog> {
  final _pageController = PageController();
  final _currentController = TextEditingController();
  final _goalController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  var _step = 0;
  var _goalType = WeightGoalType.lose;
  var _sex = CalorieSex.unspecified;
  var _activity = ActivityLevel.moderate;

  static const _lastStep = 6;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    if (profile == null) return;
    _currentController.text = _format(profile.currentKg);
    _goalController.text = _format(profile.goalKg);
    _ageController.text = profile.age.toString();
    _heightController.text = _format(profile.heightCm);
    _goalType = profile.goalType;
    _sex = profile.sex;
    _activity = profile.activityLevel;
  }

  String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  double? _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));
  int? get _age => int.tryParse(_ageController.text.trim());
  double? get _current => _number(_currentController);
  double? get _goal => _number(_goalController);
  double? get _height => _number(_heightController);

  bool get _valid => switch (_step) {
    0 => true,
    1 => _current != null && _current! >= 20 && _current! <= 400,
    2 => _validGoal,
    3 =>
      _age != null &&
          _age! >= 18 &&
          _age! <= 100 &&
          _height != null &&
          _height! >= 120 &&
          _height! <= 230,
    _ => true,
  };

  bool get _validGoal {
    if (_goal == null || _goal! < 20 || _goal! > 400 || _current == null) {
      return false;
    }
    return switch (_goalType) {
      WeightGoalType.lose => _goal! < _current!,
      WeightGoalType.maintain => (_goal! - _current!).abs() <= 3,
      WeightGoalType.gain => _goal! > _current!,
    };
  }

  int get _calories => CalorieEstimator.estimate(
    weightKg: _current ?? 70,
    heightCm: _height ?? 170,
    age: _age ?? 30,
    sex: _sex,
    activity: _activity,
    goal: _goalType,
  );

  @override
  void dispose() {
    _pageController.dispose();
    _currentController.dispose();
    _goalController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _next() {
    if (!_valid) return;
    if (_step == _lastStep) {
      Navigator.pop(
        context,
        WeightProfile(
          currentKg: _current!,
          goalKg: _goal!,
          age: _age!,
          heightCm: _height!,
          sex: _sex,
          activityLevel: _activity,
          goalType: _goalType,
          recommendedCalories: _calories,
        ),
      );
      return;
    }
    setState(() => _step++);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog.fullscreen(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .72),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _step == 0 ? null : _back,
                    icon: const Icon(PhosphorIconsBold.caretLeft),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          l10n.weightOnboardingTitle,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.weightOnboardingStep(_step + 1, _lastStep + 1),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var index = 0; index <= _lastStep; index++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: index == _step ? 25 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: index <= _step
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(
                                          alpha: .14,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.cancel,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuestionStep(
                    icon: PhosphorIconsFill.target,
                    title: l10n.weightQuestionGoal,
                    body: l10n.weightQuestionGoalHint,
                    child: _OptionList<WeightGoalType>(
                      value: _goalType,
                      onChanged: (value) => setState(() => _goalType = value),
                      options: [
                        (WeightGoalType.lose, l10n.weightGoalLose, '📉'),
                        (
                          WeightGoalType.maintain,
                          l10n.weightGoalMaintain,
                          '⚖️',
                        ),
                        (WeightGoalType.gain, l10n.weightGoalGain, '📈'),
                      ],
                      descriptions: {
                        WeightGoalType.lose: l10n.weightGoalLoseHint,
                        WeightGoalType.maintain: l10n.weightGoalMaintainHint,
                        WeightGoalType.gain: l10n.weightGoalGainHint,
                      },
                    ),
                  ),
                  _QuestionStep(
                    icon: PhosphorIconsFill.scales,
                    title: l10n.weightQuestionCurrent,
                    body: l10n.weightQuestionCurrentHint,
                    child: _NumberField(
                      controller: _currentController,
                      label: l10n.weightCurrent,
                      suffix: 'kg',
                      hint: '70,0',
                      helper: l10n.weightRangeKg,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  _QuestionStep(
                    icon: PhosphorIconsFill.flag,
                    title: l10n.weightQuestionTarget,
                    body: l10n.weightQuestionTargetHint,
                    child: _NumberField(
                      controller: _goalController,
                      label: l10n.weightGoal,
                      suffix: 'kg',
                      hint: '65,0',
                      helper: _goal == null || _validGoal
                          ? l10n.weightTargetGoalHelper
                          : l10n.weightTargetGoalError,
                      error: _goal != null && !_validGoal,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  _QuestionStep(
                    icon: PhosphorIconsFill.identificationCard,
                    title: l10n.weightQuestionAboutYou,
                    body: l10n.weightQuestionAboutYouHint,
                    child: Row(
                      children: [
                        Expanded(
                          child: _NumberField(
                            controller: _ageController,
                            label: l10n.weightAge,
                            suffix: l10n.weightYears,
                            hint: '30',
                            helper: '18–100',
                            decimal: false,
                            onChanged: () => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumberField(
                            controller: _heightController,
                            label: l10n.weightHeight,
                            suffix: 'cm',
                            hint: '170',
                            helper: '120–230 cm',
                            decimal: false,
                            onChanged: () => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _QuestionStep(
                    icon: PhosphorIconsFill.user,
                    title: l10n.weightQuestionSex,
                    body: l10n.weightQuestionSexHint,
                    child: _OptionList<CalorieSex>(
                      value: _sex,
                      onChanged: (value) => setState(() => _sex = value),
                      options: [
                        (CalorieSex.female, l10n.weightSexFemale, '♀'),
                        (CalorieSex.male, l10n.weightSexMale, '♂'),
                        (
                          CalorieSex.unspecified,
                          l10n.weightSexUnspecified,
                          '○',
                        ),
                      ],
                      descriptions: {
                        CalorieSex.female: l10n.weightSexFemaleHint,
                        CalorieSex.male: l10n.weightSexMaleHint,
                        CalorieSex.unspecified: l10n.weightSexUnspecifiedHint,
                      },
                    ),
                  ),
                  _QuestionStep(
                    icon: PhosphorIconsFill.personSimpleRun,
                    title: l10n.weightQuestionActivity,
                    body: l10n.weightQuestionActivityHint,
                    child: _OptionList<ActivityLevel>(
                      value: _activity,
                      onChanged: (value) => setState(() => _activity = value),
                      compact: true,
                      options: [
                        (
                          ActivityLevel.sedentary,
                          l10n.weightActivitySedentary,
                          '🪑',
                        ),
                        (ActivityLevel.light, l10n.weightActivityLight, '🚶'),
                        (
                          ActivityLevel.moderate,
                          l10n.weightActivityModerate,
                          '🏃',
                        ),
                        (
                          ActivityLevel.active,
                          l10n.weightActivityActive,
                          '🏋️',
                        ),
                        (
                          ActivityLevel.veryActive,
                          l10n.weightActivityVeryActive,
                          '⚡',
                        ),
                      ],
                    ),
                  ),
                  _ResultStep(
                    calories: _calories,
                    current: _current ?? 0,
                    goal: _goal ?? 0,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('weight-onboarding-next'),
                  onPressed: _valid ? _next : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    _step == _lastStep ? l10n.weightStart : l10n.continueLabel,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionStep extends StatelessWidget {
  const _QuestionStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.child,
  });
  final IconData icon;
  final String title, body;
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 26, 24, 16),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE5FF),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Icon(icon, color: AppColors.primary, size: 34),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 9),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 22),
        child,
      ],
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.hint,
    required this.helper,
    required this.onChanged,
    this.decimal = true,
    this.error = false,
  });
  final TextEditingController controller;
  final String label, suffix, hint, helper;
  final VoidCallback onChanged;
  final bool decimal;
  final bool error;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(decimal ? r'[0-9,.]' : r'[0-9]'),
          ),
        ],
        onChanged: (_) => onChanged(),
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
        decoration: InputDecoration(
          hintText: hint,
          suffixText: suffix,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: error
                  ? Colors.redAccent
                  : AppColors.primary.withValues(alpha: .12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: error ? Colors.redAccent : AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
      const SizedBox(height: 7),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          helper,
          style: TextStyle(
            color: error ? Colors.redAccent : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: error ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    ],
  );
}

class _OptionList<T> extends StatelessWidget {
  const _OptionList({
    required this.value,
    required this.onChanged,
    required this.options,
    this.descriptions = const {},
    this.compact = false,
  });
  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, String, String)> options;
  final Map<T, String> descriptions;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final option in options)
        Padding(
          padding: EdgeInsets.only(bottom: compact ? 7 : 10),
          child: InkWell(
            onTap: () => onChanged(option.$1),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: compact ? 11 : 15,
              ),
              decoration: BoxDecoration(
                color: value == option.$1
                    ? AppColors.primary.withValues(alpha: .12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: value == option.$1 ? AppColors.primary : Colors.white,
                  width: 1.5,
                ),
                boxShadow: value == option.$1
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .10),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Text(option.$3, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.$2,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (descriptions[option.$1]
                            case final description?) ...[
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    value == option.$1
                        ? PhosphorIconsFill.checkCircle
                        : PhosphorIconsRegular.circle,
                    color: value == option.$1
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({
    required this.calories,
    required this.current,
    required this.goal,
  });
  final int calories;
  final double current;
  final double goal;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
    child: Column(
      children: [
        const Text('✨', style: TextStyle(fontSize: 68)),
        const SizedBox(height: 14),
        Text(
          context.l10n.weightResultTitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ResultMetric(
                label: context.l10n.weightCurrent,
                value: '${current.toStringAsFixed(1)} kg',
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                PhosphorIconsBold.arrowRight,
                color: AppColors.primary,
              ),
            ),
            Expanded(
              child: _ResultMetric(
                label: context.l10n.weightGoal,
                value: '${goal.toStringAsFixed(1)} kg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              Text(
                context.l10n.weightEstimatedCalories,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '$calories kcal',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 38,
                ),
              ),
              Text(
                context.l10n.weightPerDay,
                style: const TextStyle(color: Colors.white),
              ),
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
              const Icon(PhosphorIconsBold.info, color: AppColors.primary),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  context.l10n.weightMedicalDisclaimer,
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
    ),
  );
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}
