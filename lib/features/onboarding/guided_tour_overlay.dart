import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/onboarding/guided_tour.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Capa del recorrido guiado. Vive encima del shell: en cada paso lleva al
/// usuario a la pantalla real, oscurece todo menos los elementos señalados y
/// explica qué se puede hacer ahí en una tarjeta. Mientras está activa
/// bloquea el resto de la app: se avanza solo con sus botones.
class GuidedTourOverlay extends ConsumerStatefulWidget {
  const GuidedTourOverlay({super.key});

  /// Cuántos frames se espera a que la pantalla destino monte sus anclas
  /// (datos que llegan, animaciones de entrada…) antes de mostrar el paso
  /// sin foco.
  static const locateAttempts = 90;

  @override
  ConsumerState<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

/// Geometría de un paso ya localizado sobre la pantalla.
class _Spotlight {
  const _Spotlight({
    required this.holes,
    required this.focus,
    required this.navBarTop,
  });

  /// Recortes que quedan iluminados.
  final List<Rect> holes;

  /// Elemento concreto que se explica (botón, tarjeta, fila), si lo hay. La
  /// tarjeta de texto se coloca en el lado contrario para no taparlo.
  final Rect? focus;

  /// Borde superior de la barra inferior, para apoyar la tarjeta encima.
  final double? navBarTop;
}

class _GuidedTourOverlayState extends ConsumerState<GuidedTourOverlay> {
  /// Foco del paso en curso, o `null` mientras se localiza.
  _Spotlight? _spotlight;

  @override
  void initState() {
    super.initState();
    final step = ref.read(guidedTourProvider);
    if (step != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _enter(step);
      });
    }
  }

  void _onStepChanged(int? previous, int? current) {
    if (current == null) {
      if (previous != null) GoRouter.of(context).go('/home');
      setState(() => _spotlight = null);
      return;
    }
    _enter(current);
  }

  void _enter(int index) {
    final step = GuidedTourStep.values[index];
    GoRouter.of(context).go(step.route);
    setState(() => _spotlight = null);
    unawaited(_locate(index));
  }

  Future<void> _locate(int index) async {
    final step = GuidedTourStep.values[index];
    final registry = ref.read(tutorialAnchorsProvider);
    for (
      var attempt = 0;
      attempt < GuidedTourOverlay.locateAttempts;
      attempt++
    ) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || ref.read(guidedTourProvider) != index) return;
      final contexts = [
        for (final target in step.targets) registry.contextOf(target),
      ];
      if (contexts.any((context) => context == null)) continue;

      // El elemento puede estar más abajo en la lista: se trae a la vista
      // antes de medirlo.
      for (final anchorContext in contexts) {
        if (anchorContext == null || !anchorContext.mounted) continue;
        await Scrollable.ensureVisible(
          anchorContext,
          alignment: .2,
          duration: const Duration(milliseconds: 220),
        );
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || ref.read(guidedTourProvider) != index) return;
      final spotlight = _measure(step);
      if (spotlight == null) continue;
      setState(() => _spotlight = spotlight);
      return;
    }
    // La pantalla no ha montado el elemento: se muestra la explicación
    // igualmente, sin foco, antes que dejar al usuario esperando.
    if (mounted && ref.read(guidedTourProvider) == index) {
      setState(
        () => _spotlight = _Spotlight(
          holes: const [],
          focus: null,
          navBarTop: _navBarTop(),
        ),
      );
    }
  }

  double? _navBarTop() {
    final overlayBox = context.findRenderObject();
    if (overlayBox is! RenderBox) return null;
    return ref
        .read(tutorialAnchorsProvider)
        .rectOf(TutorialTarget.navBar, ancestor: overlayBox)
        ?.top;
  }

  _Spotlight? _measure(GuidedTourStep step) {
    final overlayBox = context.findRenderObject();
    if (overlayBox is! RenderBox || !overlayBox.hasSize) return null;
    final registry = ref.read(tutorialAnchorsProvider);
    final bounds = Offset.zero & overlayBox.size;
    final navBarTop = _navBarTop();
    final holes = <Rect>[];
    Rect? focus;
    for (final target in step.targets) {
      final rect = registry.rectOf(target, ancestor: overlayBox);
      if (rect == null) return null;
      switch (target) {
        case TutorialTarget.shellBody:
          // El cuerpo se extiende bajo la barra (`extendBody`): el foco de
          // pantalla termina donde empieza la barra, que queda atenuada.
          final bottom = navBarTop == null
              ? rect.bottom
              : math.min(rect.bottom, navBarTop);
          holes.add(
            Rect.fromLTRB(
              rect.left,
              rect.top,
              rect.right,
              bottom,
            ).intersect(bounds),
          );
        case TutorialTarget.navBar:
        case TutorialTarget.navHabits:
        case TutorialTarget.navTools:
        case TutorialTarget.navStats:
        case TutorialTarget.navProfile:
          holes.add(rect.inflate(4).intersect(bounds));
        case TutorialTarget.newHabitButton:
        case TutorialTarget.streakCard:
        case TutorialTarget.weightLink:
          final hole = rect.inflate(6).intersect(bounds);
          holes.add(hole);
          focus = focus == null ? hole : focus.expandToInclude(hole);
      }
    }
    return _Spotlight(holes: holes, focus: focus, navBarTop: navBarTop);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(guidedTourProvider, _onStepChanged);
    final index = ref.watch(guidedTourProvider);
    if (index == null) return const SizedBox.shrink();

    final step = GuidedTourStep.values[index];
    final spotlight = _spotlight;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // Mientras se localizan las anclas no se pinta nada: la pantalla de
    // destino entra limpia y el foco aparece sobre ella ya colocado.
    return BlockSemantics(
      child: AnimatedSwitcher(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 220),
        child: spotlight == null
            ? const SizedBox.expand(key: ValueKey('guided-tour-locating'))
            : _StepLayer(
                key: ValueKey('guided-tour-step-$index'),
                step: step,
                index: index,
                spotlight: spotlight,
              ),
      ),
    );
  }
}

class _StepLayer extends ConsumerWidget {
  const _StepLayer({
    super.key,
    required this.step,
    required this.index,
    required this.spotlight,
  });

  final GuidedTourStep step;
  final int index;
  final _Spotlight spotlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final controller = ref.read(guidedTourProvider.notifier);
    final isLast = index == GuidedTourStep.values.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        // La tarjeta se apoya sobre la barra inferior, salvo que el elemento
        // explicado esté en la mitad de abajo: entonces va arriba, para no
        // taparlo. Sin elemento concreto (pasos de pantalla) va abajo y deja
        // la cabecera de la pantalla a la vista.
        final focus = spotlight.focus;
        final cardAtBottom =
            focus == null || focus.center.dy < constraints.maxHeight / 2;
        final viewPadding = MediaQuery.viewPaddingOf(context);
        final navBarTop = spotlight.navBarTop;
        final bottomInset = navBarTop == null
            ? viewPadding.bottom + 16
            : constraints.maxHeight - navBarTop + 12;

        return Stack(
          key: const ValueKey('guided-tour'),
          fit: StackFit.expand,
          children: [
            // Absorbe toques y gestos: durante el recorrido no se interactúa
            // con la pantalla de fondo.
            AbsorbPointer(
              child: CustomPaint(
                painter: _SpotlightPainter(
                  holes: spotlight.holes,
                  scrim: palette.scrim,
                  outline: palette.primary,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: cardAtBottom ? null : viewPadding.top + 16,
              bottom: cardAtBottom ? bottomInset : null,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.authContentMaxWidth,
                  ),
                  child: _StepCard(
                    step: step,
                    index: index,
                    isLast: isLast,
                    onNext: controller.next,
                    onSkip: controller.finish,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.index,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final GuidedTourStep step;
  final int index;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: palette.dialogSurface,
      borderRadius: BorderRadius.circular(28),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.primary.withValues(alpha: .18)),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.onboardingStepCounter(
                      index + 1,
                      GuidedTourStep.values.length,
                    ),
                    style: textTheme.labelMedium?.copyWith(
                      color: palette.primaryDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                if (!isLast)
                  TextButton(
                    key: const ValueKey('guided-tour-skip'),
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: palette.textSecondary,
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: Text(l10n.onboardingSkip),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              step.title(l10n),
              style: textTheme.titleLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              step.body(l10n),
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                key: const ValueKey('guided-tour-next'),
                onPressed: onNext,
                iconAlignment: IconAlignment.end,
                icon: Icon(
                  isLast
                      ? PhosphorIconsBold.check
                      : PhosphorIconsBold.arrowRight,
                  size: 18,
                ),
                label: Text(
                  isLast ? l10n.onboardingFinish : l10n.onboardingNext,
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Oscurece la pantalla salvo los recortes, que llevan un borde fino para
/// que se note qué se está señalando.
class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.holes,
    required this.scrim,
    required this.outline,
  });

  final List<Rect> holes;
  final Color scrim;
  final Color outline;

  static const _radius = Radius.circular(22);

  @override
  void paint(Canvas canvas, Size size) {
    // Unión de recortes y no `evenOdd`: los recortes pueden solaparse (una
    // pestaña dentro de la barra) y el solape debe seguir iluminado.
    var lit = Path();
    for (final hole in holes) {
      lit = Path.combine(
        PathOperation.union,
        lit,
        Path()..addRRect(RRect.fromRectAndRadius(hole, _radius)),
      );
    }
    final dimmed = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      lit,
    );
    canvas.drawPath(dimmed, Paint()..color = scrim);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = outline.withValues(alpha: .9);
    for (final hole in holes) {
      canvas.drawRRect(RRect.fromRectAndRadius(hole, _radius), stroke);
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.holes != holes ||
      oldDelegate.scrim != scrim ||
      oldDelegate.outline != outline;
}
