import 'package:freezed_annotation/freezed_annotation.dart';

part 'ambito_draft.freezed.dart';

/// Datos que aporta el usuario para crear un ámbito personalizado.
@freezed
abstract class AmbitoDraft with _$AmbitoDraft {
  const factory AmbitoDraft({
    required String name,
    required String emoji,
    required int colorValue,
  }) = _AmbitoDraft;
}
