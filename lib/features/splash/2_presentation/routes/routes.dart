import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/splash/2_presentation/pages/splash_page.dart';

/// Rutas de la feature de splash.
final splashRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
  ];
});
