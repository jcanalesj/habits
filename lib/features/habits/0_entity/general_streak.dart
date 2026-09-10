import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_streak.freezed.dart';

/// Racha general de la app (estilo Duolingo): se mantiene registrando
/// cualquier hábito cada día. 1 comodín gratuito por semana (sección 5.1).
@freezed
abstract class GeneralStreak with _$GeneralStreak {
  const factory GeneralStreak({
    @Default(0) int count,
    @Default(true) bool comodinDisponible,
    DateTime? lastLogDate,
  }) = _GeneralStreak;
}
