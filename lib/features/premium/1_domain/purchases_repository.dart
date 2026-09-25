import 'package:habits/features/premium/0_entity/premium_plan.dart';

/// Compras dentro de la app (App Store / Google Play a través de
/// RevenueCat).
///
/// Es la vía RÁPIDA para saber si el usuario tiene Premium: responde en
/// cuanto la tienda confirma la compra. La vía FIABLE es
/// `users/{uid}.subscription`, que escribe la Cloud Function del webhook y
/// que las reglas de Firestore pueden consultar.
abstract interface class PurchasesRepository {
  /// False si la app se ha compilado sin claves de RevenueCat o la
  /// plataforma no admite compras.
  bool get isAvailable;

  /// Asocia las compras al usuario de Firebase ([userId] = uid).
  Future<void> identify(String userId);

  /// Desasocia al usuario al cerrar sesión.
  Future<void> reset();

  /// Si el entitlement `premium` está activo según la tienda.
  Stream<bool> watchEntitlement();

  Future<List<PremiumPlan>> loadPlans();

  Future<PurchaseOutcome> purchase(PremiumPlan plan);

  /// Restaura compras anteriores (obligatorio en iOS). Devuelve si hay
  /// Premium activo después de restaurar.
  Future<bool> restore();

  /// Página de la tienda para gestionar o cancelar la suscripción.
  Future<Uri?> managementUrl();
}
