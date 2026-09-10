import 'package:freezed_annotation/freezed_annotation.dart';

part 'ambito.freezed.dart';

/// Ámbito/etiqueta que agrupa hábitos. Cada ámbito tiene su propia racha
/// y un único comodín de renovación semanal fija (sección 5.3).
@freezed
abstract class Ambito with _$Ambito {
  const factory Ambito({
    required String id,
    required String name,
    required String emoji,
    required int colorValue,
    @Default(false) bool isPredefined,
    @Default(0) int currentStreak,
    @Default(0) int bestStreak,
    @Default(true) bool comodinDisponible,
  }) = _Ambito;
}
