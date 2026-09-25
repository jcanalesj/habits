/// Unidad de la prueba gratuita.
enum TrialUnit { day, week, month, year }

/// Periodo de facturación de un plan.
enum PremiumPlanPeriod { monthly, annual, lifetime, other }

/// Un plan que se puede comprar, con los precios ya formateados por la
/// tienda (moneda e impuestos del país del usuario).
class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.period,
    required this.priceLabel,
    this.trialLength,
    this.trialUnit,
  });

  /// Identificador del paquete en RevenueCat.
  final String id;
  final PremiumPlanPeriod period;

  /// Precio tal cual lo muestra la tienda, p. ej. "29,99 €".
  final String priceLabel;

  /// Prueba gratuita, si la hay: [trialLength] × [trialUnit].
  final int? trialLength;
  final TrialUnit? trialUnit;

  bool get hasTrial => trialLength != null && trialUnit != null;
}

/// Resultado de una compra.
enum PurchaseOutcome { purchased, cancelled, failed, unavailable }
