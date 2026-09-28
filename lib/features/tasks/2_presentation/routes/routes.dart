import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/tasks/2_presentation/pages/tasks_page.dart';
import 'package:habits/features/tools/2_presentation/routes/routes.dart';

final tasksRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/tools/tasks',
      redirect: (context, state) => toolPremiumRedirect(ref),
      builder: (context, state) => const TasksPage(),
    ),
  ];
});
