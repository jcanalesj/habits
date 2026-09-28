import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/finance/2_presentation/pages/finance_page.dart';
import 'package:habits/features/tools/2_presentation/routes/routes.dart';

final financeRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/tools/finance',
      redirect: (context, state) => toolPremiumRedirect(ref),
      builder: (context, state) => const FinancePage(),
    ),
  ];
});
