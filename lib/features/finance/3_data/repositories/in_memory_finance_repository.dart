import 'dart:async';

import 'package:habits/features/finance/0_entity/entity.dart';
import 'package:habits/features/finance/1_domain/domain.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

class InMemoryFinanceRepository implements FinanceRepository {
  InMemoryFinanceRepository({FinanceConfig? config, DateTime Function()? now})
    : _config = config ?? const FinanceConfig(),
      _now = now ?? DateTime.now;

  FinanceConfig _config;
  final DateTime Function() _now;
  final movements = <String, Movement>{};
  final fixedCosts = <String, FixedCost>{};
  final investments = <String, Investment>{};
  final purchases = <String, PendingPurchase>{};
  final _configController = StreamController<FinanceConfig>.broadcast();
  final _changes = StreamController<void>.broadcast();
  int _sequence = 0;

  String _nextId(String prefix) => '$prefix-${++_sequence}';
  void _emit() => _changes.add(null);

  Stream<T> _watch<T>(T Function() select) async* {
    yield select();
    yield* _changes.stream.map((_) => select());
  }

  @override
  Stream<FinanceConfig> watchConfig() async* {
    yield _config;
    yield* _configController.stream;
  }

  @override
  Future<void> saveConfig(FinanceConfig config) async {
    _config = config;
    _configController.add(config);
  }

  @override
  Stream<List<Movement>> watchMovementsBetween(
    LogicalDate from,
    LogicalDate to,
  ) => _watch(
    () =>
        movements.values
            .where((m) => m.date.isAtOrAfter(from) && m.date.isAtOrBefore(to))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)),
  );

  Movement _movement(String id, MovementDraft draft) => Movement(
    id: id,
    kind: draft.kind,
    amountCents: draft.amountCents,
    concept: draft.concept.trim(),
    category: draft.category,
    date: draft.date,
    note: draft.note,
    fixedCostId: draft.fixedCostId,
    investmentId: draft.investmentId,
    pendingPurchaseId: draft.pendingPurchaseId,
  );

  @override
  Future<String> addMovement(MovementDraft draft) async {
    final id = _nextId('mov');
    movements[id] = _movement(id, draft);
    _emit();
    return id;
  }

  @override
  Future<void> updateMovement(String id, MovementDraft draft) async {
    if (!movements.containsKey(id)) return;
    movements[id] = _movement(id, draft);
    _emit();
  }

  @override
  Future<void> deleteMovement(String id) async {
    movements.remove(id);
    _emit();
  }

  @override
  Stream<List<FixedCost>> watchFixedCosts() => _watch(
    () =>
        fixedCosts.values.toList()
          ..sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth)),
  );

  FixedCost _fixed(String id, FixedCostDraft draft, Set<String> logged) =>
      FixedCost(
        id: id,
        name: draft.name.trim(),
        amountCents: draft.amountCents,
        dayOfMonth: draft.dayOfMonth,
        category: draft.category,
        active: draft.active,
        loggedMonths: logged,
      );

  @override
  Future<String> addFixedCost(FixedCostDraft draft) async {
    final id = _nextId('fix');
    fixedCosts[id] = _fixed(id, draft, const {});
    _emit();
    return id;
  }

  @override
  Future<void> updateFixedCost(String id, FixedCostDraft draft) async {
    final current = fixedCosts[id];
    if (current == null) return;
    fixedCosts[id] = _fixed(id, draft, current.loggedMonths);
    _emit();
  }

  @override
  Future<void> deleteFixedCost(String id) async {
    fixedCosts.remove(id);
    _emit();
  }

  @override
  Future<void> logFixedCost(
    FixedCost cost, {
    required String monthKey,
    required LogicalDate date,
  }) async {
    await addMovement(
      MovementDraft(
        kind: MovementKind.expense,
        amountCents: cost.amountCents,
        concept: cost.name,
        category: cost.category,
        date: date,
        fixedCostId: cost.id,
      ),
    );
    fixedCosts[cost.id] = FixedCost(
      id: cost.id,
      name: cost.name,
      amountCents: cost.amountCents,
      dayOfMonth: cost.dayOfMonth,
      category: cost.category,
      active: cost.active,
      loggedMonths: {...cost.loggedMonths, monthKey},
    );
    _emit();
  }

  @override
  Stream<List<Investment>> watchInvestments() => _watch(
    () =>
        investments.values.toList()
          ..sort((a, b) => b.currentValueCents.compareTo(a.currentValueCents)),
  );

  @override
  Future<String> addInvestment(InvestmentDraft draft) async {
    final id = _nextId('inv');
    investments[id] = Investment(
      id: id,
      name: draft.name.trim(),
      type: draft.type,
      contributedCents: draft.contributedCents,
      currentValueCents: draft.currentValueCents,
      valueUpdatedAt: _now(),
    );
    _emit();
    return id;
  }

  @override
  Future<void> updateInvestment(String id, InvestmentDraft draft) async {
    if (!investments.containsKey(id)) return;
    investments[id] = Investment(
      id: id,
      name: draft.name.trim(),
      type: draft.type,
      contributedCents: draft.contributedCents,
      currentValueCents: draft.currentValueCents,
      valueUpdatedAt: _now(),
    );
    _emit();
  }

  @override
  Future<void> deleteInvestment(String id) async {
    investments.remove(id);
    _emit();
  }

  @override
  Future<void> updateInvestmentValue(String id, int currentValueCents) async {
    final current = investments[id];
    if (current == null) return;
    investments[id] = Investment(
      id: id,
      name: current.name,
      type: current.type,
      contributedCents: current.contributedCents,
      currentValueCents: currentValueCents,
      valueUpdatedAt: _now(),
    );
    _emit();
  }

  @override
  Future<void> contributeToInvestment(
    Investment investment,
    int cents, {
    LogicalDate? movementDate,
  }) async {
    investments[investment.id] = Investment(
      id: investment.id,
      name: investment.name,
      type: investment.type,
      contributedCents: investment.contributedCents + cents,
      currentValueCents: investment.currentValueCents + cents,
      valueUpdatedAt: _now(),
    );
    if (movementDate != null) {
      await addMovement(
        MovementDraft(
          kind: MovementKind.expense,
          amountCents: cents,
          concept: investment.name,
          category: FinanceCategory.investment,
          date: movementDate,
          investmentId: investment.id,
        ),
      );
    }
    _emit();
  }

  @override
  Stream<List<PendingPurchase>> watchPendingPurchases() =>
      _watch(() => purchases.values.toList()..sort(comparePendingPurchases));

  @override
  Future<String> addPendingPurchase(PendingPurchaseDraft draft) async {
    final id = _nextId('buy');
    purchases[id] = PendingPurchase(
      id: id,
      name: draft.name.trim(),
      estimatedCents: draft.estimatedCents,
      priority: draft.priority,
      targetDate: draft.targetDate,
    );
    _emit();
    return id;
  }

  @override
  Future<void> updatePendingPurchase(
    String id,
    PendingPurchaseDraft draft,
  ) async {
    final current = purchases[id];
    if (current == null) return;
    purchases[id] = PendingPurchase(
      id: id,
      name: draft.name.trim(),
      estimatedCents: draft.estimatedCents,
      priority: draft.priority,
      targetDate: draft.targetDate,
      boughtAt: current.boughtAt,
      movementId: current.movementId,
    );
    _emit();
  }

  @override
  Future<void> deletePendingPurchase(String id) async {
    purchases.remove(id);
    _emit();
  }

  @override
  Future<void> markPurchased(
    PendingPurchase purchase, {
    required int amountCents,
    required LogicalDate date,
  }) async {
    final movementId = await addMovement(
      MovementDraft(
        kind: MovementKind.expense,
        amountCents: amountCents,
        concept: purchase.name,
        category: FinanceCategory.other,
        date: date,
        pendingPurchaseId: purchase.id,
      ),
    );
    purchases[purchase.id] = PendingPurchase(
      id: purchase.id,
      name: purchase.name,
      estimatedCents: purchase.estimatedCents,
      priority: purchase.priority,
      targetDate: purchase.targetDate,
      boughtAt: _now(),
      movementId: movementId,
    );
    _emit();
  }

  void dispose() {
    _configController.close();
    _changes.close();
  }
}
