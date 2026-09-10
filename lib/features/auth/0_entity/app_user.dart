import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// Usuario autenticado de la app.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    @Default(false) bool emailVerified,
  }) = _AppUser;
}
