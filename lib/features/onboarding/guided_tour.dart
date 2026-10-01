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
  streakCard,
  weightLink,
}

/// Pasos del recorrido, en orden. Cada uno lleva a una pantalla real y
/// señala uno o varios elementos de ella.
enum GuidedTourStep {
  createHabits('/home', [TutorialTarget.newHabitButton]),
  streak('/home', [TutorialTarget.streakCard]),
  calendars('/habits', [TutorialTarget.shellBody, TutorialTarget.navHabits]),
  quitHabits('/habits/manage?kind=quit', [TutorialTarget.shellBody]),
  weight('/profile', [TutorialTarget.weightLink, TutorialTarget.navProfile]),
  tools('/tools', [TutorialTarget.shellBody, TutorialTarget.navTools]),
  stats('/stats', [TutorialTarget.shellBody, TutorialTarget.navStats]);

  const GuidedTourStep(this.route, this.targets);

  final String route;
  final List<TutorialTarget> targets;

  String title(AppLocalizations l10n) => switch (this) {
    createHabits => l10n.onboardingCreateHabitsTitle,
    streak => l10n.onboardingStreakTitle,
    calendars => l10n.onboardingCalendarsTitle,
    quitHabits => l10n.onboardingQuitHabitsTitle,
    weight => l10n.onboardingWeightTitle,
    tools => l10n.onboardingToolsTitle,
    stats => l10n.onboardingStatsTitle,
  };

  String body(AppLocalizations l10n) => switch (this) {
    createHabits => l10n.onboardingCreateHabitsBody,
    streak => l10n.onboardingStreakBody,
    calendars => l10n.onboardingCalendarsBody,
    quitHabits => l10n.onboardingQuitHabitsBody,
    weight => l10n.onboardingWeightBody,
    tools => l10n.onboardingToolsBody,
    stats => l10n.onboardingStatsBody,
  };
}

/// Paso activo del recorrido, o `null` cuando no está en marcha. Quien
/// navega es la capa del shell ([GuidedTourOverlay]): aquí solo vive el
/// estado, así la Home puede arrancarlo sin conocer el router.
final guidedTourProvider = NotifierProvider<GuidedTourController, int?>(
  GuidedTourController.new,
);

class GuidedTourController extends Notifier<int?> {
  @override
  int? build() => null;

  bool get isActive => state != null;

  void start() => state = 0;

  void next() {
    final current = state;
    if (current == null) return;
    final following = current + 1;
    state = following < GuidedTourStep.values.length ? following : null;
  }

  void finish() => state = null;
}

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
