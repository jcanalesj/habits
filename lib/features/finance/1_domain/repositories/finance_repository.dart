import 'package:habits/features/finance/0_entity/entity.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

abstract class FinanceRepository {
  Stream<FinanceConfig> watchConfig();
  Future<void> saveConfig(FinanceConfig config);

  Stream<List<Movement>> watchMovementsBetween(
    LogicalDate from,
    LogicalDate to,
  );
  Future<String> addMovement(MovementDraft draft);
  Future<void> updateMovement(String id, MovementDraft draft);
  Future<void> deleteMovement(String id);

  Stream<List<FixedCost>> watchFixedCosts();
  Future<String> addFixedCost(FixedCostDraft draft);
  Future<void> updateFixedCost(String id, FixedCostDraft draft);
  Future<void> deleteFixedCost(String id);

  /// Crea el movimiento del mes y marca el fijo como registrado en
  /// [monthKey]. Una sola escritura.
  Future<void> logFixedCost(
    FixedCost cost, {
    required String monthKey,
    required LogicalDate date,
  });

  Stream<List<Investment>> watchInvestments();
  Future<String> addInvestment(InvestmentDraft draft);
  Future<void> updateInvestment(String id, InvestmentDraft draft);
  Future<void> deleteInvestment(String id);
  Future<void> updateInvestmentValue(String id, int currentValueCents);

  /// Suma [cents] a lo aportado y, si [movementDate] no es null, registra
  /// el gasto con categoría Inversión.
  Future<void> contributeToInvestment(
    Investment investment,
    int cents, {
    LogicalDate? movementDate,
  });

  Stream<List<PendingPurchase>> watchPendingPurchases();
  Future<String> addPendingPurchase(PendingPurchaseDraft draft);
  Future<void> updatePendingPurchase(String id, PendingPurchaseDraft draft);
  Future<void> deletePendingPurchase(String id);

  /// Registra el gasto real y marca la compra como hecha.
  Future<void> markPurchased(
    PendingPurchase purchase, {
    required int amountCents,
    required LogicalDate date,
  });
}
