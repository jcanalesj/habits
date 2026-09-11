import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/habits/2_presentation/pages/habit_form_page.dart';
import 'package:habits/features/habits/2_presentation/pages/home_page.dart';

/// Rutas de la pestaña de inicio.
final habitsRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
  ];
});

/// Rutas a pantalla completa (fuera del shell con barra de navegación):
/// el formulario tapa la barra mientras se crea o edita un hábito.
final habitFormRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/habit/new',
      builder: (context, state) => const HabitFormPage(),
    ),
    GoRoute(
      path: '/habit/:id',
      builder: (context, state) =>
          HabitFormPage(habitId: state.pathParameters['id']),
    ),
  ];
});
