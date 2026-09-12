import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habits/components/cat_mascot.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Transición de entrada que revela [child] como continuación de la
/// bienvenida. No crea rutas, diálogos ni bloquea la carga de la Home.
class ColdStartWelcome extends StatefulWidget {
  const ColdStartWelcome({
    super.key,
    required this.greeting,
    required this.message,
    required this.onFinished,
    required this.child,
  });

  /// Duración total de la entrada. Todas las fases son fracciones de este
  /// valor, así que cambiarlo aquí ralentiza o acelera la animación entera
  /// de forma proporcional.
  static const duration = Duration(milliseconds: 2200);

  /// Con "reducir movimiento" activado no se anima el recorrido de la
  /// mascota: solo se funde la Home. Se mantiene corta a propósito, que es
  /// lo que espera quien pide menos movimiento.
  static const reducedMotionDuration = Duration(milliseconds: 260);

  /// Al tocar la pantalla se salta al final. Este remate sí es rápido: el
  /// usuario ha pedido explícitamente ir al grano.
  static const skipDuration = Duration(milliseconds: 120);

  final String greeting;
  final String message;
  final VoidCallback onFinished;
  final Widget child;

  @override
  State<ColdStartWelcome> createState() => _ColdStartWelcomeState();
}

class _ColdStartWelcomeState extends State<ColdStartWelcome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onFinished();
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _controller.duration = _reduceMotion
        ? ColdStartWelcome.reducedMotionDuration
        : ColdStartWelcome.duration;
    _controller.forward();
  }

  void _skip() {
    if (_controller.isCompleted) return;
    _controller.animateTo(
      1,
      duration: ColdStartWelcome.skipDuration,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _interval(double value, double begin, double end, Curve curve) {
    return curve.transform(((value - begin) / (end - begin)).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = _controller.value;
        final reveal = _reduceMotion
            ? Curves.easeOut.transform(value)
            : _interval(value, .48, 1, Curves.easeOutCubic);
        final move = _reduceMotion
            ? 0.0
            : _interval(value, .35, .94, Curves.easeInOutCubic);
        final intro = _interval(value, 0, .20, Curves.easeOut);
        final messageOut = 1 - _interval(value, .48, .72, Curves.easeIn);
        final overlayOut = 1 - _interval(value, .72, 1, Curves.easeInOut);

        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: reveal,
              child: Transform.translate(
                offset: Offset(0, _reduceMotion ? 0 : 18 * (1 - reveal)),
                child: child,
              ),
            ),
            Semantics(
              button: true,
              label: context.l10n.skipWelcome,
              child: GestureDetector(
                key: const ValueKey('cold-start-welcome'),
                behavior: HitTestBehavior.opaque,
                onTap: _skip,
                child: Opacity(
                  opacity: overlayOut,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: AppColors.background),
                      Positioned.fill(
                        child: Opacity(
                          opacity: .15,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 18,
                              sigmaY: 18,
                            ),
                            child: Image.asset(
                              'assets/images/cards/card1.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      if (!_reduceMotion)
                        Align(
                          alignment: Alignment.lerp(
                            const Alignment(0, -.34),
                            const Alignment(.83, -.88),
                            move,
                          )!,
                          child: Transform.scale(
                            scale:
                                (lerpDouble(.88, 1, intro)! *
                                lerpDouble(1, .34, move)!),
                            child: const CatMascot(size: 156),
                          ),
                        )
                      else
                        Opacity(
                          opacity: 1 - reveal,
                          child: const Align(
                            alignment: Alignment(0, -.30),
                            child: CatMascot(size: 132),
                          ),
                        ),
                      Align(
                        alignment: _reduceMotion
                            ? const Alignment(0, .10)
                            : Alignment.lerp(
                                const Alignment(0, .08),
                                const Alignment(-.78, -.80),
                                move,
                              )!,
                        child: Transform.scale(
                          alignment: Alignment.centerLeft,
                          scale: _reduceMotion
                              ? 1
                              : lerpDouble(1.08, .72, move)!,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              widget.greeting,
                              textAlign: move < .7
                                  ? TextAlign.center
                                  : TextAlign.left,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, .34),
                        child: Opacity(
                          opacity: intro * messageOut,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
