import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/auth/2_presentation/presentation.dart';
import 'package:habits/features/onboarding/guided_tour.dart';
import 'package:habits/features/onboarding/guided_tour_overlay.dart';

/// Shell de navegación: pinta la rama activa y la barra inferior.
///
/// Es la raíz de la zona autenticada (solo se llega con email verificado),
/// por lo que aquí se garantiza el perfil en backend del usuario.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final profile = ref.watch(ensureUserProfileProvider(locale));
    if (profile.hasError) {
      // No bloquea la app: se reintenta en la siguiente sesión verificada.
      debugPrint('ensureUserProfile falló: ${profile.error}');
    }

    // El recorrido guiado se pinta por encima del shell entero (contenido y
    // barra) y navega entre ramas; por eso vive aquí y no en una ruta.
    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          extendBody: true,
          body: TutorialAnchor(
            target: TutorialTarget.shellBody,
            child: navigationShell,
          ),
          bottomNavigationBar: TutorialAnchor(
            target: TutorialTarget.navBar,
            child: AppBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          ),
        ),
        const GuidedTourOverlay(),
      ],
    );
  }
}
