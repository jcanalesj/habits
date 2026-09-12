import 'package:flutter/material.dart';
import 'package:habits/components/components.dart';

/// Página provisional para secciones aún no construidas. Admite una
/// acción opcional (p. ej. cerrar sesión en Perfil) anclada sobre la barra
/// de navegación.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    this.emoji = '🚧',
    this.action,
  });

  final String title;
  final String emoji;
  final Widget? action;

  /// Altura visual de la barra flotante más un margen de separación. El
  /// shell usa `extendBody`, así que esta zona no forma parte del safe area
  /// que recibe la página.
  static const double bottomBarClearance = 136;

  @override
  Widget build(BuildContext context) {
    // La barra inferior se dibuja sobre el body (`extendBody: true`). Su
    // altura incluye además el safe area, que cambia entre dispositivos.
    // Reservamos ambas zonas para que acciones como "Cerrar sesión" nunca
    // queden debajo de la navegación ni del indicador de inicio.
    final bottomActionInset =
        MediaQuery.viewPaddingOf(context).bottom + bottomBarClearance;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PlaceholderContent(title: title, emoji: emoji),
          if (action != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: bottomActionInset,
              child: Center(child: action),
            ),
        ],
      ),
    );
  }
}
