import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/tools/0_entity/entity.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Catálogo completo de herramientas, en el orden del panel.
const toolCatalog = <ToolDescriptor>[
  ToolDescriptor(
    id: ToolId.tasks,
    route: '/tools/tasks',
    icon: PhosphorIconsFill.checkSquare,
    accent: AppColors.pink,
  ),
  ToolDescriptor(
    id: ToolId.pomodoro,
    route: '/tools/pomodoro',
    icon: PhosphorIconsFill.timer,
    accent: AppColors.flame,
  ),
  ToolDescriptor(
    id: ToolId.shopping,
    route: '/tools/shopping',
    icon: PhosphorIconsFill.shoppingCart,
    accent: AppColors.blue,
  ),
  ToolDescriptor(
    id: ToolId.finance,
    route: '/tools/finance',
    icon: PhosphorIconsFill.wallet,
    accent: AppColors.lilac,
  ),
  ToolDescriptor(
    id: ToolId.steps,
    route: '/tools/steps',
    icon: PhosphorIconsFill.footprints,
    accent: AppColors.green,
    platforms: {TargetPlatform.iOS, TargetPlatform.android},
  ),
];

/// Plataforma en la que corre la app. Inyectable para que los tests puedan
/// ver (u ocultar) las herramientas que dependen del dispositivo.
final toolsPlatformProvider = Provider<({TargetPlatform platform, bool isWeb})>(
  (ref) => (platform: defaultTargetPlatform, isWeb: kIsWeb),
);

/// Herramientas disponibles en esta plataforma, en el orden del panel.
final toolDescriptorsProvider = Provider<List<ToolDescriptor>>((ref) {
  final env = ref.watch(toolsPlatformProvider);
  return [
    for (final tool in toolCatalog)
      if (tool.availableOn(env.platform, isWeb: env.isWeb)) tool,
  ];
});

/// Clave local del aviso "las herramientas no afectan a tu racha".
const toolsNoticeHiddenKey = 'tools_notice_hidden';
