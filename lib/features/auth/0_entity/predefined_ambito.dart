import 'package:freezed_annotation/freezed_annotation.dart';

part 'predefined_ambito.freezed.dart';

/// Ámbito predefinido que se siembra en `users/{uid}/ambitos` al crear el
/// perfil (doc funcional §4.4). El id debe ser uno de los que las Security
/// Rules reconocen como predefinidos.
@freezed
abstract class PredefinedAmbito with _$PredefinedAmbito {
  const factory PredefinedAmbito({
    required String id,
    required String name,
    required String emoji,
    required int colorValue,
    required int order,
  }) = _PredefinedAmbito;
}
