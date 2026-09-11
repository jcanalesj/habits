import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';

part 'streak_state.freezed.dart';

/// Situación de la racha general respecto al día de hoy.
enum StreakStatus {
  /// No hay ninguna racha viva: el usuario aún no ha completado su primer
  /// hábito, o la racha anterior se rompió definitivamente.
  none,

  /// Hoy ya hay actividad. La racha incluye el día de hoy.
  completedToday,

  /// La racha está intacta (ayer hubo actividad o estaba protegido) pero
  /// hoy todavía no se ha completado nada.
  pendingToday,

  /// Ayer quedó vacío y todavía se puede rescatar con un comodín durante
  /// todo el día de hoy (§18). Al terminar hoy, la racha anterior se rompe
  /// definitivamente.
  atRisk,
}

/// Oportunidad de rescate: el día inmediatamente anterior quedó sin
/// actividad y sigue dentro de la ventana en la que un comodín puede
/// protegerlo (§17: solo durante el día siguiente, nunca después).
@freezed
abstract class RescueOpportunity with _$RescueOpportunity {
  const factory RescueOpportunity({
    /// Día a proteger. Siempre es `hoy - 1`.
    required LogicalDate day,

    /// Racha que se perderá si no se rescata: los días de actividad de la
    /// cadena que terminó justo antes del hueco. Es el número que la Home
    /// muestra mientras dura la ventana ("🔥 24 — tu racha está en peligro").
    required int streakAtRisk,

    /// Racha resultante si se usa el comodín ahora. Incluye la actividad de
    /// hoy si ya la hay: el comodín protege pero no suma (§16), así que
    /// 24 + comodín = 24, y 24 + comodín + actividad de hoy = 25.
    required int streakIfRescued,
  }) = _RescueOpportunity;
}

/// Resultado del motor de rachas. Es un valor derivado y reconstruible: se
/// calcula íntegramente desde los registros y los días protegidos.
///
/// Durante la ventana de rescate conviven DOS valores reales y distintos
/// ([currentStreak] y [RescueOpportunity.streakAtRisk]); el dominio los
/// representa por separado y es la presentación quien decide cuál enseñar
/// (ver [displayStreak]).
@freezed
abstract class StreakState with _$StreakState {
  const factory StreakState({
    /// Racha viva a día de hoy, contada en DÍAS CON ACTIVIDAD.
    ///
    /// Es el valor determinista: si ayer quedó vacío y sin proteger, la
    /// cadena anterior ya está rota y esto vale 0, o 1 si hoy hay actividad.
    @Default(0) int currentStreak,

    /// Mejor racha histórica, con la misma semántica: días de actividad de
    /// la cadena más larga. Los días protegidos mantienen la cadena pero no
    /// se cuentan (§32).
    @Default(0) int bestStreak,

    /// Último día con actividad real. Null si el usuario nunca completó un
    /// hábito.
    LogicalDate? lastActivityDay,
    @Default(StreakStatus.none) StreakStatus status,
    RescueOpportunity? rescue,
  }) = _StreakState;

  const StreakState._();

  static const empty = StreakState();

  bool get canRescue => rescue != null;

  /// Número que se enseña en la Home.
  ///
  /// Decisión de producto: durante la ventana de rescate se mantiene
  /// visible la racha anterior ("🔥 24, tu racha está en peligro") en lugar
  /// del valor ya roto. No es un falseo del cálculo: [currentStreak] sigue
  /// siendo el valor determinista y ambos viajan juntos.
  int get displayStreak => rescue?.streakAtRisk ?? currentStreak;
}
