import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/2_presentation/controllers/post_registration.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_dimensions.dart';
import 'package:habits/theme/app_theme.dart';

/// Bienvenida tras crear la cuenta: marca y un empujón motivacional antes
/// de entrar por primera vez.
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    void start() {
      // Limpia la marca antes de navegar: el redirect deja de anclar aquí.
      ref.read(justRegisteredProvider.notifier).clear();
      context.go('/home');
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(
            asset: 'assets/backgrounds/splash_background.png',
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ConstanzaLogo(size: 145),
                      const SizedBox(height: 2),
                      const ConstanzaWordmark(fontSize: 28),
                      const SizedBox(height: 22),
                      Container(
                        width: 34,
                        height: 3,
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        l10n.welcomeTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: palette.authHeading,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // El remate ("HOY") va destacado dentro de la frase.
                      Text.rich(
                        TextSpan(
                          style: textTheme.titleMedium?.copyWith(
                            color: palette.authHeading.withValues(alpha: 0.82),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            letterSpacing: -0.1,
                          ),
                          children: [
                            TextSpan(text: l10n.welcomeMessage),
                            TextSpan(
                              text: l10n.welcomeMessageHighlight,
                              style: TextStyle(
                                color: context.palette.primaryDeep,
                                fontWeight: FontWeight.w800,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: AppDimensions.authContentMaxWidth,
                        child: GradientButton(
                          label: l10n.welcomeStart,
                          onPressed: start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
