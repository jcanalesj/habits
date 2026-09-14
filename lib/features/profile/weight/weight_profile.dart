import 'package:flutter/foundation.dart';

enum WeightGoalType { lose, maintain, gain }

enum CalorieSex { female, male, unspecified }

enum ActivityLevel {
  sedentary(1.2),
  light(1.375),
  moderate(1.55),
  active(1.725),
  veryActive(1.9);

  const ActivityLevel(this.multiplier);
  final double multiplier;
}

@immutable
class WeightProfile {
  const WeightProfile({
    required this.currentKg,
    required this.goalKg,
    required this.age,
    required this.heightCm,
    required this.sex,
    required this.activityLevel,
    required this.goalType,
    required this.recommendedCalories,
  });
  final double currentKg, goalKg, heightCm;
  final int age, recommendedCalories;
  final CalorieSex sex;
  final ActivityLevel activityLevel;
  final WeightGoalType goalType;
}

abstract final class CalorieEstimator {
  static int estimate({
    required double weightKg,
    required double heightCm,
    required int age,
    required CalorieSex sex,
    required ActivityLevel activity,
    required WeightGoalType goal,
  }) {
    final constant = switch (sex) {
      CalorieSex.male => 5.0,
      CalorieSex.female => -161.0,
      CalorieSex.unspecified => -78.0,
    };
    final resting = 10 * weightKg + 6.25 * heightCm - 5 * age + constant;
    final maintenance = resting * activity.multiplier;
    final adjusted = switch (goal) {
      WeightGoalType.lose => maintenance * .85,
      WeightGoalType.maintain => maintenance,
      WeightGoalType.gain => maintenance * 1.10,
    };
    return adjusted.round().clamp(1200, 4500);
  }
}
