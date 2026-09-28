import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/finance/2_presentation/routes/routes.dart';
import 'package:habits/features/pomodoro/2_presentation/routes/routes.dart';
import 'package:habits/features/shopping/2_presentation/routes/routes.dart';
import 'package:habits/features/steps/2_presentation/routes/routes.dart';
import 'package:habits/features/tasks/2_presentation/routes/routes.dart';
import 'package:habits/features/tools/2_presentation/pages/tools_panel_page.dart';

/// Rama del shell: el panel de herramientas, con barra inferior.
final toolsRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    GoRoute(
      path: '/tools',
      builder: (context, state) => const ToolsPanelPage(),
    ),
  ];
});

/// Un enlace directo a una herramienta no se salta la puerta Premium: sin
/// acceso vuelve al panel, que es quien explica los planes.
String? toolPremiumRedirect(Ref ref) =>
    ref.read(premiumAccessProvider) ? null : '/tools';

/// Pantallas de las herramientas, fuera del shell (a pantalla completa).
/// Cada herramienta añade aquí su ruta al implementarse.
final toolPageRoutesProvider = Provider<List<GoRoute>>((ref) {
  return [
    ...ref.watch(tasksRoutesProvider),
    ...ref.watch(pomodoroRoutesProvider),
    ...ref.watch(shoppingRoutesProvider),
    ...ref.watch(financeRoutesProvider),
    ...ref.watch(stepsRoutesProvider),
  ];
});
