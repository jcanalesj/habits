import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
// Los ficheros de providers son la capa de inyección de dependencias:
// son el único punto de 2_presentation autorizado a importar 3_data.
import 'package:habits/features/habits/3_data/data.dart';

/// Repositorio de hábitos del usuario con sesión.
///
/// Toda la cadena de hábitos (repositorio → usecases → HomeController) es
/// `autoDispose` y lee el usuario UNA vez al crearse: la Home solo existe
/// con sesión verificada y, al cerrar sesión, se desmonta y la cadena se
/// destruye, de modo que el siguiente usuario la crea de cero. Así ningún
/// provider se invalida "fuera de banda" por el stream de sesión, lo que en
/// Riverpod 3 provoca reconstrucciones perezosas durante el build de la Home
/// ("markNeedsBuild called during build").
final habitsRepositoryProvider = Provider.autoDispose<HabitsRepository>((ref) {
  final userId = ref.read(authControllerProvider).value?.id;
  return FirestoreHabitsRepository(
    userId: userId ?? FirestoreHabitsRepository.anonymousUserId,
  );
});

final watchHomeSummaryUsecaseProvider =
    Provider.autoDispose<WatchHomeSummaryUsecase>((ref) {
      return WatchHomeSummaryUsecase(ref.watch(habitsRepositoryProvider));
    });

final toggleHabitCompletionUsecaseProvider =
    Provider.autoDispose<ToggleHabitCompletionUsecase>((ref) {
      return ToggleHabitCompletionUsecase(ref.watch(habitsRepositoryProvider));
    });

final createHabitUsecaseProvider = Provider.autoDispose<CreateHabitUsecase>((
  ref,
) {
  return CreateHabitUsecase(ref.watch(habitsRepositoryProvider));
});

final updateHabitUsecaseProvider = Provider.autoDispose<UpdateHabitUsecase>((
  ref,
) {
  return UpdateHabitUsecase(ref.watch(habitsRepositoryProvider));
});

final deleteHabitUsecaseProvider = Provider.autoDispose<DeleteHabitUsecase>((
  ref,
) {
  return DeleteHabitUsecase(ref.watch(habitsRepositoryProvider));
});

final createAmbitoUsecaseProvider = Provider.autoDispose<CreateAmbitoUsecase>((
  ref,
) {
  return CreateAmbitoUsecase(ref.watch(habitsRepositoryProvider));
});

final updateAmbitoUsecaseProvider = Provider.autoDispose<UpdateAmbitoUsecase>((
  ref,
) {
  return UpdateAmbitoUsecase(ref.watch(habitsRepositoryProvider));
});

final deleteAmbitoUsecaseProvider = Provider.autoDispose<DeleteAmbitoUsecase>((
  ref,
) {
  return DeleteAmbitoUsecase(ref.watch(habitsRepositoryProvider));
});

final getHabitLogsUsecaseProvider = Provider.autoDispose<GetHabitLogsUsecase>((
  ref,
) {
  return GetHabitLogsUsecase(ref.watch(habitsRepositoryProvider));
});

/// Nombre del usuario mostrado en el saludo: nickname de la cuenta o, si no
/// lo tiene, la parte local del email.
final userNameProvider = Provider<String>((ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return '';
  final displayName = user.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) return displayName;
  return user.email.split('@').first;
});
