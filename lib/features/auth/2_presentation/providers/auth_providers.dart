import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/1_domain/domain.dart';
// Los ficheros de providers son la capa de inyección de dependencias:
// único punto de 2_presentation autorizado a importar 3_data.
import 'package:habits/features/auth/3_data/data.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return FirestoreUserProfileRepository();
});

final deviceInfoRepositoryProvider = Provider<DeviceInfoRepository>((ref) {
  return FlutterTimezoneDeviceInfoRepository();
});

final signInUsecaseProvider = Provider<SignInUsecase>((ref) {
  return SignInUsecase(ref.watch(authRepositoryProvider));
});

final signUpUsecaseProvider = Provider<SignUpUsecase>((ref) {
  return SignUpUsecase(ref.watch(authRepositoryProvider));
});

final signOutUsecaseProvider = Provider<SignOutUsecase>((ref) {
  return SignOutUsecase(ref.watch(authRepositoryProvider));
});

final sendPasswordResetUsecaseProvider = Provider<SendPasswordResetUsecase>((
  ref,
) {
  return SendPasswordResetUsecase(ref.watch(authRepositoryProvider));
});

final sendEmailVerificationUsecaseProvider =
    Provider<SendEmailVerificationUsecase>((ref) {
      return SendEmailVerificationUsecase(ref.watch(authRepositoryProvider));
    });

final checkEmailVerifiedUsecaseProvider = Provider<CheckEmailVerifiedUsecase>((
  ref,
) {
  return CheckEmailVerifiedUsecase(ref.watch(authRepositoryProvider));
});

final ensureUserProfileUsecaseProvider = Provider<EnsureUserProfileUsecase>((
  ref,
) {
  return EnsureUserProfileUsecase(
    ref.watch(userProfileRepositoryProvider),
    ref.watch(deviceInfoRepositoryProvider),
  );
});
