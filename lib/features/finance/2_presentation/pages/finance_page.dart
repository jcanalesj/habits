import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/finance/0_entity/entity.dart';
import 'package:habits/features/finance/1_domain/domain.dart';
import 'package:habits/features/finance/2_presentation/providers/finance_providers.dart';
import 'package:habits/features/finance/2_presentation/widgets/finance_dialogs.dart';
import 'package:habits/features/finance/2_presentation/widgets/finance_labels.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

enum _FinanceTab { movements, fixed, investments, pending }

/// Finanzas personales: héroe del mes y cuatro partes (movimientos, gastos
/// fijos, inversiones y compras pendientes).
class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  _FinanceTab _tab = _FinanceTab.movements;

  String get _locale => Localizations.localeOf(context).toString();

  FinanceConfig get _config =>
      ref.read(financeConfigProvider).value ?? _defaultConfig;

  /// Sin ajustes guardados la moneda sale del idioma.
  FinanceConfig get _defaultConfig => FinanceConfig(
    currency: Localizations.localeOf(context).languageCode == 'en'
        ? 'USD'
        : 'EUR',
  );

  String _money(int cents) => formatMoney(cents, _config.currency, _locale);

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      AppNotice.show(
        context,
        message: context.l10n.financeSaveError,
        type: AppNoticeType.error,
      );
      return;
    }
    if (success != null && mounted) {
      AppNotice.show(context, message: success, type: AppNoticeType.success);
    }
  }

  Future<bool> _confirmDelete() => showConfirmDeleteDialog(
    context,
    title: context.l10n.financeDeleteTitle,
    body: context.l10n.financeDeleteBody,
  );

  Future<void> _openSettings() async {
    final next = await showFinanceSettingsSheet(context, initial: _config);
    if (next == null || !mounted) return;
    await _run(
      () => ref.read(financeRepositoryProvider).saveConfig(next),
      success: context.l10n.financeSaved,
    );
  }

  // ------------------------------------------------------------ acciones

  Future<void> _addOrEditMovement([Movement? initial]) async {
    final today = ref.read(todayProvider);
    final draft = await showMovementDialog(
      context,
      today: today,
      currency: _config.currency,
      initial: initial,
    );
    if (draft == null || !mounted) return;
    final repository = ref.read(financeRepositoryProvider);
    await _run(
      () => initial == null
          ? repository.addMovement(draft)
          : repository.updateMovement(initial.id, draft),
      success: context.l10n.financeSaved,
    );
  }

  Future<void> _addOrEditFixed([FixedCost? initial]) async {
    final draft = await showFixedCostDialog(
      context,
      currency: _config.currency,
      initial: initial,
    );
    if (draft == null || !mounted) return;
    final repository = ref.read(financeRepositoryProvider);
    await _run(
      () => initial == null
          ? repository.addFixedCost(draft)
          : repository.updateFixedCost(initial.id, draft),
      success: context.l10n.financeSaved,
    );
  }

  Future<void> _logFixed(FixedCost cost, FinancePeriod period) => _run(
    () => ref
        .read(financeRepositoryProvider)
        .logFixedCost(
          cost,
          monthKey: period.key,
          date: period.dayFor(cost.dayOfMonth),
        ),
    success: context.l10n.financeSaved,
  );

  Future<void> _addOrEditInvestment([Investment? initial]) async {
    final draft = await showInvestmentDialog(
      context,
      currency: _config.currency,
      initial: initial,
    );
    if (draft == null || !mounted) return;
    final repository = ref.read(financeRepositoryProvider);
    await _run(
      () => initial == null
          ? repository.addInvestment(draft)
          : repository.updateInvestment(initial.id, draft),
      success: context.l10n.financeSaved,
    );
  }

  Future<void> _updateValue(Investment investment) async {
    final result = await showAmountDialog(
      context,
      title: context.l10n.financeUpdateValue,
      currency: _config.currency,
      initialCents: investment.currentValueCents,
      icon: PhosphorIconsFill.trendUp,
      color: AppColors.green,
    );
    if (result == null || !mounted) return;
    await _run(
      () => ref
          .read(financeRepositoryProvider)
          .updateInvestmentValue(investment.id, result.cents),
      success: context.l10n.financeSaved,
    );
  }

  Future<void> _contribute(Investment investment) async {
    final l10n = context.l10n;
    final result = await showAmountDialog(
      context,
      title: l10n.financeContributionAmount,
      currency: _config.currency,
      toggleLabel: l10n.financeContributionAsMovement,
      icon: PhosphorIconsFill.plusCircle,
      color: AppColors.green,
    );
    if (result == null || !mounted) return;
    final today = ref.read(todayProvider);
    await _run(
      () => ref
          .read(financeRepositoryProvider)
          .contributeToInvestment(
            investment,
            result.cents,
            movementDate: result.toggle ? today : null,
          ),
      success: l10n.financeSaved,
    );
  }

  Future<void> _addOrEditPending([PendingPurchase? initial]) async {
    final today = ref.read(todayProvider);
    final draft = await showPendingPurchaseDialog(
      context,
      today: today,
      currency: _config.currency,
      initial: initial,
    );
    if (draft == null || !mounted) return;
    final repository = ref.read(financeRepositoryProvider);
    await _run(
      () => initial == null
          ? repository.addPendingPurchase(draft)
          : repository.updatePendingPurchase(initial.id, draft),
      success: context.l10n.financeSaved,
    );
  }

  Future<void> _markBought(PendingPurchase purchase) async {
    final l10n = context.l10n;
    final result = await showAmountDialog(
      context,
      title: l10n.financeBoughtTitle,
      helper: l10n.financeBoughtHelper,
      currency: _config.currency,
      initialCents: purchase.estimatedCents,
      icon: PhosphorIconsFill.shoppingBag,
      color: AppColors.pink,
    );
    if (result == null || !mounted) return;
    final today = ref.read(todayProvider);
    await _run(
      () => ref
          .read(financeRepositoryProvider)
          .markPurchased(purchase, amountCents: result.cents, date: today),
      success: l10n.financeSaved,
    );
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final period = ref.watch(selectedFinancePeriodProvider);
    final config = ref.watch(financeConfigProvider).value ?? _defaultConfig;
    final summary = ref.watch(periodSummaryProvider(period));
    final offset = ref.watch(financeMonthOffsetProvider);

    final monthName = DateFormat.yMMMM(_locale).format(
      DateTime.utc(period.start.year, period.start.month, period.start.day),
    );
    final monthShort = DateFormat.MMMM(_locale).format(
      DateTime.utc(period.start.year, period.start.month, period.start.day),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.financeTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            key: const ValueKey('finance-settings'),
            tooltip: l10n.financeSettingsTitle,
            onPressed: _openSettings,
            icon: const Icon(PhosphorIconsBold.gear),
          ),
        ],
      ),
      body: ListView(
        key: const ValueKey('finance-page'),
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          40 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          _MonthHero(
            title: monthName,
            summary: summary,
            currency: config.currency,
            locale: _locale,
            isCurrent: offset == 0,
            onPrevious: ref.read(financeMonthOffsetProvider.notifier).previous,
            onNext: ref.read(financeMonthOffsetProvider.notifier).next,
          ),
          const SizedBox(height: 16),
          SegmentedPill<_FinanceTab>(
            options: _FinanceTab.values,
            selected: _tab,
            expand: true,
            keyOf: (tab) => ValueKey('finance-tab-${tab.name}'),
            labelOf: (tab) => switch (tab) {
              _FinanceTab.movements => l10n.financeTabMovements,
              _FinanceTab.fixed => l10n.financeTabFixed,
              _FinanceTab.investments => l10n.financeTabInvestments,
              _FinanceTab.pending => l10n.financeTabPending,
            },
            onSelected: (tab) => setState(() => _tab = tab),
          ),
          const SizedBox(height: 16),
          switch (_tab) {
            _FinanceTab.movements => _MovementsView(
              period: period,
              money: _money,
              onTap: _addOrEditMovement,
              onDelete: (movement) async {
                if (!await _confirmDelete() || !mounted) return;
                await _run(
                  () => ref
                      .read(financeRepositoryProvider)
                      .deleteMovement(movement.id),
                );
              },
            ),
            _FinanceTab.fixed => _FixedView(
              period: period,
              monthShort: monthShort,
              money: _money,
              onTap: _addOrEditFixed,
              onLog: (cost) => _logFixed(cost, period),
              onDelete: (cost) async {
                if (!await _confirmDelete() || !mounted) return;
                await _run(
                  () => ref
                      .read(financeRepositoryProvider)
                      .deleteFixedCost(cost.id),
                );
              },
            ),
            _FinanceTab.investments => _InvestmentsView(
              money: _money,
              onTap: _addOrEditInvestment,
              onUpdateValue: _updateValue,
              onContribute: _contribute,
              onDelete: (investment) async {
                if (!await _confirmDelete() || !mounted) return;
                await _run(
                  () => ref
                      .read(financeRepositoryProvider)
                      .deleteInvestment(investment.id),
                );
              },
            ),
            _FinanceTab.pending => _PendingView(
              money: _money,
              onTap: _addOrEditPending,
              onBought: _markBought,
              onDelete: (purchase) async {
                if (!await _confirmDelete() || !mounted) return;
                await _run(
                  () => ref
                      .read(financeRepositoryProvider)
                      .deletePendingPurchase(purchase.id),
                );
              },
            ),
          },
          const SizedBox(height: 22),
          FilledButton.icon(
            key: const ValueKey('finance-new'),
            onPressed: switch (_tab) {
              _FinanceTab.movements => () => _addOrEditMovement(),
              _FinanceTab.fixed => () => _addOrEditFixed(),
              _FinanceTab.investments => () => _addOrEditInvestment(),
              _FinanceTab.pending => () => _addOrEditPending(),
            },
            icon: const Icon(PhosphorIconsBold.plus),
            label: Text(switch (_tab) {
              _FinanceTab.movements => l10n.financeNewMovement,
              _FinanceTab.fixed => l10n.financeNewFixed,
              _FinanceTab.investments => l10n.financeNewInvestment,
              _FinanceTab.pending => l10n.financeNewPending,
            }),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              backgroundColor: palette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- héroe

class _MonthHero extends StatelessWidget {
  const _MonthHero({
    required this.title,
    required this.summary,
    required this.currency,
    required this.locale,
    required this.isCurrent,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final PeriodSummary? summary;
  final String currency;
  final String locale;
  final bool isCurrent;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final balance = summary?.balanceCents;
    final balanceColor = balance == null
        ? palette.textPrimary
        : balance < 0
        ? dangerColor
        : AppColors.green;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.tint(palette.primary, .06),
            palette.tint(AppColors.lilac, .06),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
            child: Row(
              children: [
                IconButton(
                  key: const ValueKey('finance-previous-month'),
                  tooltip: l10n.financePreviousMonth,
                  onPressed: onPrevious,
                  icon: const Icon(PhosphorIconsBold.caretLeft),
                ),
                Expanded(
                  child: Text(
                    title[0].toUpperCase() + title.substring(1),
                    key: const ValueKey('finance-month-title'),
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('finance-next-month'),
                  tooltip: l10n.financeNextMonth,
                  onPressed: isCurrent ? null : onNext,
                  icon: const Icon(PhosphorIconsBold.caretRight),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: palette.isDark ? 1 : .9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.financeMonthBalance,
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  balance == null
                      ? '—'
                      : formatSignedMoney(balance, currency, locale),
                  key: const ValueKey('finance-balance'),
                  style: TextStyle(
                    color: balanceColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _HeroValue(
                        label: l10n.financeIncome,
                        value: summary == null
                            ? '—'
                            : formatMoney(
                                summary!.incomeCents,
                                currency,
                                locale,
                              ),
                        color: AppColors.green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 34,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      color: palette.divider,
                    ),
                    Expanded(
                      child: _HeroValue(
                        label: l10n.financeExpenses,
                        value: summary == null
                            ? '—'
                            : formatMoney(
                                summary!.expenseCents,
                                currency,
                                locale,
                              ),
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (summary != null && summary!.fixedTotal > 0) ...[
                  const SizedBox(height: 14),
                  Text(
                    l10n.financeFixedProgress(
                      summary!.fixedLogged,
                      summary!.fixedTotal,
                    ),
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary!.fixedLogged / summary!.fixedTotal,
                      minHeight: 8,
                      backgroundColor: palette.tint(palette.primary, .10),
                      color: palette.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroValue extends StatelessWidget {
  const _HeroValue({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: palette.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------ piezas comunes

class _ListCard extends StatelessWidget {
  const _ListCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: surfaceDecoration(palette),
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0)
              Divider(height: 1, indent: 56, color: palette.divider),
            child,
          ],
        ],
      ),
    );
  }
}

class _Swipeable extends StatelessWidget {
  const _Swipeable({
    required super.key,
    required this.onDelete,
    required this.child,
  });
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) => Dismissible(
    key: key!,
    direction: DismissDirection.endToStart,
    confirmDismiss: (_) async {
      onDelete();
      return false;
    },
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      color: dangerColor.withValues(alpha: .12),
      child: const Icon(PhosphorIconsBold.trash, color: dangerColor),
    ),
    child: child,
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.palette.tint(color, .12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 19),
  );
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _IconBox(icon: icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                trailing,
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: action),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
    child: Text(
      text,
      style: TextStyle(
        color: context.palette.textSecondary,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    ),
  );
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.items});
  final List<(String label, String value, Color? color)> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: surfaceDecoration(palette),
      child: Row(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0)
              Container(
                width: 1,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: palette.divider,
              ),
            Expanded(
              child: _HeroValue(
                label: item.$1,
                value: item.$2,
                color: item.$3 ?? palette.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _tonalAction({
  required Key key,
  required BuildContext context,
  required String label,
  required IconData icon,
  required VoidCallback? onPressed,
  Color? color,
}) {
  final palette = context.palette;
  final accent = color ?? palette.primary;
  return FilledButton.tonalIcon(
    key: key,
    onPressed: onPressed,
    icon: Icon(icon, size: 16),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: palette.tint(accent, .12),
      foregroundColor: palette.isDark
          ? accent
          : Color.lerp(accent, palette.textPrimary, .25),
      visualDensity: VisualDensity.compact,
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
    ),
  );
}

// ----------------------------------------------------------- movimientos

class _MovementsView extends ConsumerWidget {
  const _MovementsView({
    required this.period,
    required this.money,
    required this.onTap,
    required this.onDelete,
  });

  final FinancePeriod period;
  final String Function(int cents) money;
  final void Function(Movement movement) onTap;
  final void Function(Movement movement) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.palette;
    final today = ref.watch(todayProvider);
    final movements =
        ref.watch(periodMovementsProvider(period)).value ?? const <Movement>[];
    if (movements.isEmpty) {
      return EmptyStateBlock(
        icon: PhosphorIconsRegular.receipt,
        text: l10n.financeMovementsEmpty,
      );
    }
    final locale = Localizations.localeOf(context).toString();
    final groups = <LogicalDate, List<Movement>>{};
    for (final movement in movements) {
      groups.putIfAbsent(movement.date, () => []).add(movement);
    }
    String dayLabel(LogicalDate date) {
      if (date == today) return l10n.financeToday;
      if (date == today.previous) return l10n.financeYesterday;
      return DateFormat.MMMEd(
        locale,
      ).format(DateTime.utc(date.year, date.month, date.day));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in groups.entries) ...[
          _SectionLabel(dayLabel(entry.key)),
          _ListCard(
            children: [
              for (final movement in entry.value)
                _Swipeable(
                  key: ValueKey('movement-${movement.id}'),
                  onDelete: () => onDelete(movement),
                  child: _RowTile(
                    icon: categoryIcon(movement.category),
                    color: movement.kind == MovementKind.income
                        ? AppColors.green
                        : AppColors.lilac,
                    title: movement.concept,
                    subtitle: categoryLabel(l10n, movement.category),
                    trailing: Text(
                      movement.kind == MovementKind.income
                          ? '+${money(movement.amountCents)}'
                          : '−${money(movement.amountCents)}',
                      style: TextStyle(
                        color: movement.kind == MovementKind.income
                            ? AppColors.green
                            : palette.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onTap: () => onTap(movement),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------ fijos

class _FixedView extends ConsumerWidget {
  const _FixedView({
    required this.period,
    required this.monthShort,
    required this.money,
    required this.onTap,
    required this.onLog,
    required this.onDelete,
  });

  final FinancePeriod period;
  final String monthShort;
  final String Function(int cents) money;
  final void Function(FixedCost cost) onTap;
  final void Function(FixedCost cost) onLog;
  final void Function(FixedCost cost) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.palette;
    final costs = ref.watch(fixedCostsProvider).value ?? const <FixedCost>[];
    if (costs.isEmpty) {
      return EmptyStateBlock(
        icon: PhosphorIconsRegular.repeat,
        text: l10n.financeFixedEmpty,
      );
    }
    final total = costs
        .where((cost) => cost.active)
        .fold(0, (sum, cost) => sum + cost.amountCents);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalsRow(items: [(l10n.financeFixedTotal, money(total), null)]),
        _ListCard(
          children: [
            for (final cost in costs)
              _Swipeable(
                key: ValueKey('fixed-${cost.id}'),
                onDelete: () => onDelete(cost),
                child: _RowTile(
                  icon: categoryIcon(cost.category),
                  color: cost.active ? AppColors.lilac : palette.textHint,
                  title: cost.name,
                  subtitle: cost.active
                      ? l10n.financeDayOfMonth(cost.dayOfMonth)
                      : l10n.financeInactive,
                  trailing: Text(
                    money(cost.amountCents),
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onTap: () => onTap(cost),
                  action: !cost.active
                      ? null
                      : cost.isLoggedIn(period.key)
                      ? Text(
                          l10n.financeLoggedThisMonth,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        )
                      : _tonalAction(
                          key: ValueKey('fixed-log-${cost.id}'),
                          context: context,
                          label: l10n.financeLogThisMonth(monthShort),
                          icon: PhosphorIconsBold.check,
                          onPressed: () => onLog(cost),
                        ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------- inversiones

class _InvestmentsView extends ConsumerWidget {
  const _InvestmentsView({
    required this.money,
    required this.onTap,
    required this.onUpdateValue,
    required this.onContribute,
    required this.onDelete,
  });

  final String Function(int cents) money;
  final void Function(Investment investment) onTap;
  final void Function(Investment investment) onUpdateValue;
  final void Function(Investment investment) onContribute;
  final void Function(Investment investment) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = context.palette;
    final investments =
        ref.watch(investmentsProvider).value ?? const <Investment>[];
    if (investments.isEmpty) {
      return EmptyStateBlock(
        icon: PhosphorIconsRegular.trendUp,
        text: l10n.financeInvestmentsEmpty,
        color: AppColors.green,
      );
    }
    final contributed = investments.fold(
      0,
      (sum, inv) => sum + inv.contributedCents,
    );
    final value = investments.fold(
      0,
      (sum, inv) => sum + inv.currentValueCents,
    );
    final totalReturn = value - contributed;
    String returnText(int cents, double? percent) {
      final sign = cents >= 0 ? '+' : '−';
      final base = '$sign${money(cents.abs())}';
      if (percent == null) return base;
      return '$base ($sign${percent.abs().toStringAsFixed(1)} %)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalsRow(
          items: [
            (l10n.financeTotalContributed, money(contributed), null),
            (l10n.financeTotalValue, money(value), null),
            (
              l10n.financeReturn,
              returnText(
                totalReturn,
                contributed == 0 ? null : totalReturn * 100 / contributed,
              ),
              totalReturn >= 0 ? AppColors.green : dangerColor,
            ),
          ],
        ),
        _ListCard(
          children: [
            for (final investment in investments)
              _Swipeable(
                key: ValueKey('investment-${investment.id}'),
                onDelete: () => onDelete(investment),
                child: _RowTile(
                  icon: PhosphorIconsFill.trendUp,
                  color: AppColors.green,
                  title: investment.name,
                  subtitle:
                      '${investmentTypeLabel(l10n, investment.type)}  ·  '
                      '${l10n.financeContributedLabel} ${money(investment.contributedCents)}',
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        money(investment.currentValueCents),
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        returnText(
                          investment.returnCents,
                          investment.returnPercent,
                        ),
                        style: TextStyle(
                          color: investment.returnCents >= 0
                              ? AppColors.green
                              : dangerColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => onTap(investment),
                  action: Wrap(
                    spacing: 8,
                    children: [
                      _tonalAction(
                        key: ValueKey('investment-contribute-${investment.id}'),
                        context: context,
                        label: l10n.financeContribute,
                        icon: PhosphorIconsBold.plus,
                        color: AppColors.green,
                        onPressed: () => onContribute(investment),
                      ),
                      _tonalAction(
                        key: ValueKey('investment-value-${investment.id}'),
                        context: context,
                        label: l10n.financeUpdateValue,
                        icon: PhosphorIconsBold.pencilSimple,
                        onPressed: () => onUpdateValue(investment),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ----------------------------------------------------- pendientes

class _PendingView extends ConsumerStatefulWidget {
  const _PendingView({
    required this.money,
    required this.onTap,
    required this.onBought,
    required this.onDelete,
  });

  final String Function(int cents) money;
  final void Function(PendingPurchase purchase) onTap;
  final void Function(PendingPurchase purchase) onBought;
  final void Function(PendingPurchase purchase) onDelete;

  @override
  ConsumerState<_PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends ConsumerState<_PendingView> {
  bool _boughtExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final today = ref.watch(todayProvider);
    final locale = Localizations.localeOf(context).toString();
    final all =
        ref.watch(pendingPurchasesProvider).value ?? const <PendingPurchase>[];
    final pending = all.where((purchase) => !purchase.isBought).toList();
    final bought = all.where((purchase) => purchase.isBought).toList();
    if (all.isEmpty) {
      return EmptyStateBlock(
        icon: PhosphorIconsRegular.gift,
        text: l10n.financePendingEmpty,
        color: AppColors.pink,
      );
    }
    final estimated = pending.fold(
      0,
      (sum, purchase) => sum + purchase.estimatedCents,
    );

    Widget tile(PendingPurchase purchase) {
      final details = [
        purchasePriorityLabel(l10n, purchase.priority),
        if (purchase.targetDate case final date?)
          date == today
              ? l10n.financeToday
              : DateFormat.MMMEd(
                  locale,
                ).format(DateTime.utc(date.year, date.month, date.day)),
      ].join('  ·  ');
      return _Swipeable(
        key: ValueKey('purchase-${purchase.id}'),
        onDelete: () => widget.onDelete(purchase),
        child: _RowTile(
          icon: PhosphorIconsFill.gift,
          color: purchase.isBought
              ? palette.textHint
              : purchase.priority == PurchasePriority.high
              ? AppColors.flame
              : AppColors.pink,
          title: purchase.name,
          subtitle: details,
          trailing: Text(
            widget.money(purchase.estimatedCents),
            style: TextStyle(
              color: purchase.isBought
                  ? palette.textSecondary
                  : palette.textPrimary,
              fontWeight: FontWeight.w900,
              decoration: purchase.isBought ? TextDecoration.lineThrough : null,
            ),
          ),
          onTap: () => widget.onTap(purchase),
          action: purchase.isBought
              ? null
              : _tonalAction(
                  key: ValueKey('purchase-bought-${purchase.id}'),
                  context: context,
                  label: l10n.financeMarkBought,
                  icon: PhosphorIconsBold.check,
                  color: AppColors.pink,
                  onPressed: () => widget.onBought(purchase),
                ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pending.isNotEmpty) ...[
          _TotalsRow(
            items: [
              (l10n.financeEstimatedTotal, widget.money(estimated), null),
            ],
          ),
          _ListCard(children: [for (final purchase in pending) tile(purchase)]),
        ],
        if (bought.isNotEmpty) ...[
          const SizedBox(height: 14),
          InkWell(
            key: const ValueKey('finance-bought-toggle'),
            onTap: () => setState(() => _boughtExpanded = !_boughtExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  child: _SectionLabel(
                    '${l10n.financeBoughtSection} · ${bought.length}',
                  ),
                ),
                Icon(
                  _boughtExpanded
                      ? PhosphorIconsBold.caretUp
                      : PhosphorIconsBold.caretDown,
                  size: 16,
                  color: palette.textSecondary,
                ),
              ],
            ),
          ),
          if (_boughtExpanded)
            _ListCard(
              children: [for (final purchase in bought) tile(purchase)],
            ),
        ],
      ],
    );
  }
}
