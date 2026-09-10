import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
// Los ficheros de providers son la capa de inyección de dependencias:
// único punto de 2_presentation autorizado a importar 3_data.
import 'package:habits/features/auth/3_data/data.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final signInUsecaseProvider = Provider<SignInUsecase>((ref) {
  return SignInUsecase(ref.read(authRepositoryProvider));
});
