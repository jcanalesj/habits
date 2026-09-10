import 'package:flutter/material.dart';
import 'package:habits/components/components.dart';

/// Página provisional para secciones aún no construidas.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title, this.emoji = '🚧'});

  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlaceholderContent(title: title, emoji: emoji),
    );
  }
}
