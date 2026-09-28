import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/pomodoro/2_presentation/pages/pomodoro_page.dart';
import 'package:habits/features/tools/2_presentation/routes/routes.dart';

final pomodoroRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/tools/pomodoro',
      redirect: (context, state) => toolPremiumRedirect(ref),
      builder: (context, state) => const PomodoroPage(),
    ),
  ];
});
