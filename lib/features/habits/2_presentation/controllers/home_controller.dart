import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';

class HomeController extends AsyncNotifier<HomeSummary> {
  @override
  Future<HomeSummary> build() => _load();

  Future<HomeSummary> _load() async {
    final result = await ref.read(getHomeSummaryUsecaseProvider).execute();
    return switch (result) {
      GetHomeSummarySuccess(:final summary) => summary,
      GetHomeSummaryFailed(:final message) => throw Exception(message),
    };
  }

  /// Marca o desmarca el cumplimiento de hoy para [habitId].
  Future<void> toggleToday(String habitId) async {
    final summary = state.value;
    if (summary == null) return;

    final today = LogicalDay.today();
    final isCompleted = summary.weekLogs.any(
      (log) =>
          log.habitId == habitId && LogicalDay.isSameDay(log.date, today),
    );

    final result =
        await ref.read(toggleHabitCompletionUsecaseProvider).execute(
              habitId: habitId,
              date: today,
              completed: !isCompleted,
            );
    if (!ref.mounted) return;

    switch (result) {
      case ToggleHabitCompletionSuccess():
        state = AsyncData(await _load());
      case ToggleHabitCompletionFailed():
        // El estado previo se mantiene; el fallo se reflejará vía UI cuando
        // exista gestión de errores global (snackbar/toast).
        break;
    }
  }
}

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeSummary>(HomeController.new);
