import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/amount_field.dart';
import 'package:habits/features/finance/2_presentation/providers/finance_providers.dart';
import 'package:habits/features/pomodoro/2_presentation/providers/pomodoro_providers.dart';
import 'package:habits/features/shopping/2_presentation/providers/shopping_providers.dart';
import 'package:habits/features/steps/2_presentation/providers/steps_providers.dart';
import 'package:habits/features/tasks/2_presentation/providers/tasks_providers.dart';
import 'package:habits/features/tools/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:intl/intl.dart';

/// Dato vivo de cada tarjeta del panel ("3 pendientes hoy"), ya localizado
/// por la herramienta que lo produce; null = sin dato todavía.
///
/// Cada herramienta añade aquí su rama al implementarse.
final toolSummaryProvider = Provider.autoDispose
    .family<String?, ({ToolId id, AppLocalizations l10n})>((ref, args) {
      final l10n = args.l10n;
      return switch (args.id) {
        ToolId.tasks => switch (ref.watch(todayPendingTasksCountProvider)) {
          final count? => l10n.tasksPendingTodayWithCount(count),
          null => null,
        },
        ToolId.pomodoro => switch (ref.watch(todayPomodoroCountProvider)) {
          final count? => l10n.pomodoroTodayWithCount(count),
          null => null,
        },
        ToolId.shopping => switch (ref.watch(shoppingPendingCountProvider)) {
          final count? => l10n.shoppingPendingWithCount(count),
          null => null,
        },
        ToolId.finance => switch (ref.watch(monthBalanceProvider)) {
          final balance? => l10n.financeMonthSummary(
            formatSignedMoney(balance.cents, balance.currency, l10n.localeName),
          ),
          null => null,
        },
        ToolId.steps => switch (ref.watch(todayStepsSummaryProvider)) {
          final summary? => l10n.stepsSummary(
            NumberFormat.decimalPattern(l10n.localeName).format(summary.steps),
            NumberFormat.decimalPattern(l10n.localeName).format(summary.goal),
          ),
          null => null,
        },
      };
    });
