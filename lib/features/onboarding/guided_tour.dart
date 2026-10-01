import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/localization/gen/app_localizations.dart';

/// Elementos reales de la app sobre los que el recorrido pone el foco.
/// Cada pantalla envuelve el suyo con [TutorialAnchor].
enum TutorialTarget {
  /// Zona de contenido del shell (todo menos la barra inferior).
  shellBody,

  /// Barra inferior completa: sirve para recortar el cuerpo y colocar la
  /// tarjeta justo encima, nunca se señala sola.
  navBar,
  navHabits,
  navTools,
  navStats,
  navProfile,
  newHabitButton,
  firstHabitTile,
  streakCard,
  firstCalendarCard,
  habitKindSelector,
  weightLink,
  firstToolCard,
  statsHabitsProgress;

  /// Los elementos concretos (botón, fila, tarjeta) se explican de cerca:
  /// la tarjeta de texto se aparta de ellos y tocarlos avanza.
  bool get isFocus => switch (this) {
    shellBody ||
    navBar ||
    navHabits ||
    navTools ||
    navStats ||
    navProfile => false,
    _ => true,
  };
}

/// Dónde va la tarjeta de texto.
enum GuidedTourLayout {
  /// Sobre la barra inferior o, si el foco está abajo, arriba.
  beside,

  /// En el centro, sin foco: bienvenida.
  centered,
}

/// Pasos del recorrido, en orden. Cada uno lleva a una pantalla real,
/// señala uno o varios elementos de ella y lleva su mascota.
enum GuidedTourStep {
  intro(
    '/home',
    [],
    asset: 'assets/images/cat.png',
    layout: GuidedTourLayout.centered,
  ),
  createHabits('/home', [
    TutorialTarget.newHabitButton,
  ], asset: 'assets/images/empty_habits.png'),
  checkHabit('/home', [
    TutorialTarget.firstHabitTile,
  ], asset: 'assets/images/edit.png'),
  streak('/home', [
    TutorialTarget.streakCard,
  ], asset: 'assets/images/wildcard_grant_cat.png'),
  calendars(
    '/habits',
    [TutorialTarget.shellBody, TutorialTarget.navHabits],
    optional: [TutorialTarget.firstCalendarCard],
    asset: 'assets/images/zona_horaria.png',
  ),
  quitHabits(
    '/habits/manage?kind=quit',
    [TutorialTarget.shellBody],
    optional: [TutorialTarget.habitKindSelector],
    asset: 'assets/images/gatotriste.png',
  ),
  weight('/profile', [
    TutorialTarget.weightLink,
    TutorialTarget.navProfile,
  ], asset: 'assets/images/gatogym.png'),
  tools(
    '/tools',
    [TutorialTarget.shellBody, TutorialTarget.navTools],
    optional: [TutorialTarget.firstToolCard],
    asset: 'assets/images/shopping/shopping_groceries_cat.png',
  ),
  stats(
    '/stats',
    [TutorialTarget.shellBody, TutorialTarget.navStats],
    optional: [TutorialTarget.statsHabitsProgress],
    asset: 'assets/images/love.png',
  ),
  finish('/home', [
    TutorialTarget.newHabitButton,
  ], asset: 'assets/images/cat.png');

  const GuidedTourStep(
    this.route,
    this.targets, {
    required this.asset,
    this.optional = const [],
    this.layout = GuidedTourLayout.beside,
  });

  final String route;

  /// Elementos que deben estar en pantalla para mostrar el paso.
  final List<TutorialTarget> targets;

  /// Elementos que se señalan si existen (p. ej. la primera tarjeta de
  /// calendario, que no está cuando aún no hay hábitos).
  final List<TutorialTarget> optional;

  final String asset;
  final GuidedTourLayout layout;

  String title(AppLocalizations l10n, {required bool hasHabits}) =>
      switch (this) {
        intro => l10n.onboardingIntroTitle,
        createHabits => l10n.onboardingCreateHabitsTitle,
        checkHabit => l10n.onboardingCheckHabitTitle,
        streak => l10n.onboardingStreakTitle,
        calendars => l10n.onboardingCalendarsTitle,
        quitHabits => l10n.onboardingQuitHabitsTitle,
        weight => l10n.onboardingWeightTitle,
        tools => l10n.onboardingToolsTitle,
        stats => l10n.onboardingStatsTitle,
        finish =>
          hasHabits
              ? l10n.onboardingFinishTitle
              : l10n.onboardingFinishFirstHabitTitle,
      };

  String body(AppLocalizations l10n, {required bool hasHabits}) =>
      switch (this) {
        intro => l10n.onboardingIntroBody,
        createHabits => l10n.onboardingCreateHabitsBody,
        checkHabit => l10n.onboardingCheckHabitBody,
        streak => l10n.onboardingStreakBody,
        calendars => l10n.onboardingCalendarsBody,
        quitHabits => l10n.onboardingQuitHabitsBody,
        weight => l10n.onboardingWeightBody,
        tools => l10n.onboardingToolsBody,
        stats => l10n.onboardingStatsBody,
        finish =>
          hasHabits
              ? l10n.onboardingFinishBody
              : l10n.onboardingFinishFirstHabitBody,
      };
}

/// Paso activo del recorrido (índice en [GuidedTourController.steps]), o
/// `null` cuando no está en marcha. Quien navega es la capa del shell
/// ([GuidedTourOverlay]): aquí solo vive el estado, así la Home puede
/// arrancarlo sin conocer el router.
final guidedTourProvider = NotifierProvider<GuidedTourController, int?>(
  GuidedTourController.new,
);

class GuidedTourController extends Notifier<int?> {
  List<GuidedTourStep> _steps = const [];
  bool _usesDemoData = false;

  @override
  int? build() => null;

  /// Pasos de este recorrido: se fijan al arrancar, para no cambiar bajo
  /// los pies del usuario a mitad.
  List<GuidedTourStep> get steps => _steps;

  /// La cuenta no tenía hábitos al arrancar: durante el recorrido las
  /// pantallas se alimentan de hábitos de ejemplo (ver
  /// [guidedTourDemoDataProvider]) y el cierre invita a crear el primero.
  bool get usesDemoData => _usesDemoData;

  GuidedTourStep? get currentStep {
    final index = state;
    return index == null ? null : _steps[index];
  }

  bool get isActive => state != null;
  bool get isFirst => state == 0;
  bool get isLast => state != null && state == _steps.length - 1;

  /// [hasHabits]: si la cuenta ya tiene hábitos reales. Sin ellos, el
  /// recorrido enseña datos de ejemplo para que cada pantalla tenga algo
  /// que mostrar.
  void start({required bool hasHabits}) {
    _usesDemoData = !hasHabits;
    _steps = GuidedTourStep.values;
    state = 0;
  }

  void next() {
    final current = state;
    if (current == null) return;
    final following = current + 1;
    state = following < _steps.length ? following : null;
  }

  void previous() {
    final current = state;
    if (current == null || current == 0) return;
    state = current - 1;
  }

  void finish() => state = null;
}

/// `true` mientras el recorrido está activo sobre una cuenta sin hábitos:
/// el repositorio de hábitos sirve entonces un juego de ejemplo en memoria.
final guidedTourDemoDataProvider = Provider<bool>((ref) {
  final active = ref.watch(guidedTourProvider) != null;
  return active && ref.watch(guidedTourProvider.notifier).usesDemoData;
});

/// Registro de dónde está cada elemento señalable. Las pantallas se apuntan
/// al construirse y se borran al desmontarse; la capa del recorrido lo
/// consulta para recortar el foco.
class TutorialAnchorRegistry {
  final _contexts = <TutorialTarget, BuildContext>{};

  void register(TutorialTarget target, BuildContext context) =>
      _contexts[target] = context;

  void unregister(TutorialTarget target, BuildContext context) {
    if (identical(_contexts[target], context)) _contexts.remove(target);
  }

  /// Contexto montado del elemento, o `null` si esa pantalla no está.
  BuildContext? contextOf(TutorialTarget target) {
    final context = _contexts[target];
    if (context == null || !context.mounted) return null;
    return context;
  }

  /// Rectángulo del elemento en coordenadas de [ancestor] (o globales).
  Rect? rectOf(TutorialTarget target, {RenderBox? ancestor}) {
    final context = contextOf(target);
    final box = context?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
  }
}

final tutorialAnchorsProvider = Provider<TutorialAnchorRegistry>(
  (ref) => TutorialAnchorRegistry(),
);

/// Marca a [child] como el elemento [target] del recorrido. No pinta nada.
class TutorialAnchor extends ConsumerStatefulWidget {
  const TutorialAnchor({super.key, required this.target, required this.child});

  final TutorialTarget target;
  final Widget child;

  @override
  ConsumerState<TutorialAnchor> createState() => _TutorialAnchorState();
}

class _TutorialAnchorState extends ConsumerState<TutorialAnchor> {
  late TutorialAnchorRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = ref.read(tutorialAnchorsProvider);
    _registry.register(widget.target, context);
  }

  @override
  void didUpdateWidget(covariant TutorialAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _registry.unregister(oldWidget.target, context);
      _registry.register(widget.target, context);
    }
  }

  @override
  void dispose() {
    _registry.unregister(widget.target, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
