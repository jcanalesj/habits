/// Estimaciones a partir de los pasos. Usa el perfil de peso cuando existe
/// (altura para la zancada, peso para las calorías) y valores medios si no.
abstract final class StepsEstimator {
  static const defaultStrideMeters = 0.74;
  static const defaultWeightKg = 70.0;

  /// Zancada media ≈ 41,4 % de la altura.
  static double strideMeters(double? heightCm) =>
      heightCm == null ? defaultStrideMeters : heightCm / 100 * 0.414;

  static int distanceMeters(int steps, {double? heightCm}) =>
      (steps * strideMeters(heightCm)).round();

  /// Caminar cuesta ≈ 0,57 kcal por kilo y kilómetro.
  static int calories(int distanceMeters, {double? weightKg}) =>
      (distanceMeters / 1000 * (weightKg ?? defaultWeightKg) * 0.57).round();
}
