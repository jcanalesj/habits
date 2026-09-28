import 'package:habits/features/habits/0_entity/logical_date.dart';

/// Ajustes: moneda ISO 4217 y día en que empieza el "mes" del usuario.
class FinanceConfig {
  const FinanceConfig({this.currency = 'EUR', this.monthStartDay = 1});

  final String currency;

  /// 1–28, para que exista en todos los meses.
  final int monthStartDay;

  static const currencies = ['EUR', 'USD', 'GBP', 'MXN', 'ARS', 'COP', 'CLP'];

  bool get isValid =>
      RegExp(r'^[A-Z]{3}$').hasMatch(currency) &&
      monthStartDay >= 1 &&
      monthStartDay <= 28;

  FinanceConfig copyWith({String? currency, int? monthStartDay}) =>
      FinanceConfig(
        currency: currency ?? this.currency,
        monthStartDay: monthStartDay ?? this.monthStartDay,
      );

  @override
  bool operator ==(Object other) =>
      other is FinanceConfig &&
      other.currency == currency &&
      other.monthStartDay == monthStartDay;

  @override
  int get hashCode => Object.hash(currency, monthStartDay);
}

enum MovementKind { expense, income }

/// Categorías con id estable (se guarda el `name`); el texto lo pone l10n.
enum FinanceCategory {
  home,
  food,
  transport,
  leisure,
  health,
  clothes,
  subscriptions,
  gifts,
  salary,
  investment,
  other;

  static FinanceCategory parse(String? value) =>
      FinanceCategory.values.asNameMap()[value] ?? FinanceCategory.other;
}

enum InvestmentType {
  funds,
  stocks,
  crypto,
  deposit,
  property,
  other;

  static InvestmentType parse(String? value) =>
      InvestmentType.values.asNameMap()[value] ?? InvestmentType.other;
}

enum PurchasePriority {
  low,
  normal,
  high;

  static PurchasePriority parse(String? value) =>
      PurchasePriority.values.asNameMap()[value] ?? PurchasePriority.normal;
}

/// Límites comunes. Importes en céntimos enteros: nunca `double`.
abstract final class FinanceLimits {
  static const maxAmountCents = 100000000; // 1.000.000,00
  static const maxTextLength = 80;
  static const maxNoteLength = 200;
}

class Movement {
  const Movement({
    required this.id,
    required this.kind,
    required this.amountCents,
    required this.concept,
    required this.category,
    required this.date,
    this.note,
    this.fixedCostId,
    this.investmentId,
    this.pendingPurchaseId,
  });

  final String id;
  final MovementKind kind;
  final int amountCents;
  final String concept;
  final FinanceCategory category;
  final LogicalDate date;
  final String? note;
  final String? fixedCostId;
  final String? investmentId;
  final String? pendingPurchaseId;

  int get signedCents =>
      kind == MovementKind.income ? amountCents : -amountCents;
}

class MovementDraft {
  const MovementDraft({
    required this.kind,
    required this.amountCents,
    required this.concept,
    required this.category,
    required this.date,
    this.note,
    this.fixedCostId,
    this.investmentId,
    this.pendingPurchaseId,
  });

  final MovementKind kind;
  final int amountCents;
  final String concept;
  final FinanceCategory category;
  final LogicalDate date;
  final String? note;
  final String? fixedCostId;
  final String? investmentId;
  final String? pendingPurchaseId;

  bool get isValid =>
      amountCents > 0 &&
      amountCents <= FinanceLimits.maxAmountCents &&
      concept.trim().isNotEmpty &&
      concept.trim().length <= FinanceLimits.maxTextLength &&
      (note == null || note!.length <= FinanceLimits.maxNoteLength);
}

class FixedCost {
  const FixedCost({
    required this.id,
    required this.name,
    required this.amountCents,
    required this.dayOfMonth,
    required this.category,
    required this.active,
    this.loggedMonths = const {},
  });

  final String id;
  final String name;
  final int amountCents;
  final int dayOfMonth;
  final FinanceCategory category;
  final bool active;

  /// Meses (`YYYY-MM`, clave del periodo) en los que ya se registró.
  final Set<String> loggedMonths;

  bool isLoggedIn(String monthKey) => loggedMonths.contains(monthKey);
}

class FixedCostDraft {
  const FixedCostDraft({
    required this.name,
    required this.amountCents,
    required this.dayOfMonth,
    required this.category,
    this.active = true,
  });

  final String name;
  final int amountCents;
  final int dayOfMonth;
  final FinanceCategory category;
  final bool active;

  bool get isValid =>
      name.trim().isNotEmpty &&
      name.trim().length <= FinanceLimits.maxTextLength &&
      amountCents > 0 &&
      amountCents <= FinanceLimits.maxAmountCents &&
      dayOfMonth >= 1 &&
      dayOfMonth <= 28;
}

class Investment {
  const Investment({
    required this.id,
    required this.name,
    required this.type,
    required this.contributedCents,
    required this.currentValueCents,
    this.valueUpdatedAt,
  });

  final String id;
  final String name;
  final InvestmentType type;
  final int contributedCents;
  final int currentValueCents;
  final DateTime? valueUpdatedAt;

  int get returnCents => currentValueCents - contributedCents;

  /// Rentabilidad en tanto por ciento (null sin aportación).
  double? get returnPercent =>
      contributedCents == 0 ? null : returnCents * 100 / contributedCents;
}

class InvestmentDraft {
  const InvestmentDraft({
    required this.name,
    required this.type,
    required this.contributedCents,
    required this.currentValueCents,
  });

  final String name;
  final InvestmentType type;
  final int contributedCents;
  final int currentValueCents;

  bool get isValid =>
      name.trim().isNotEmpty &&
      name.trim().length <= FinanceLimits.maxTextLength &&
      contributedCents >= 0 &&
      contributedCents <= FinanceLimits.maxAmountCents &&
      currentValueCents >= 0 &&
      currentValueCents <= FinanceLimits.maxAmountCents;
}

class PendingPurchase {
  const PendingPurchase({
    required this.id,
    required this.name,
    required this.estimatedCents,
    required this.priority,
    this.targetDate,
    this.boughtAt,
    this.movementId,
  });

  final String id;
  final String name;
  final int estimatedCents;
  final PurchasePriority priority;
  final LogicalDate? targetDate;
  final DateTime? boughtAt;
  final String? movementId;

  bool get isBought => boughtAt != null;
}

class PendingPurchaseDraft {
  const PendingPurchaseDraft({
    required this.name,
    required this.estimatedCents,
    required this.priority,
    this.targetDate,
  });

  final String name;
  final int estimatedCents;
  final PurchasePriority priority;
  final LogicalDate? targetDate;

  bool get isValid =>
      name.trim().isNotEmpty &&
      name.trim().length <= FinanceLimits.maxTextLength &&
      estimatedCents > 0 &&
      estimatedCents <= FinanceLimits.maxAmountCents;
}

/// Orden de compras pendientes: no compradas primero, prioridad alta antes,
/// luego por fecha objetivo (las que tienen antes) y por nombre.
int comparePendingPurchases(PendingPurchase a, PendingPurchase b) {
  if (a.isBought != b.isBought) return a.isBought ? 1 : -1;
  final byPriority = b.priority.index.compareTo(a.priority.index);
  if (byPriority != 0) return byPriority;
  if (a.targetDate != null || b.targetDate != null) {
    if (a.targetDate == null) return 1;
    if (b.targetDate == null) return -1;
    final byDate = a.targetDate!.compareTo(b.targetDate!);
    if (byDate != 0) return byDate;
  }
  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
}
