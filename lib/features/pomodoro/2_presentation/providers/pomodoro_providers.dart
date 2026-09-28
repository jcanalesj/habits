import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/features/pomodoro/0_entity/entity.dart';
import 'package:habits/features/pomodoro/1_domain/domain.dart';
import 'package:habits/features/pomodoro/2_presentation/controllers/pomodoro_controller.dart';
// Capa de inyección de dependencias: único punto autorizado a importar 3_data.
import 'package:habits/features/pomodoro/3_data/data.dart';
import 'package:habits/local_preferences.dart';

final pomodoroRepositoryProvider = Provider.autoDispose<PomodoroRepository>((
  ref,
) {
  final userId = ref.read(authControllerProvider).value?.id ?? 'anonymous';
  return FirestorePomodoroRepository(userId: userId);
});

final pomodoroStateStoreProvider = Provider<PomodoroStateStore>((ref) {
  final userId = ref.watch(authControllerProvider).value?.id ?? 'anonymous';
  final preferences = ref.watch(sharedPreferencesProvider);
  if (preferences == null) return InMemoryPomodoroStateStore();
  return SharedPomodoroStateStore(preferences, userId: userId);
});

final pomodoroConfigProvider = StreamProvider.autoDispose<PomodoroConfig>(
  (ref) => ref.watch(pomodoroRepositoryProvider).watchConfig(),
);

/// Sesiones de hoy.
final todayPomodoroSessionsProvider =
    StreamProvider.autoDispose<List<PomodoroSession>>((ref) {
      final today = ref.watch(todayProvider);
      return ref
          .watch(pomodoroRepositoryProvider)
          .watchSessionsBetween(today, today);
    });

/// Sesiones de la semana en curso (lunes a hoy).
final weekPomodoroSessionsProvider =
    StreamProvider.autoDispose<List<PomodoroSession>>((ref) {
      final today = ref.watch(todayProvider);
      final calendar = ref.watch(logicalCalendarProvider);
      return ref
          .watch(pomodoroRepositoryProvider)
          .watchSessionsBetween(calendar.startOfWeek(today), today);
    });

final todayPomodoroCountProvider = Provider.autoDispose<int?>(
  (ref) => ref.watch(todayPomodoroSessionsProvider).value?.length,
);

/// El temporizador. Es `autoDispose` solo para poder depender de los
/// providers de sesión; se mantiene vivo con `keepAlive` para seguir
/// contando al salir de la pantalla.
final pomodoroControllerProvider =
    NotifierProvider.autoDispose<PomodoroController, PomodoroState>(
      PomodoroController.new,
    );
