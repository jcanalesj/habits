import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/shopping/2_presentation/pages/shopping_page.dart';
import 'package:habits/features/tools/2_presentation/routes/routes.dart';

final shoppingRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/tools/shopping',
      redirect: (context, state) => toolPremiumRedirect(ref),
      builder: (context, state) => const ShoppingPage(),
    ),
  ];
});
