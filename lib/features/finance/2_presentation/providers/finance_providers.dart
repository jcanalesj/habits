import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/finance/0_entity/entity.dart';
import 'package:habits/features/finance/1_domain/domain.dart';
// Capa de inyección de dependencias: único punto autorizado a importar 3_data.
import 'package:habits/features/finance/3_data/data.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';

final financeRepositoryProvider = Provider.autoDispose<FinanceRepository>((
  ref,
) {
  final userId = ref.read(authControllerProvider).value?.id ?? 'anonymous';
  return FirestoreFinanceRepository(userId: userId);
});

final financeConfigProvider = StreamProvider.autoDispose<FinanceConfig>(
  (ref) => ref.watch(financeRepositoryProvider).watchConfig(),
);

/// Mes que se está viendo, como desplazamiento respecto al actual.
class FinanceMonthOffset extends Notifier<int> {
  @override
  int build() => 0;

  void previous() => state--;
  void next() => state++;
  void reset() => state = 0;
}

final financeMonthOffsetProvider =
    NotifierProvider.autoDispose<FinanceMonthOffset, int>(
      FinanceMonthOffset.new,
    );

/// Periodo actual (el que contiene hoy) según el día de inicio configurado.
final currentFinancePeriodProvider = Provider.autoDispose<FinancePeriod>((ref) {
  final today = ref.watch(todayProvider);
  final config =
      ref.watch(financeConfigProvider).value ?? const FinanceConfig();
  return FinancePeriod.containing(today, startDay: config.monthStartDay);
});

/// Periodo que se está viendo en pantalla.
final selectedFinancePeriodProvider = Provider.autoDispose<FinancePeriod>(
  (ref) => ref
      .watch(currentFinancePeriodProvider)
      .shift(ref.watch(financeMonthOffsetProvider)),
);

final periodMovementsProvider = StreamProvider.autoDispose
    .family<List<Movement>, FinancePeriod>(
      (ref, period) => ref
          .watch(financeRepositoryProvider)
          .watchMovementsBetween(period.start, period.end),
    );

final fixedCostsProvider = StreamProvider.autoDispose<List<FixedCost>>(
  (ref) => ref.watch(financeRepositoryProvider).watchFixedCosts(),
);

final investmentsProvider = StreamProvider.autoDispose<List<Investment>>(
  (ref) => ref.watch(financeRepositoryProvider).watchInvestments(),
);

final pendingPurchasesProvider =
    StreamProvider.autoDispose<List<PendingPurchase>>(
      (ref) => ref.watch(financeRepositoryProvider).watchPendingPurchases(),
    );

/// Resumen de un periodo: ingresos, gastos y saldo (céntimos).
class PeriodSummary {
  const PeriodSummary({
    required this.incomeCents,
    required this.expenseCents,
    required this.fixedLogged,
    required this.fixedTotal,
  });

  final int incomeCents;
  final int expenseCents;
  final int fixedLogged;
  final int fixedTotal;

  int get balanceCents => incomeCents - expenseCents;

  static PeriodSummary of(
    List<Movement> movements,
    List<FixedCost> fixed,
    String monthKey,
  ) {
    var income = 0;
    var expense = 0;
    for (final movement in movements) {
      if (movement.kind == MovementKind.income) {
        income += movement.amountCents;
      } else {
        expense += movement.amountCents;
      }
    }
    final active = fixed.where((cost) => cost.active).toList();
    return PeriodSummary(
      incomeCents: income,
      expenseCents: expense,
      fixedLogged: active.where((cost) => cost.isLoggedIn(monthKey)).length,
      fixedTotal: active.length,
    );
  }
}

final periodSummaryProvider = Provider.autoDispose
    .family<PeriodSummary?, FinancePeriod>((ref, period) {
      final movements = ref.watch(periodMovementsProvider(period));
      final fixed = ref.watch(fixedCostsProvider);
      if (!movements.hasValue || !fixed.hasValue) return null;
      return PeriodSummary.of(movements.value!, fixed.value!, period.key);
    });

/// Saldo del mes actual, para el dato vivo del panel.
final monthBalanceProvider =
    Provider.autoDispose<({int cents, String currency})?>((ref) {
      final period = ref.watch(currentFinancePeriodProvider);
      final summary = ref.watch(periodSummaryProvider(period));
      final config = ref.watch(financeConfigProvider).value;
      if (summary == null || config == null) return null;
      return (cents: summary.balanceCents, currency: config.currency);
    });
