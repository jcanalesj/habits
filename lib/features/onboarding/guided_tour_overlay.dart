import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/habits/2_presentation/pages/habits_list_page.dart';
import 'package:habits/features/onboarding/guided_tour.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Capa del recorrido guiado. Vive encima del shell: en cada paso lleva al
/// usuario a la pantalla real, oscurece todo menos los elementos señalados y
/// explica qué se puede hacer ahí en una tarjeta con la mascota. Mientras
/// está activa bloquea el resto de la app: se avanza con sus botones, con
/// el botón atrás del sistema o tocando el elemento iluminado.
class GuidedTourOverlay extends ConsumerStatefulWidget {
  const GuidedTourOverlay({super.key});

  /// Cuántos frames se espera a que la pantalla destino monte sus anclas
  /// (datos que llegan, animaciones de entrada…) antes de mostrar el paso
  /// sin foco.
  static const locateAttempts = 90;

  /// Margen extra para las anclas opcionales: si en ese tiempo no aparecen
  /// (p. ej. no hay hábitos y no hay tarjeta de calendario) se sigue sin
  /// ellas.
  static const optionalAttempts = 12;

  @override
  ConsumerState<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

/// Un recorte iluminado del paso.
class _Hole {
  const _Hole(this.rect, {required this.isFocus});

  final Rect rect;

  /// Elemento concreto que se explica: late para llamar la atención y
  /// tocarlo avanza.
  final bool isFocus;
}

/// Geometría de un paso ya localizado sobre la pantalla.
class _Spotlight {
  const _Spotlight({required this.holes, required this.navBarTop});

  final List<_Hole> holes;

  /// Unión de los recortes de foco, si los hay. La tarjeta de texto se
  /// coloca en el lado contrario para no taparlos.
  Rect? get focus => holes
      .where((hole) => hole.isFocus)
      .map((hole) => hole.rect)
      .fold<Rect?>(
        null,
        (union, rect) => union == null ? rect : union.expandToInclude(rect),
      );

  /// Borde superior de la barra inferior, para apoyar la tarjeta encima.
  final double? navBarTop;
}

class _GuidedTourOverlayState extends ConsumerState<GuidedTourOverlay> {
  /// Foco del paso en curso, o `null` mientras se localiza.
  _Spotlight? _spotlight;

  GuidedTourController get _controller => ref.read(guidedTourProvider.notifier);

  @override
  void initState() {
    super.initState();
    final index = ref.read(guidedTourProvider);
    if (index != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _enter(index);
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
    final steps = _controller.steps;
    if (index == 0) {
      // Las mascotas de todos los pasos se precargan al arrancar: así cada
      // tarjeta aparece completa en vez de rellenarse al vuelo.
      for (final step in steps) {
        unawaited(precacheImage(AssetImage(step.asset), context));
      }
      // El recorrido empieza con cada pantalla en su inicio. Si se pide
      // desde el final de Perfil, por ejemplo, la fila de peso ni siquiera
      // estaría construida (las listas son perezosas) y no habría ancla.
      _scrollPagesToTop();
    }
    final step = steps[index];
    GoRouter.of(context).go(step.route);
    setState(() => _spotlight = null);
    unawaited(_locate(index, step));
  }

  Future<void> _locate(int index, GuidedTourStep step) async {
    final registry = ref.read(tutorialAnchorsProvider);
    var optionalWait = 0;
    for (
      var attempt = 0;
      attempt < GuidedTourOverlay.locateAttempts;
      attempt++
    ) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || ref.read(guidedTourProvider) != index) return;
      final required = [
        for (final target in step.targets) registry.contextOf(target),
      ];
      if (required.any((context) => context == null)) {
        // Red de seguridad: si el ancla tarda, puede ser que la pantalla
        // esté desplazada y la fila no exista aún. Subir la desvela.
        if (attempt == 12) _scrollPagesToTop();
        continue;
      }
      final optional = [
        for (final target in step.optional) registry.contextOf(target),
      ];
      if (optional.any((context) => context == null) &&
          optionalWait++ < GuidedTourOverlay.optionalAttempts) {
        continue;
      }

      // El elemento puede estar más abajo en la lista: se trae a la vista
      // antes de medirlo, pero solo lo justo: si ya se ve, la pantalla no
      // se mueve y conserva su contexto (cabeceras, saludo…).
      for (final (target, anchorContext) in [
        for (final (i, target) in step.targets.indexed) (target, required[i]),
        for (final (i, target) in step.optional.indexed) (target, optional[i]),
      ]) {
        if (anchorContext == null || !anchorContext.mounted) continue;
        await Scrollable.ensureVisible(
          anchorContext,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          duration: const Duration(milliseconds: 220),
        );
        if (!mounted || ref.read(guidedTourProvider) != index) return;
        if (!anchorContext.mounted) continue;
        await _liftAboveNavBar(target, anchorContext);
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
        () => _spotlight = _Spotlight(holes: const [], navBarTop: _navBarTop()),
      );
    }
  }

  /// Las listas se extienden bajo la barra inferior (`extendBody`), así
  /// que "visible al final" puede dejar el elemento tapado por la barra. Si
  /// pasa, se desplaza un poco más para sacarlo entero por encima.
  Future<void> _liftAboveNavBar(
    TutorialTarget target,
    BuildContext anchorContext,
  ) async {
    if (!target.isFocus) return;
    final overlayBox = context.findRenderObject();
    final navBarTop = _navBarTop();
    final position = Scrollable.maybeOf(anchorContext)?.position;
    if (overlayBox is! RenderBox || navBarTop == null || position == null) {
      return;
    }
    final rect = ref
        .read(tutorialAnchorsProvider)
        .rectOf(target, ancestor: overlayBox);
    if (rect == null) return;
    final overflow = rect.bottom + 18 - navBarTop;
    if (overflow <= 0) return;
    await position.animateTo(
      math.min(position.pixels + overflow, position.maxScrollExtent),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  /// Lleva al principio todas las listas verticales del shell (todas las
  /// pestañas: están montadas en el `IndexedStack`). Las horizontales
  /// (gráficas por semanas, filtros) se dejan como están.
  void _scrollPagesToTop() {
    final body = ref
        .read(tutorialAnchorsProvider)
        .contextOf(TutorialTarget.shellBody);
    if (body == null) return;
    void visit(Element element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        final position = (element.state as ScrollableState).position;
        if (position.axis == Axis.vertical &&
            position.hasPixels &&
            position.pixels != 0) {
          position.jumpTo(0);
        }
      }
      element.visitChildren(visit);
    }

    body.visitChildElements(visit);
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
    final holes = <_Hole>[];
    for (final (target, isRequired) in [
      for (final target in step.targets) (target, true),
      for (final target in step.optional) (target, false),
    ]) {
      final rect = registry.rectOf(target, ancestor: overlayBox);
      if (rect == null) {
        if (isRequired) return null;
        continue;
      }
      if (target == TutorialTarget.shellBody) {
        // El cuerpo se extiende bajo la barra (`extendBody`): el foco de
        // pantalla termina donde empieza la barra, que queda atenuada.
        final bottom = navBarTop == null
            ? rect.bottom
            : math.min(rect.bottom, navBarTop);
        holes.add(
          _Hole(
            Rect.fromLTRB(
              rect.left,
              rect.top,
              rect.right,
              bottom,
            ).intersect(bounds),
            isFocus: false,
          ),
        );
      } else {
        // Los elementos de contenido no se iluminan bajo la barra.
        final limit = target.isFocus && navBarTop != null
            ? Rect.fromLTRB(0, 0, bounds.right, navBarTop)
            : bounds;
        holes.add(
          _Hole(
            rect.inflate(target.isFocus ? 6 : 4).intersect(limit),
            isFocus: target.isFocus,
          ),
        );
      }
    }
    return _Spotlight(holes: holes, navBarTop: navBarTop);
  }

  Future<void> _createFirstHabit() async {
    _controller.finish();
    await HabitsListPage.openCreateHabit(context, ref, activeHabitCount: 0);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(guidedTourProvider, _onStepChanged);
    final index = ref.watch(guidedTourProvider);
    if (index == null) return const SizedBox.shrink();

    final controller = _controller;
    final step = controller.steps[index];
    final spotlight = _spotlight;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Con datos de ejemplo la cuenta real está vacía: el cierre invita a
    // crear el primer hábito.
    final hasHabits = !controller.usesDemoData;
    final isLast = controller.isLast;

    // Mientras se localizan las anclas no se pinta nada: la pantalla de
    // destino entra limpia y el foco aparece sobre ella ya colocado.
    return BackButtonListener(
      // El botón atrás del sistema retrocede un paso (o cierra en el
      // primero) en vez de mover la pantalla de fondo bajo el recorrido.
      onBackButtonPressed: () async {
        if (controller.isFirst) {
          controller.finish();
        } else {
          controller.previous();
        }
        return true;
      },
      child: BlockSemantics(
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
                  count: controller.steps.length,
                  spotlight: spotlight,
                  hasHabits: hasHabits,
                  demoData: controller.usesDemoData,
                  isLast: isLast,
                  onNext: isLast && !hasHabits
                      ? _createFirstHabit
                      : controller.next,
                  onPrevious: controller.isFirst ? null : controller.previous,
                  onSkip: controller.finish,
                ),
        ),
      ),
    );
  }
}

class _StepLayer extends StatelessWidget {
  const _StepLayer({
    super.key,
    required this.step,
    required this.index,
    required this.count,
    required this.spotlight,
    required this.hasHabits,
    required this.demoData,
    required this.isLast,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final GuidedTourStep step;
  final int index;
  final int count;
  final _Spotlight spotlight;
  final bool hasHabits;
  final bool demoData;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;

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
        final centered = step.layout == GuidedTourLayout.centered;

        final card = ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.authContentMaxWidth,
          ),
          child: _StepCard(
            asset: step.asset,
            title: step.title(l10n, hasHabits: hasHabits),
            body: step.body(l10n, hasHabits: hasHabits),
            counter: l10n.onboardingStepCounter(index + 1, count),
            demoLabel: demoData && step != GuidedTourStep.intro
                ? l10n.onboardingDemoData
                : null,
            centered: centered,
            nextLabel: switch (step) {
              GuidedTourStep.intro => l10n.onboardingStart,
              GuidedTourStep.finish =>
                hasHabits
                    ? l10n.onboardingFinish
                    : l10n.onboardingCreateFirstHabit,
              _ => l10n.onboardingNext,
            },
            nextIcon: switch (step) {
              GuidedTourStep.finish =>
                hasHabits ? PhosphorIconsBold.check : PhosphorIconsBold.plus,
              _ => PhosphorIconsBold.arrowRight,
            },
            showSkip: !isLast,
            onNext: onNext,
            onPrevious: onPrevious,
            onSkip: onSkip,
          ),
        );

        return Stack(
          key: const ValueKey('guided-tour'),
          fit: StackFit.expand,
          children: [
            // Absorbe toques y gestos: durante el recorrido no se interactúa
            // con la pantalla de fondo.
            AbsorbPointer(
              child: _SpotlightLayer(
                holes: spotlight.holes,
                scrim: palette.scrim,
                outline: palette.primary,
              ),
            ),
            // Tocar el elemento iluminado también avanza: es lo que uno
            // hace instintivamente cuando algo se señala.
            for (final hole in spotlight.holes)
              if (hole.isFocus)
                Positioned.fromRect(
                  rect: hole.rect,
                  child: GestureDetector(
                    key: const ValueKey('guided-tour-focus'),
                    behavior: HitTestBehavior.opaque,
                    onTap: onNext,
                  ),
                ),
            if (centered)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: card),
                ),
              )
            else
              Positioned(
                left: 16,
                right: 16,
                top: cardAtBottom ? null : viewPadding.top + 16,
                bottom: cardAtBottom ? bottomInset : null,
                child: Center(child: card),
              ),
          ],
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.asset,
    required this.title,
    required this.body,
    required this.counter,
    required this.demoLabel,
    required this.centered,
    required this.nextLabel,
    required this.nextIcon,
    required this.showSkip,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final String asset;
  final String title;
  final String body;
  final String counter;

  /// Aviso de que lo que se ve son datos de ejemplo, si procede.
  final String? demoLabel;
  final bool centered;
  final String nextLabel;
  final IconData nextIcon;
  final bool showSkip;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    final titleText = Text(
      title,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: textTheme.titleLarge?.copyWith(
        color: palette.textPrimary,
        fontWeight: FontWeight.w900,
        height: 1.15,
      ),
    );
    final image = Image.asset(
      asset,
      height: centered ? 150 : 76,
      width: centered ? null : 76,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );

    return Material(
      color: palette.dialogSurface,
      borderRadius: BorderRadius.circular(28),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
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
          crossAxisAlignment: centered
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
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
                    counter,
                    style: textTheme.labelMedium?.copyWith(
                      color: palette.primaryDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                // El aviso de datos de ejemplo se queda con todo el hueco
                // libre (alineado a la izquierda) y solo se recorta si de
                // verdad no cabe.
                Expanded(
                  child: demoLabel == null
                      ? const SizedBox.shrink()
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              key: const ValueKey('guided-tour-demo'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: palette.tint(AppColors.orange, .16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                demoLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                if (showSkip)
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
            if (centered) ...[
              image,
              const SizedBox(height: 14),
              titleText,
            ] else
              Row(
                children: [
                  image,
                  const SizedBox(width: 14),
                  Expanded(child: titleText),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (onPrevious != null) ...[
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      key: const ValueKey('guided-tour-previous'),
                      onPressed: onPrevious,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.primaryDeep,
                        side: BorderSide(
                          color: palette.primary.withValues(alpha: .45),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: Semantics(
                        label: l10n.onboardingPrevious,
                        child: const Icon(
                          PhosphorIconsBold.arrowLeft,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      key: const ValueKey('guided-tour-next'),
                      onPressed: onNext,
                      iconAlignment: IconAlignment.end,
                      icon: Icon(nextIcon, size: 18),
                      label: Text(nextLabel, maxLines: 1),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Oscurece la pantalla salvo los recortes. Los de foco laten un par de
/// veces al aparecer para llevar la vista hasta ellos.
class _SpotlightLayer extends StatefulWidget {
  const _SpotlightLayer({
    required this.holes,
    required this.scrim,
    required this.outline,
  });

  final List<_Hole> holes;
  final Color scrim;
  final Color outline;

  @override
  State<_SpotlightLayer> createState() => _SpotlightLayerState();
}

class _SpotlightLayerState extends State<_SpotlightLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Latido finito: llama la atención y se calma, y con "reducir
    // movimiento" ni empieza.
    if (!MediaQuery.disableAnimationsOf(context) &&
        widget.holes.any((hole) => hole.isFocus) &&
        !_pulse.isAnimating) {
      _pulse.repeat(reverse: true, count: 4);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _SpotlightPainter(
      holes: widget.holes,
      scrim: widget.scrim,
      outline: widget.outline,
      pulse: _pulse,
    ),
  );
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.holes,
    required this.scrim,
    required this.outline,
    required this.pulse,
  }) : super(repaint: pulse);

  final List<_Hole> holes;
  final Color scrim;
  final Color outline;
  final Animation<double> pulse;

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
        Path()..addRRect(RRect.fromRectAndRadius(hole.rect, _radius)),
      );
    }
    final dimmed = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      lit,
    );
    canvas.drawPath(dimmed, Paint()..color = scrim);

    final t = pulse.value;
    for (final hole in holes) {
      final rrect = RRect.fromRectAndRadius(hole.rect, _radius);
      if (hole.isFocus) {
        // Halo que crece y se desvanece alrededor del elemento.
        canvas.drawRRect(
          rrect.inflate(2 + 6 * t),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = outline.withValues(alpha: .55 * (1 - t)),
        );
      }
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = outline.withValues(alpha: .9),
      );
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.holes != holes ||
      oldDelegate.scrim != scrim ||
      oldDelegate.outline != outline;
}
