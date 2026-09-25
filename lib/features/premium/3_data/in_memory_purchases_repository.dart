import 'dart:async';

import 'package:habits/features/premium/0_entity/premium_plan.dart';
import 'package:habits/features/premium/1_domain/purchases_repository.dart';

/// Tienda simulada para tests.
class InMemoryPurchasesRepository implements PurchasesRepository {
  InMemoryPurchasesRepository({
    this.plans = const [
      PremiumPlan(
        id: 'monthly',
        period: PremiumPlanPeriod.monthly,
        priceLabel: '2,99 €',
      ),
      PremiumPlan(
        id: 'annual',
        period: PremiumPlanPeriod.annual,
        priceLabel: '19,99 €',
        trialLength: 1,
        trialUnit: TrialUnit.week,
      ),
    ],
    this.nextOutcome = PurchaseOutcome.purchased,
    this.restorable = false,
  });

  final List<PremiumPlan> plans;
  PurchaseOutcome nextOutcome;
  bool restorable;
  String? identifiedUser;
  bool _active = false;
  final _entitlement = StreamController<bool>.broadcast();

  @override
  bool get isAvailable => true;

  @override
  Future<void> identify(String userId) async => identifiedUser = userId;

  @override
  Future<void> reset() async {
    identifiedUser = null;
    _set(false);
  }

  @override
  Stream<bool> watchEntitlement() async* {
    yield _active;
    yield* _entitlement.stream;
  }

  @override
  Future<List<PremiumPlan>> loadPlans() async => plans;

  @override
  Future<PurchaseOutcome> purchase(PremiumPlan plan) async {
    if (nextOutcome == PurchaseOutcome.purchased) _set(true);
    return nextOutcome;
  }

  @override
  Future<bool> restore() async {
    if (restorable) _set(true);
    return _active;
  }

  @override
  Future<Uri?> managementUrl() async =>
      Uri.parse('https://apps.apple.com/account/subscriptions');

  void _set(bool active) {
    _active = active;
    _entitlement.add(active);
  }
}
