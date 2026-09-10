import 'package:freezed_annotation/freezed_annotation.dart';

part 'ambito.freezed.dart';

/// Ámbito/etiqueta que agrupa hábitos. Solo configuración: las rachas y el
/// comodín son datos derivados de los registros y viven en [StreaksSnapshot].
@freezed
abstract class Ambito with _$Ambito {
  const factory Ambito({
    required String id,
    required String name,
    required String emoji,
    required int colorValue,
    @Default(false) bool isPredefined,
    @Default(0) int order,
    DateTime? createdAt,
  }) = _Ambito;

  const Ambito._();

  /// Id fijo del ámbito de reasignación, que no puede eliminarse.
  static const generalId = 'general';

  bool get isGeneral => id == generalId;
}
