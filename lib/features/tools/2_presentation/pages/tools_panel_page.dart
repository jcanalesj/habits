import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/profile/premium/premium_gate.dart';
import 'package:habits/features/tools/0_entity/entity.dart';
import 'package:habits/features/tools/2_presentation/providers/tools_providers.dart';
import 'package:habits/features/tools/2_presentation/providers/tool_summaries.dart';
import 'package:habits/features/tools/2_presentation/widgets/premium_tools_dialog.dart';
import 'package:habits/local_preferences.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Panel de Herramientas: una tarjeta por herramienta con su dato vivo.
///
/// Ninguna herramienta toca la racha ni los registros: el panel lo recuerda
/// una vez con un aviso que se puede cerrar.
class ToolsPanelPage extends ConsumerStatefulWidget {
  const ToolsPanelPage({super.key});

  @override
  ConsumerState<ToolsPanelPage> createState() => _ToolsPanelPageState();
}

class _ToolsPanelPageState extends ConsumerState<ToolsPanelPage> {
  late bool _noticeHidden =
      ref.read(sharedPreferencesProvider)?.getBool(toolsNoticeHiddenKey) ??
      false;

  Future<void> _hideNotice() async {
    setState(() => _noticeHidden = true);
    await ref
        .read(sharedPreferencesProvider)
        ?.setBool(toolsNoticeHiddenKey, true);
  }

  Future<void> _open(ToolDescriptor tool) async {
    final hasAccess = ref.read(premiumAccessProvider);
    if (tool.premium && !hasAccess) {
      final allowed = await requestPremiumAccess(
        context,
        ref,
        dialogBuilder: (_) => const PremiumToolsDialog(),
      );
      if (!allowed || !mounted) return;
    }
    if (!mounted) return;
    context.push(tool.route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final tools = ref.watch(toolDescriptorsProvider);
    final hasAccess = ref.watch(premiumAccessProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final summaries = {
      for (final tool in tools)
        tool.id: ref.watch(toolSummaryProvider((id: tool.id, l10n: l10n))),
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const ValueKey('tools-panel'),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            AppBottomNavBar.contentClearance + bottomInset,
          ),
          children: [
            SectionHeader(title: l10n.toolsTitle),
            const SizedBox(height: 4),
            Text(
              l10n.toolsSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
            if (!_noticeHidden) ...[
              const SizedBox(height: 14),
              SurfaceCard(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CatMascot(size: 48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            l10n.toolsNoticeBody,
                            style: textTheme.bodyMedium?.copyWith(
                              color: palette.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        key: const ValueKey('tools-notice-dismiss'),
                        onPressed: _hideNotice,
                        child: Text(l10n.toolsNoticeDismiss),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final width = (constraints.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final tool in tools)
                      SizedBox(
                        width: width,
                        height: width * 1.05,
                        child: ToolCard(
                          key: ValueKey('tool-card-${tool.id.name}'),
                          icon: tool.icon,
                          accent: tool.accent,
                          title: tool.id.title(l10n),
                          subtitle: tool.id.subtitle(l10n),
                          value: summaries[tool.id],
                          locked: tool.premium && !hasAccess,
                          onTap: () => _open(tool),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension ToolIdTexts on ToolId {
  String title(AppLocalizations l10n) => switch (this) {
    ToolId.tasks => l10n.toolTasksTitle,
    ToolId.pomodoro => l10n.toolPomodoroTitle,
    ToolId.shopping => l10n.toolShoppingTitle,
    ToolId.finance => l10n.toolFinanceTitle,
    ToolId.steps => l10n.toolStepsTitle,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    ToolId.tasks => l10n.toolTasksSubtitle,
    ToolId.pomodoro => l10n.toolPomodoroSubtitle,
    ToolId.shopping => l10n.toolShoppingSubtitle,
    ToolId.finance => l10n.toolFinanceSubtitle,
    ToolId.steps => l10n.toolStepsSubtitle,
  };
}
