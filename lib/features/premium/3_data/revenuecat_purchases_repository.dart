import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:habits/features/premium/0_entity/premium_plan.dart';
import 'package:habits/features/premium/1_domain/purchases_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// [PurchasesRepository] sobre RevenueCat.
class RevenueCatPurchasesRepository implements PurchasesRepository {
  RevenueCatPurchasesRepository(this._apiKey);

  /// Entitlement que desbloquea Premium (mismo nombre en RevenueCat y en la
  /// Cloud Function del webhook).
  static const entitlementId = 'premium';

  final String _apiKey;
  Future<void>? _configured;
  final _entitlement = StreamController<bool>.broadcast();
  bool? _lastEntitlement;

  @override
  bool get isAvailable => true;

  Future<void> _ensureConfigured() => _configured ??= () async {
    await Purchases.configure(PurchasesConfiguration(_apiKey));
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
  }();

  void _onCustomerInfo(CustomerInfo info) {
    final active = info.entitlements.active.containsKey(entitlementId);
    _lastEntitlement = active;
    _entitlement.add(active);
  }

  @override
  Future<void> identify(String userId) async {
    await _ensureConfigured();
    final result = await Purchases.logIn(userId);
    _onCustomerInfo(result.customerInfo);
  }

  @override
  Future<void> reset() async {
    if (_configured == null) return;
    await _ensureConfigured();
    try {
      if (!await Purchases.isAnonymous) await Purchases.logOut();
    } on PlatformException catch (error) {
      debugPrint('RevenueCat logOut: $error');
    }
    _lastEntitlement = false;
    _entitlement.add(false);
  }

  @override
  Stream<bool> watchEntitlement() async* {
    if (_lastEntitlement != null) yield _lastEntitlement!;
    yield* _entitlement.stream;
  }

  @override
  Future<List<PremiumPlan>> loadPlans() async {
    await _ensureConfigured();
    final offering = (await Purchases.getOfferings()).current;
    if (offering == null) return const [];
    _packages = {
      for (final package in offering.availablePackages)
        package.identifier: package,
    };
    return [
      for (final package in offering.availablePackages)
        PremiumPlan(
          id: package.identifier,
          period: switch (package.packageType) {
            PackageType.monthly => PremiumPlanPeriod.monthly,
            PackageType.annual => PremiumPlanPeriod.annual,
            PackageType.lifetime => PremiumPlanPeriod.lifetime,
            _ => PremiumPlanPeriod.other,
          },
          priceLabel: package.storeProduct.priceString,
          trialLength: _freeTrial(package)?.periodNumberOfUnits,
          trialUnit: switch (_freeTrial(package)?.periodUnit) {
            PeriodUnit.day => TrialUnit.day,
            PeriodUnit.week => TrialUnit.week,
            PeriodUnit.month => TrialUnit.month,
            PeriodUnit.year => TrialUnit.year,
            _ => null,
          },
        ),
    ];
  }

  Map<String, Package> _packages = const {};

  static IntroductoryPrice? _freeTrial(Package package) {
    final intro = package.storeProduct.introductoryPrice;
    return intro != null && intro.price == 0 ? intro : null;
  }

  @override
  Future<PurchaseOutcome> purchase(PremiumPlan plan) async {
    final package = _packages[plan.id];
    if (package == null) return PurchaseOutcome.failed;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _onCustomerInfo(result.customerInfo);
      return result.customerInfo.entitlements.active.containsKey(entitlementId)
          ? PurchaseOutcome.purchased
          : PurchaseOutcome.failed;
    } on PlatformException catch (error) {
      return switch (PurchasesErrorHelper.getErrorCode(error)) {
        PurchasesErrorCode.purchaseCancelledError => PurchaseOutcome.cancelled,
        PurchasesErrorCode.purchaseNotAllowedError ||
        PurchasesErrorCode.storeProblemError => PurchaseOutcome.unavailable,
        _ => PurchaseOutcome.failed,
      };
    }
  }

  @override
  Future<bool> restore() async {
    await _ensureConfigured();
    final info = await Purchases.restorePurchases();
    _onCustomerInfo(info);
    return info.entitlements.active.containsKey(entitlementId);
  }

  @override
  Future<Uri?> managementUrl() async {
    await _ensureConfigured();
    final url = (await Purchases.getCustomerInfo()).managementURL;
    return url == null ? null : Uri.tryParse(url);
  }
}

/// Sin claves de RevenueCat (desarrollo, tests, plataformas sin tienda):
/// no se puede comprar y nadie obtiene Premium por esta vía.
class UnavailablePurchasesRepository implements PurchasesRepository {
  const UnavailablePurchasesRepository();

  @override
  bool get isAvailable => false;

  @override
  Future<void> identify(String userId) async {}

  @override
  Future<void> reset() async {}

  @override
  Stream<bool> watchEntitlement() => Stream.value(false);

  @override
  Future<List<PremiumPlan>> loadPlans() async => const [];

  @override
  Future<PurchaseOutcome> purchase(PremiumPlan plan) async =>
      PurchaseOutcome.unavailable;

  @override
  Future<bool> restore() async => false;

  @override
  Future<Uri?> managementUrl() async => null;
}
