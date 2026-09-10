import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
// Los ficheros de providers son la capa de inyección de dependencias:
// son el único punto de 2_presentation autorizado a importar 3_data.
import 'package:habits/features/habits/3_data/data.dart';

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return InMemoryHabitsRepository();
});

final getHomeSummaryUsecaseProvider = Provider<GetHomeSummaryUsecase>((ref) {
  return GetHomeSummaryUsecase(ref.read(habitsRepositoryProvider));
});

final toggleHabitCompletionUsecaseProvider =
    Provider<ToggleHabitCompletionUsecase>((ref) {
  return ToggleHabitCompletionUsecase(ref.read(habitsRepositoryProvider));
});

/// Nombre del usuario mostrado en el saludo. Stub hasta que exista la
/// feature de autenticación (sección 8 del documento funcional).
final userNameProvider = Provider<String>((ref) => 'Alex');
