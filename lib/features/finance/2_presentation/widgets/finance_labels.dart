import 'package:flutter/widgets.dart';
import 'package:habits/features/finance/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

String categoryLabel(AppLocalizations l10n, FinanceCategory category) =>
    switch (category) {
      FinanceCategory.home => l10n.financeCategoryHome,
      FinanceCategory.food => l10n.financeCategoryFood,
      FinanceCategory.transport => l10n.financeCategoryTransport,
      FinanceCategory.leisure => l10n.financeCategoryLeisure,
      FinanceCategory.health => l10n.financeCategoryHealth,
      FinanceCategory.clothes => l10n.financeCategoryClothes,
      FinanceCategory.subscriptions => l10n.financeCategorySubscriptions,
      FinanceCategory.gifts => l10n.financeCategoryGifts,
      FinanceCategory.salary => l10n.financeCategorySalary,
      FinanceCategory.investment => l10n.financeCategoryInvestment,
      FinanceCategory.other => l10n.financeCategoryOther,
    };

IconData categoryIcon(FinanceCategory category) => switch (category) {
  FinanceCategory.home => PhosphorIconsFill.house,
  FinanceCategory.food => PhosphorIconsFill.forkKnife,
  FinanceCategory.transport => PhosphorIconsFill.car,
  FinanceCategory.leisure => PhosphorIconsFill.confetti,
  FinanceCategory.health => PhosphorIconsFill.heartbeat,
  FinanceCategory.clothes => PhosphorIconsFill.tShirt,
  FinanceCategory.subscriptions => PhosphorIconsFill.repeat,
  FinanceCategory.gifts => PhosphorIconsFill.gift,
  FinanceCategory.salary => PhosphorIconsFill.briefcase,
  FinanceCategory.investment => PhosphorIconsFill.trendUp,
  FinanceCategory.other => PhosphorIconsFill.dotsThreeCircle,
};

String investmentTypeLabel(AppLocalizations l10n, InvestmentType type) =>
    switch (type) {
      InvestmentType.funds => l10n.financeInvestmentFunds,
      InvestmentType.stocks => l10n.financeInvestmentStocks,
      InvestmentType.crypto => l10n.financeInvestmentCrypto,
      InvestmentType.deposit => l10n.financeInvestmentDeposit,
      InvestmentType.property => l10n.financeInvestmentProperty,
      InvestmentType.other => l10n.financeInvestmentOther,
    };

String purchasePriorityLabel(
  AppLocalizations l10n,
  PurchasePriority priority,
) => switch (priority) {
  PurchasePriority.low => l10n.financePriorityLow,
  PurchasePriority.normal => l10n.financePriorityNormal,
  PurchasePriority.high => l10n.financePriorityHigh,
};
