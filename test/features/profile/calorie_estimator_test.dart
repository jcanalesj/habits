import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/profile/weight/weight_profile.dart';

void main() {
  test('calcula mantenimiento con Mifflin-St Jeor y actividad', () {
    final calories = CalorieEstimator.estimate(
      weightKg: 70,
      heightCm: 170,
      age: 30,
      sex: CalorieSex.female,
      activity: ActivityLevel.moderate,
      goal: WeightGoalType.maintain,
    );
    expect(calories, 2250);
  });

  test('perder y ganar aplican ajustes moderados', () {
    int estimate(WeightGoalType goal) => CalorieEstimator.estimate(
      weightKg: 80,
      heightCm: 180,
      age: 35,
      sex: CalorieSex.male,
      activity: ActivityLevel.moderate,
      goal: goal,
    );

    expect(
      estimate(WeightGoalType.lose),
      lessThan(estimate(WeightGoalType.maintain)),
    );
    expect(
      estimate(WeightGoalType.gain),
      greaterThan(estimate(WeightGoalType.maintain)),
    );
  });
}
