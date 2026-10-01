import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/1_domain/repositories/notifications_repository.dart';
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

/// Canal nativo de la notificación fija de pasos (solo Android).
final stepsLiveNotificationProvider = Provider<StepsLiveNotification>(
  (ref) => PlatformStepsLiveNotification(),
);

/// Si esta plataforma puede mostrar los pasos en la barra de notificaciones.
final stepsLiveNotificationSupportedProvider = FutureProvider<bool>(
  (ref) => ref.watch(stepsLiveNotificationProvider).isSupported(),
);

/// Interruptor "pasos en la barra de notificaciones". El estado real vive
/// en el lado nativo (sobrevive a cerrar la app): aquí solo se consulta y
/// se mantiene al día la configuración que el servicio necesita.
final stepsLiveNotificationEnabledProvider =
    AsyncNotifierProvider<StepsLiveNotificationController, bool>(
      StepsLiveNotificationController.new,
    );

class StepsLiveNotificationController extends AsyncNotifier<bool> {
  StepsLiveNotificationLabels? _labels;
  String? _locale;

  @override
  Future<bool> build() async {
    // Objetivo o perfil nuevos: el servicio se reconfigura solo. Solo
    // mientras alguien observa este provider (la página de Pasos): sin
    // observadores queda en pausa, así que al volver se reenvía todo.
    ref.listen(stepsConfigProvider, (_, _) => _pushUpdate());
    ref.listen(stepsBodyProvider, (_, _) => _pushUpdate());
    // La zona marca dónde corta el día el servicio.
    ref.listen(profileTimezoneProvider, (_, _) => _pushUpdate());
    ref.onResume(_pushUpdate);
    return ref.watch(stepsLiveNotificationProvider).isEnabled();
  }

  StepsLiveNotificationConfig _config() {
    final body = ref.read(stepsBodyProvider);
    return StepsLiveNotificationConfig(
      userId: ref.read(authControllerProvider).value?.id ?? 'anonymous',
      goal:
          ref.read(stepsConfigProvider).value?.goal ?? StepsConfig.defaultGoal,
      strideMeters: StepsEstimator.strideMeters(body.heightCm),
      weightKg: body.weightKg ?? StepsEstimator.defaultWeightKg,
      timezone: ref.read(logicalCalendarProvider).timezoneName,
      locale: _locale ?? 'es',
      labels: _labels!,
    );
  }

  /// Enciende la notificación. Pide antes el permiso de notificaciones del
  /// sistema (Android 13+) y devuelve por qué no se ha podido, si no.
  Future<StepsLiveNotificationResult> enable({
    required StepsLiveNotificationLabels labels,
    required String locale,
  }) async {
    final permission = await ref
        .read(notificationsRepositoryProvider)
        .requestPermission();
    if (permission == NotificationPermission.denied) {
      return StepsLiveNotificationResult.notificationsDenied;
    }
    _labels = labels;
    _locale = locale;
    final result = await ref
        .read(stepsLiveNotificationProvider)
        .start(_config());
    state = AsyncData(result == StepsLiveNotificationResult.started);
    return result;
  }

  Future<void> disable() async {
    await ref.read(stepsLiveNotificationProvider).stop();
    state = const AsyncData(false);
  }

  Future<void> _pushUpdate() async {
    if (state.value != true || _labels == null) return;
    await ref.read(stepsLiveNotificationProvider).update(_config());
  }
}
