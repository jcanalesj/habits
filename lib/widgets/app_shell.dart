import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/localization/l10n.dart';

/// Shell de navegación: pinta la rama activa y la barra inferior.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        onCreate: () {
          // TODO(habits): flujo de creación de hábito (siguiente hito).
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.createHabitComingSoon)),
          );
        },
      ),
    );
  }
}
