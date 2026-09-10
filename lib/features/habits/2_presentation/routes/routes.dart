import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';

/// Rutas de la feature de hábitos.
final habitsRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ];
});
