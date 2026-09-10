import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';

/// Estado de la Home, alimentado por snapshots del repositorio: cualquier
/// escritura (local u otro dispositivo) se refleja sola, sin recargas.
class HomeController extends StreamNotifier<HomeSummary> {
  @override
  Stream<HomeSummary> build() =>
      ref.watch(watchHomeSummaryUsecaseProvider).execute();

  /// Marca o desmarca el cumplimiento de hoy para [habitId]. El estado
  /// "completado" se decide por los registros, nunca por la caché de rachas.
  Future<ToggleHabitCompletionResult?> toggleToday(String habitId) async {
    final summary = state.value;
    if (summary == null) return null;

    final today = LogicalDay.today();
    final result = await ref
        .read(toggleHabitCompletionUsecaseProvider)
        .execute(
          habitId: habitId,
          date: today,
          completed: !summary.isCompletedOn(habitId, today),
        );
    if (!ref.mounted) return result;

    // Con éxito no hay nada que hacer: el snapshot actualizará el estado.
    // Si falla, el estado previo se mantiene; la gestión visual de errores
    // llegará con la infraestructura global de snackbars.
    return result;
  }
}

/// autoDispose: muere con la Home (p. ej. al cerrar sesión) para que no
/// queden suscripciones a Firestore ni cadenas de providers obsoletas.
final homeControllerProvider =
    StreamNotifierProvider.autoDispose<HomeController, HomeSummary>(
      HomeController.new,
    );
