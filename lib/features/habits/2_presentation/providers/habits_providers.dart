import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/auth/2_presentation/providers/auth_providers.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
// Los ficheros de providers son la capa de inyección de dependencias:
// son el único punto de 2_presentation autorizado a importar 3_data.
import 'package:habits/features/habits/3_data/data.dart';

/// Reloj de la app. Inyectable para poder fijar el instante en los tests
/// (§34): 23:59, 00:00, cambio de mes, cambio de año o un cambio de horario
/// de verano.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Zona horaria IANA del perfil.
///
/// Es la única fuente del "día lógico": NO se usa la zona del dispositivo.
/// Mientras el perfil no ha cargado se cae a UTC, lo que a lo sumo desplaza
/// el día unas horas en la primera carga y nunca reinterpreta el pasado
/// (§13).
final profileTimezoneProvider = StreamProvider.autoDispose<String>((ref) {
  final userId = ref.read(authControllerProvider).value?.id;
  if (userId == null) return Stream.value(LogicalCalendar.fallbackTimezone);
  return ref
      .read(userProfileRepositoryProvider)
      .watchTimezone(userId)
      .map((timezone) => timezone ?? LogicalCalendar.fallbackTimezone);
});

/// Calendario con la zona del perfil. Todo cálculo de día, semana, mes y año
/// pasa por aquí.
final logicalCalendarProvider = Provider.autoDispose<LogicalCalendar>((ref) {
  final timezone =
      ref.watch(profileTimezoneProvider).value ??
      LogicalCalendar.fallbackTimezone;
  return LogicalCalendar(timezone);
});

/// Día lógico de hoy en la zona del perfil.
final todayProvider = Provider.autoDispose<LogicalDate>((ref) {
  return ref
      .watch(logicalCalendarProvider)
      .dateOf(ref.watch(clockProvider).nowUtc());
});

final periodicityResolverProvider = Provider.autoDispose<PeriodicityResolver>(
  (ref) => PeriodicityResolver(ref.watch(logicalCalendarProvider)),
);

final goalProgressCalculatorProvider =
    Provider.autoDispose<GoalProgressCalculator>(
      (ref) => GoalProgressCalculator(ref.watch(periodicityResolverProvider)),
    );

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
    timezone: ref.watch(profileTimezoneProvider).value,
  );
});

/// Repositorio de comodines, separado a propósito del de hábitos: tiene un
/// contrato distinto (requiere conectividad, escrituras atómicas).
final wildcardsRepositoryProvider = Provider.autoDispose<WildcardsRepository>((
  ref,
) {
  final userId = ref.read(authControllerProvider).value?.id;
  return FirestoreWildcardsRepository(
    userId: userId ?? FirestoreHabitsRepository.anonymousUserId,
  );
});

final watchHomeSummaryUsecaseProvider =
    Provider.autoDispose<WatchHomeSummaryUsecase>((ref) {
      return WatchHomeSummaryUsecase(
        habits: ref.watch(habitsRepositoryProvider),
        wildcards: ref.watch(wildcardsRepositoryProvider),
        calendar: ref.watch(logicalCalendarProvider),
        goalProgress: ref.watch(goalProgressCalculatorProvider),
        clock: ref.watch(clockProvider),
      );
    });

final toggleHabitCompletionUsecaseProvider =
    Provider.autoDispose<ToggleHabitCompletionUsecase>((ref) {
      return ToggleHabitCompletionUsecase(ref.watch(habitsRepositoryProvider));
    });

final useWildcardUsecaseProvider = Provider.autoDispose<UseWildcardUsecase>((
  ref,
) {
  return UseWildcardUsecase(ref.watch(wildcardsRepositoryProvider));
});

final ensureMonthlyWildcardGrantUsecaseProvider =
    Provider.autoDispose<EnsureMonthlyWildcardGrantUsecase>((ref) {
      return EnsureMonthlyWildcardGrantUsecase(
        ref.watch(wildcardsRepositoryProvider),
      );
    });

final rebuildStreakUsecaseProvider = Provider.autoDispose<RebuildStreakUsecase>(
  (ref) => RebuildStreakUsecase(
    ref.watch(habitsRepositoryProvider),
    ref.watch(wildcardsRepositoryProvider),
  ),
);

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

final changeHabitPeriodicityUsecaseProvider =
    Provider.autoDispose<ChangeHabitPeriodicityUsecase>((ref) {
      return ChangeHabitPeriodicityUsecase(
        ref.watch(habitsRepositoryProvider),
        ref.watch(periodicityResolverProvider),
      );
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

/// Ámbitos del usuario, para el selector del formulario de hábitos.
final ambitosProvider = StreamProvider.autoDispose<List<Ambito>>((ref) {
  return ref.watch(habitsRepositoryProvider).watchAmbitos();
});

/// Hábitos activos, para la pestaña "Hábitos".
final activeHabitsProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  return ref.watch(habitsRepositoryProvider).watchActiveHabits();
});

/// Un hábito concreto por id, para la pantalla de edición. Null si no existe.
final habitByIdProvider = FutureProvider.autoDispose.family<Habit?, String>((
  ref,
  habitId,
) {
  return ref.watch(habitsRepositoryProvider).getHabit(habitId);
});

/// Notificaciones locales. Una sola instancia: el plugin guarda estado
/// (canal creado, permisos) y crear varias duplicaría el trabajo.
final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return LocalNotificationsRepository();
});

final syncRemindersUsecaseProvider = Provider<SyncRemindersUsecase>((ref) {
  return SyncRemindersUsecase(ref.watch(notificationsRepositoryProvider));
});

/// Permiso actual del sistema para notificar.
final notificationPermissionProvider =
    FutureProvider.autoDispose<NotificationPermission>((ref) {
      return ref.watch(notificationsRepositoryProvider).currentPermission();
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
