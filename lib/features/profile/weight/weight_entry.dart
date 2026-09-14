import 'package:flutter/foundation.dart';

@immutable
class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.kilograms,
    required this.recordedAt,
  });

  final String id;
  final double kilograms;
  final DateTime recordedAt;
}
