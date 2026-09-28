import 'package:flutter/material.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/finance/0_entity/entity.dart';
import 'package:habits/features/finance/2_presentation/widgets/finance_labels.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

Future<T?> _show<T>(BuildContext context, Widget dialog) => showDialog<T>(
  context: context,
  barrierColor: context.palette.scrim,
  builder: (_) => dialog,
);

String _dateLabel(BuildContext context, LogicalDate date, LogicalDate today) {
  final l10n = context.l10n;
  if (date == today) return l10n.financeToday;
  if (date == today.previous) return l10n.financeYesterday;
  return DateFormat.MMMEd(
    Localizations.localeOf(context).toString(),
  ).format(DateTime.utc(date.year, date.month, date.day));
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 4),
    child: Text(
      text,
      style: TextStyle(
        color: context.palette.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: .4,
      ),
    ),
  );
}

/// Chips de categoría (una sola selección).
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});
  final FinanceCategory selected;
  final ValueChanged<FinanceCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final category in FinanceCategory.values)
          ChoiceChip(
            key: ValueKey('finance-category-${category.name}'),
            avatar: Icon(categoryIcon(category), size: 16),
            label: Text(categoryLabel(l10n, category)),
            selected: category == selected,
            onSelected: (_) => onSelected(category),
          ),
      ],
    );
  }
}

// ----------------------------------------------------------- movimiento

Future<MovementDraft?> showMovementDialog(
  BuildContext context, {
  required LogicalDate today,
  required String currency,
  Movement? initial,
}) => _show(
  context,
  _MovementDialog(today: today, currency: currency, initial: initial),
);

class _MovementDialog extends StatefulWidget {
  const _MovementDialog({
    required this.today,
    required this.currency,
    this.initial,
  });
  final LogicalDate today;
  final String currency;
  final Movement? initial;

  @override
  State<_MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<_MovementDialog> {
  late MovementKind _kind = widget.initial?.kind ?? MovementKind.expense;
  late final _amount = TextEditingController(
    text: widget.initial == null
        ? ''
        : amountTextFromCents(widget.initial!.amountCents, 'es'),
  );
  late int? _cents = widget.initial?.amountCents;
  late final _concept = TextEditingController(text: widget.initial?.concept);
  late final _note = TextEditingController(text: widget.initial?.note ?? '');
  late FinanceCategory _category =
      widget.initial?.category ?? FinanceCategory.food;
  late LogicalDate _date = widget.initial?.date ?? widget.today;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _amount.text = amountTextFromCents(
          widget.initial!.amountCents,
          Localizations.localeOf(context).toString(),
        );
      });
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _concept.dispose();
    _note.dispose();
    super.dispose();
  }

  MovementDraft get _draft => MovementDraft(
    kind: _kind,
    amountCents: _cents ?? 0,
    concept: _concept.text,
    category: _category,
    date: _date,
    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    fixedCostId: widget.initial?.fixedCostId,
    investmentId: widget.initial?.investmentId,
    pendingPurchaseId: widget.initial?.pendingPurchaseId,
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_date.year, _date.month, _date.day),
      firstDate: DateTime(widget.today.year - 5),
      // Un movimiento futuro es una compra pendiente, no un movimiento.
      lastDate: DateTime(
        widget.today.year,
        widget.today.month,
        widget.today.day,
      ),
    );
    if (picked == null) return;
    setState(() => _date = LogicalDate(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.initial != null;
    return AppFormDialog(
      key: const ValueKey('finance-movement-dialog'),
      hero: const AppDialogHero.icon(
        icon: PhosphorIconsFill.wallet,
        color: AppColors.lilac,
      ),
      title: editing ? l10n.financeEditMovement : l10n.financeNewMovement,
      primaryLabel: l10n.financeSave,
      primaryKey: const ValueKey('finance-movement-save'),
      onPrimary: _draft.isValid ? () => Navigator.pop(context, _draft) : null,
      children: [
        SegmentedPill<MovementKind>(
          options: MovementKind.values,
          selected: _kind,
          expand: true,
          keyOf: (kind) => ValueKey('finance-kind-${kind.name}'),
          labelOf: (kind) => kind == MovementKind.income
              ? l10n.financeTypeIncome
              : l10n.financeTypeExpense,
          onSelected: (kind) => setState(() {
            _kind = kind;
            if (kind == MovementKind.income &&
                _category != FinanceCategory.salary &&
                _category != FinanceCategory.other) {
              _category = FinanceCategory.salary;
            }
          }),
        ),
        const SizedBox(height: 14),
        AmountField(
          key: const ValueKey('finance-amount-field'),
          controller: _amount,
          currency: widget.currency,
          label: l10n.financeAmountLabel,
          autofocus: !editing,
          textInputAction: TextInputAction.next,
          onChanged: (cents) => setState(() => _cents = cents),
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: const ValueKey('finance-concept-field'),
          controller: _concept,
          label: l10n.financeConceptLabel,
          prefixIcon: PhosphorIconsBold.textAa,
          maxLength: FinanceLimits.maxTextLength,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _FieldLabel(l10n.financeCategoryLabel),
        _CategoryChips(
          selected: _category,
          onSelected: (category) => setState(() => _category = category),
        ),
        const SizedBox(height: 10),
        _FieldLabel(l10n.financeDateLabel),
        Align(
          alignment: Alignment.centerLeft,
          child: ActionChip(
            key: const ValueKey('finance-date-chip'),
            avatar: const Icon(PhosphorIconsBold.calendarBlank, size: 16),
            label: Text(_dateLabel(context, _date, widget.today)),
            onPressed: _pickDate,
          ),
        ),
        const SizedBox(height: 10),
        AppTextField(
          controller: _note,
          label: l10n.financeNoteLabel,
          prefixIcon: PhosphorIconsBold.notePencil,
          maxLength: FinanceLimits.maxNoteLength,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------- gasto fijo

Future<FixedCostDraft?> showFixedCostDialog(
  BuildContext context, {
  required String currency,
  FixedCost? initial,
}) => _show(context, _FixedCostDialog(currency: currency, initial: initial));

class _FixedCostDialog extends StatefulWidget {
  const _FixedCostDialog({required this.currency, this.initial});
  final String currency;
  final FixedCost? initial;

  @override
  State<_FixedCostDialog> createState() => _FixedCostDialogState();
}

class _FixedCostDialogState extends State<_FixedCostDialog> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _amount = TextEditingController();
  late int? _cents = widget.initial?.amountCents;
  late int _day = widget.initial?.dayOfMonth ?? 1;
  late FinanceCategory _category =
      widget.initial?.category ?? FinanceCategory.home;
  late bool _active = widget.initial?.active ?? true;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _amount.text = amountTextFromCents(
          widget.initial!.amountCents,
          Localizations.localeOf(context).toString(),
        );
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  FixedCostDraft get _draft => FixedCostDraft(
    name: _name.text,
    amountCents: _cents ?? 0,
    dayOfMonth: _day,
    category: _category,
    active: _active,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return AppFormDialog(
      key: const ValueKey('finance-fixed-dialog'),
      hero: const AppDialogHero.icon(
        icon: PhosphorIconsFill.repeat,
        color: AppColors.lilac,
      ),
      title: widget.initial == null
          ? l10n.financeNewFixed
          : l10n.financeEditFixed,
      primaryLabel: l10n.financeSave,
      primaryKey: const ValueKey('finance-fixed-save'),
      onPrimary: _draft.isValid ? () => Navigator.pop(context, _draft) : null,
      children: [
        AppTextField(
          key: const ValueKey('finance-fixed-name'),
          controller: _name,
          label: l10n.financeNameLabel,
          prefixIcon: PhosphorIconsBold.textAa,
          maxLength: FinanceLimits.maxTextLength,
          autofocus: widget.initial == null,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AmountField(
          key: const ValueKey('finance-fixed-amount'),
          controller: _amount,
          currency: widget.currency,
          label: l10n.financeAmountLabel,
          onChanged: (cents) => setState(() => _cents = cents),
        ),
        const SizedBox(height: 14),
        _FieldLabel(l10n.financeDayOfMonthLabel),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: _day > 1 ? () => setState(() => _day--) : null,
              icon: const Icon(PhosphorIconsBold.minus, size: 18),
            ),
            Expanded(
              child: Text(
                l10n.financeDayOfMonth(_day),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: _day < 28 ? () => setState(() => _day++) : null,
              icon: const Icon(PhosphorIconsBold.plus, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FieldLabel(l10n.financeCategoryLabel),
        _CategoryChips(
          selected: _category,
          onSelected: (category) => setState(() => _category = category),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.financeActiveLabel),
          value: _active,
          onChanged: (value) => setState(() => _active = value),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------- inversión

Future<InvestmentDraft?> showInvestmentDialog(
  BuildContext context, {
  required String currency,
  Investment? initial,
}) => _show(context, _InvestmentDialog(currency: currency, initial: initial));

class _InvestmentDialog extends StatefulWidget {
  const _InvestmentDialog({required this.currency, this.initial});
  final String currency;
  final Investment? initial;

  @override
  State<_InvestmentDialog> createState() => _InvestmentDialogState();
}

class _InvestmentDialogState extends State<_InvestmentDialog> {
  late final _name = TextEditingController(text: widget.initial?.name);
  final _contributed = TextEditingController();
  final _value = TextEditingController();
  late int? _contributedCents = widget.initial?.contributedCents;
  late int? _valueCents = widget.initial?.currentValueCents;
  late InvestmentType _type = widget.initial?.type ?? InvestmentType.funds;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final locale = Localizations.localeOf(context).toString();
        _contributed.text = amountTextFromCents(
          widget.initial!.contributedCents,
          locale,
        );
        _value.text = amountTextFromCents(
          widget.initial!.currentValueCents,
          locale,
        );
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _contributed.dispose();
    _value.dispose();
    super.dispose();
  }

  InvestmentDraft get _draft => InvestmentDraft(
    name: _name.text,
    type: _type,
    contributedCents: _contributedCents ?? 0,
    currentValueCents: _valueCents ?? (_contributedCents ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppFormDialog(
      key: const ValueKey('finance-investment-dialog'),
      hero: const AppDialogHero.icon(
        icon: PhosphorIconsFill.trendUp,
        color: AppColors.green,
      ),
      title: widget.initial == null
          ? l10n.financeNewInvestment
          : l10n.financeEditInvestment,
      primaryLabel: l10n.financeSave,
      primaryKey: const ValueKey('finance-investment-save'),
      onPrimary: _draft.isValid && _contributedCents != null
          ? () => Navigator.pop(context, _draft)
          : null,
      children: [
        AppTextField(
          key: const ValueKey('finance-investment-name'),
          controller: _name,
          label: l10n.financeNameLabel,
          prefixIcon: PhosphorIconsBold.textAa,
          maxLength: FinanceLimits.maxTextLength,
          autofocus: widget.initial == null,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _FieldLabel(l10n.financeInvestmentTypeLabel),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final type in InvestmentType.values)
              ChoiceChip(
                label: Text(investmentTypeLabel(l10n, type)),
                selected: type == _type,
                onSelected: (_) => setState(() => _type = type),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AmountField(
          key: const ValueKey('finance-investment-contributed'),
          controller: _contributed,
          currency: widget.currency,
          label: l10n.financeContributedLabel,
          textInputAction: TextInputAction.next,
          onChanged: (cents) => setState(() => _contributedCents = cents),
        ),
        const SizedBox(height: 12),
        AmountField(
          key: const ValueKey('finance-investment-value'),
          controller: _value,
          currency: widget.currency,
          label: l10n.financeCurrentValueLabel,
          onChanged: (cents) => setState(() => _valueCents = cents),
        ),
      ],
    );
  }
}

// -------------------------------------------------------- importe suelto

/// Pide un importe (actualizar valor, aportar, precio real de una compra).
/// Con [toggleLabel] añade un interruptor y devuelve su valor.
Future<({int cents, bool toggle})?> showAmountDialog(
  BuildContext context, {
  required String title,
  required String currency,
  String? helper,
  int? initialCents,
  String? toggleLabel,
  bool toggleInitial = true,
  IconData icon = PhosphorIconsFill.coins,
  Color color = AppColors.lilac,
}) => _show(
  context,
  _AmountDialog(
    title: title,
    helper: helper,
    currency: currency,
    initialCents: initialCents,
    toggleLabel: toggleLabel,
    toggleInitial: toggleInitial,
    icon: icon,
    color: color,
  ),
);

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.title,
    required this.currency,
    required this.icon,
    required this.color,
    this.helper,
    this.initialCents,
    this.toggleLabel,
    this.toggleInitial = true,
  });
  final String title;
  final String? helper;
  final String currency;
  final int? initialCents;
  final String? toggleLabel;
  final bool toggleInitial;
  final IconData icon;
  final Color color;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _amount = TextEditingController();
  late int? _cents = widget.initialCents;
  late bool _toggle = widget.toggleInitial;

  @override
  void initState() {
    super.initState();
    if (widget.initialCents != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _amount.text = amountTextFromCents(
          widget.initialCents!,
          Localizations.localeOf(context).toString(),
        );
      });
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final valid =
        _cents != null &&
        _cents! > 0 &&
        _cents! <= FinanceLimits.maxAmountCents;
    return AppFormDialog(
      key: const ValueKey('finance-amount-dialog'),
      hero: AppDialogHero.icon(icon: widget.icon, color: widget.color),
      title: widget.title,
      helper: widget.helper,
      primaryLabel: l10n.financeSave,
      primaryKey: const ValueKey('finance-amount-save'),
      onPrimary: valid
          ? () => Navigator.pop(context, (cents: _cents!, toggle: _toggle))
          : null,
      children: [
        AmountField(
          key: const ValueKey('finance-amount-input'),
          controller: _amount,
          currency: widget.currency,
          label: l10n.financeAmountLabel,
          autofocus: true,
          onChanged: (cents) => setState(() => _cents = cents),
        ),
        if (widget.toggleLabel != null)
          SwitchListTile(
            key: const ValueKey('finance-amount-toggle'),
            contentPadding: EdgeInsets.zero,
            title: Text(widget.toggleLabel!),
            value: _toggle,
            onChanged: (value) => setState(() => _toggle = value),
          ),
      ],
    );
  }
}

// ---------------------------------------------------- compra pendiente

Future<PendingPurchaseDraft?> showPendingPurchaseDialog(
  BuildContext context, {
  required LogicalDate today,
  required String currency,
  PendingPurchase? initial,
}) => _show(
  context,
  _PendingPurchaseDialog(today: today, currency: currency, initial: initial),
);

class _PendingPurchaseDialog extends StatefulWidget {
  const _PendingPurchaseDialog({
    required this.today,
    required this.currency,
    this.initial,
  });
  final LogicalDate today;
  final String currency;
  final PendingPurchase? initial;

  @override
  State<_PendingPurchaseDialog> createState() => _PendingPurchaseDialogState();
}

class _PendingPurchaseDialogState extends State<_PendingPurchaseDialog> {
  late final _name = TextEditingController(text: widget.initial?.name);
  final _amount = TextEditingController();
  late int? _cents = widget.initial?.estimatedCents;
  late PurchasePriority _priority =
      widget.initial?.priority ?? PurchasePriority.normal;
  late LogicalDate? _target = widget.initial?.targetDate;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _amount.text = amountTextFromCents(
          widget.initial!.estimatedCents,
          Localizations.localeOf(context).toString(),
        );
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  PendingPurchaseDraft get _draft => PendingPurchaseDraft(
    name: _name.text,
    estimatedCents: _cents ?? 0,
    priority: _priority,
    targetDate: _target,
  );

  Future<void> _pickDate() async {
    final base = _target ?? widget.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(base.year, base.month, base.day),
      firstDate: DateTime(
        widget.today.year,
        widget.today.month,
        widget.today.day,
      ),
      lastDate: DateTime(widget.today.year + 10, 12, 31),
    );
    if (picked == null) return;
    setState(
      () => _target = LogicalDate(picked.year, picked.month, picked.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppFormDialog(
      key: const ValueKey('finance-pending-dialog'),
      hero: const AppDialogHero.icon(
        icon: PhosphorIconsFill.gift,
        color: AppColors.pink,
      ),
      title: widget.initial == null
          ? l10n.financeNewPending
          : l10n.financeEditPending,
      primaryLabel: l10n.financeSave,
      primaryKey: const ValueKey('finance-pending-save'),
      onPrimary: _draft.isValid ? () => Navigator.pop(context, _draft) : null,
      children: [
        AppTextField(
          key: const ValueKey('finance-pending-name'),
          controller: _name,
          label: l10n.financeNameLabel,
          prefixIcon: PhosphorIconsBold.textAa,
          maxLength: FinanceLimits.maxTextLength,
          autofocus: widget.initial == null,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AmountField(
          key: const ValueKey('finance-pending-amount'),
          controller: _amount,
          currency: widget.currency,
          label: l10n.financeEstimatedLabel,
          onChanged: (cents) => setState(() => _cents = cents),
        ),
        const SizedBox(height: 14),
        _FieldLabel(l10n.financeTargetDateLabel),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              avatar: const Icon(PhosphorIconsBold.calendarBlank, size: 16),
              label: Text(
                _target == null
                    ? l10n.tasksDatePick
                    : _dateLabel(context, _target!, widget.today),
              ),
              selected: _target != null,
              onSelected: (_) => _pickDate(),
            ),
            ChoiceChip(
              label: Text(l10n.financeNoTargetDate),
              selected: _target == null,
              onSelected: (_) => setState(() => _target = null),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FieldLabel(l10n.financePriorityLabel),
        SegmentedPill<PurchasePriority>(
          options: PurchasePriority.values,
          selected: _priority,
          expand: true,
          labelOf: (priority) => purchasePriorityLabel(l10n, priority),
          onSelected: (priority) => setState(() => _priority = priority),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- ajustes

Future<FinanceConfig?> showFinanceSettingsSheet(
  BuildContext context, {
  required FinanceConfig initial,
}) => showModalBottomSheet<FinanceConfig>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  backgroundColor: context.palette.surfaceElevated,
  builder: (_) => _SettingsSheet(initial: initial),
);

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({required this.initial});
  final FinanceConfig initial;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late FinanceConfig _config = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final currencies = {...FinanceConfig.currencies, _config.currency}.toList();
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.financeSettingsTitle,
              style: textTheme.titleLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            _FieldLabel(l10n.financeCurrencyLabel),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final currency in currencies)
                  ChoiceChip(
                    key: ValueKey('finance-currency-$currency'),
                    label: Text(currency),
                    selected: currency == _config.currency,
                    onSelected: (_) => setState(
                      () => _config = _config.copyWith(currency: currency),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.financeCurrencyHelper,
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            _FieldLabel(l10n.financeMonthStartLabel),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _config.monthStartDay > 1
                      ? () => setState(
                          () => _config = _config.copyWith(
                            monthStartDay: _config.monthStartDay - 1,
                          ),
                        )
                      : null,
                  icon: const Icon(PhosphorIconsBold.minus, size: 18),
                ),
                Expanded(
                  child: Text(
                    l10n.financeDayOfMonth(_config.monthStartDay),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _config.monthStartDay < 28
                      ? () => setState(
                          () => _config = _config.copyWith(
                            monthStartDay: _config.monthStartDay + 1,
                          ),
                        )
                      : null,
                  icon: const Icon(PhosphorIconsBold.plus, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('finance-settings-save'),
              onPressed: _config.isValid
                  ? () => Navigator.pop(context, _config)
                  : null,
              child: Text(l10n.financeSettingsSave),
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
