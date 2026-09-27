enum HabitKind { build, quit }

extension HabitKindX on HabitKind {
  String get storageValue => name;

  static HabitKind fromStorage(String? value) =>
      value == HabitKind.quit.name ? HabitKind.quit : HabitKind.build;
}
