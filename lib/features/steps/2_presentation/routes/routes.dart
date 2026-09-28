import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/steps/2_presentation/pages/steps_page.dart';
import 'package:habits/features/steps/2_presentation/pages/steps_calendar_page.dart';
import 'package:habits/features/tools/2_presentation/routes/routes.dart';

final stepsRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/tools/steps',
      redirect: (context, state) => toolPremiumRedirect(ref),
      builder: (context, state) => const StepsPage(),
      routes: [
        GoRoute(
          path: 'calendar',
          builder: (context, state) => const StepsCalendarPage(),
        ),
      ],
    ),
  ];
});
