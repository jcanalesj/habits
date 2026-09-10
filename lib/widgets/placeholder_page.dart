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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PlaceholderContent(title: title, emoji: emoji),
          if (action != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 120,
              child: Center(child: action),
            ),
        ],
      ),
    );
  }
}
