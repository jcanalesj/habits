enum HabitTrackingType { single, repetitions }

extension HabitTrackingTypeX on HabitTrackingType {
  String get storageValue => name;

  static HabitTrackingType fromStorage(Object? value) =>
      value == HabitTrackingType.repetitions.name
      ? HabitTrackingType.repetitions
      : HabitTrackingType.single;
}
