import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/profile/weight/weight_providers.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/1_domain/domain.dart';
import 'package:habits/features/steps/2_presentation/controllers/steps_controller.dart';
// Capa de inyección de dependencias: único punto autorizado a importar 3_data.
import 'package:habits/features/steps/3_data/data.dart';
import 'package:habits/local_preferences.dart';

final stepsRepositoryProvider = Provider.autoDispose<StepsRepository>((ref) {
  final userId = ref.read(authControllerProvider).value?.id ?? 'anonymous';
  return FirestoreStepsRepository(userId: userId);
});

/// Contador nativo. Se crea perezosamente: en web y escritorio la
/// herramienta no aparece y nunca se instancia.
final pedometerSourceProvider = Provider<PedometerSource>(
  (ref) => PlatformPedometerSource(),
);

final stepLedgerStoreProvider = Provider<StepLedgerStore>((ref) {
  final userId = ref.watch(authControllerProvider).value?.id ?? 'anonymous';
  final preferences = ref.watch(sharedPreferencesProvider);
  if (preferences == null) return InMemoryStepLedgerStore();
  return SharedStepLedgerStore(preferences, userId: userId);
});

final stepsConfigProvider = StreamProvider.autoDispose<StepsConfig>(
  (ref) => ref.watch(stepsRepositoryProvider).watchConfig(),
);

/// Últimos siete días guardados en la cuenta (hoy incluido).
final storedStepsDaysProvider = StreamProvider.autoDispose<List<StepsDay>>((
  ref,
) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(stepsRepositoryProvider)
      .watchDaysBetween(
        today.addDays(-(StepsController.historyDays - 1)),
        today,
      );
});

final stepsControllerProvider =
    NotifierProvider.autoDispose<StepsController, StepsState>(
      StepsController.new,
    );

/// Rangos del histórico.
enum StepsRange { week, month, year, all }

/// Días guardados en un rango (histórico completo con [StepsRange.all]).
final stepsHistoryProvider = StreamProvider.autoDispose
    .family<List<StepsDay>, StepsRange>((ref, range) {
      final today = ref.watch(todayProvider);
      final from = switch (range) {
        StepsRange.week => today.addDays(-6),
        StepsRange.month => today.addDays(-29),
        StepsRange.year => today.addDays(-364),
        StepsRange.all => const LogicalDate(2020, 1, 1),
      };
      return ref
          .watch(stepsRepositoryProvider)
          .watchDaysBetween(from, today)
          .map((days) => days..sort((a, b) => a.day.compareTo(b.day)));
    });

/// Altura y peso del perfil de peso, si existen, para zancada y calorías.
final stepsBodyProvider =
    Provider.autoDispose<({double? heightCm, double? weightKg})>((ref) {
      final profile = ref.watch(weightProfileProvider).value;
      return (heightCm: profile?.heightCm, weightKg: profile?.currentKg);
    });

/// Dato vivo del panel: "6.240 / 8.000" a partir de lo guardado, sin tocar
/// el sensor ni pedir permisos desde el panel.
final todayStepsSummaryProvider =
    Provider.autoDispose<({int steps, int goal})?>((ref) {
      final config = ref.watch(stepsConfigProvider).value;
      final stored = ref.watch(storedStepsDaysProvider).value;
      if (config == null || stored == null || !config.consented) return null;
      final today = ref.watch(todayProvider);
      final entry = stored.where((day) => day.day == today).firstOrNull;
      return (steps: entry?.steps ?? 0, goal: config.goal);
    });

String stepsCelebratedKey(String userId) => 'steps_celebrated_$userId';
