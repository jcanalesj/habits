import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Splash de arranque: logo, una frase motivacional aleatoria y barra de
/// carga. Al completarse, y una vez restaurada la sesión, navega a la Home;
/// el `redirect` del router decide si toca login o verificación.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  /// Duración total del splash antes de entrar en la app.
  static const duration = Duration(milliseconds: 2800);

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Índice de la frase elegida para este arranque.
  final int _phraseIndex = Random().nextInt(5);

  /// Frases disponibles — ampliable añadiendo claves splashPhraseN a los
  /// .arb y sumándolas aquí.
  List<String> _phrases(AppLocalizations l10n) => [
    l10n.splashPhrase1,
    l10n.splashPhrase2,
    l10n.splashPhrase3,
    l10n.splashPhrase4,
    l10n.splashPhrase5,
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: SplashPage.duration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _enterApp();
          })
          ..forward();
  }

  Future<void> _enterApp() async {
    try {
      // Primer valor del stream de sesión (restaurada desde el almacenamiento
      // seguro del SDK). Si falla, el redirect tratará al usuario como
      // anónimo y lo llevará a login.
      await ref.read(authControllerProvider.future);
    } catch (_) {
      // Ver comentario anterior.
    }
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phrases = _phrases(context.l10n);
    final phrase = phrases[_phraseIndex % phrases.length];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/backgrounds/splash_background.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                const ConstanzaLogo(size: 210),
                const SizedBox(height: 8),
                const ConstanzaWordmark(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    phrase,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) =>
                      SplashLoadingIndicator(progress: _controller.value),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
