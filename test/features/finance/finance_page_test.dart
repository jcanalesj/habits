import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/components/amount_field.dart';
import 'package:habits/features/finance/0_entity/entity.dart';
import 'package:habits/features/finance/2_presentation/pages/finance_page.dart';
import 'package:habits/features/finance/2_presentation/providers/finance_providers.dart';
import 'package:habits/features/finance/3_data/data.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  test('los importes se escriben y leen en céntimos enteros', () {
    expect(parseAmountToCents('12,5'), 1250);
    expect(parseAmountToCents('12.50'), 1250);
    expect(parseAmountToCents('1200'), 120000);
    expect(parseAmountToCents('1.234'), isNull);
    expect(parseAmountToCents('abc'), isNull);
    expect(amountTextFromCents(1250, 'es'), '12,50');
    expect(amountTextFromCents(1200, 'en'), '12');
    expect(formatMoney(123456, 'EUR', 'es'), contains('1.234,56'));
    expect(formatMoney(123456, 'EUR', 'es'), contains('€'));
  });

  Future<InMemoryFinanceRepository> pumpFinance(WidgetTester tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    final repository = InMemoryFinanceRepository(now: () => testInstant);
    addTearDown(repository.dispose);
    await repository.addMovement(
      const MovementDraft(
        kind: MovementKind.income,
        amountCents: 150000,
        concept: 'Nómina',
        category: FinanceCategory.salary,
        date: testToday,
      ),
    );
    await repository.addMovement(
      MovementDraft(
        kind: MovementKind.expense,
        amountCents: 4550,
        concept: 'Cena',
        category: FinanceCategory.food,
        date: testToday.previous,
      ),
    );
    await repository.addFixedCost(
      const FixedCostDraft(
        name: 'Alquiler',
        amountCents: 85000,
        dayOfMonth: 1,
        category: FinanceCategory.home,
      ),
    );
    await tester.pumpWidget(
      localizedApp(
        const FinancePage(),
        overrides: [
          ...env.overrides,
          financeRepositoryProvider.overrideWithValue(repository),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('muestra el saldo del mes y los movimientos por día', (
    tester,
  ) async {
    await pumpFinance(tester);
    expect(find.text('Septiembre de 2026'), findsOneWidget);
    expect(find.textContaining('1.454,50'), findsWidgets);
    expect(find.text('Nómina'), findsWidgets);
    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Ayer'), findsOneWidget);
    expect(find.text('Fijos registrados 0 de 1'), findsOneWidget);
  });

  testWidgets('registrar un gasto fijo crea el movimiento del mes', (
    tester,
  ) async {
    final repository = await pumpFinance(tester);
    await tester.tap(find.byKey(const ValueKey('finance-tab-fixed')));
    await tester.pumpAndSettle();
    expect(find.text('Alquiler'), findsOneWidget);
    final log = find.byKey(const ValueKey('fixed-log-fix-3'));
    await tester.ensureVisible(log);
    await tester.tap(log);
    await tester.pumpAndSettle();

    expect(find.text('Registrado ✓'), findsOneWidget);
    expect(
      repository.movements.values.where((m) => m.fixedCostId == 'fix-3').length,
      1,
    );
    expect(find.text('Fijos registrados 1 de 1'), findsOneWidget);
  });

  testWidgets('crea un movimiento desde el diálogo', (tester) async {
    final repository = await pumpFinance(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('finance-new')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('finance-new')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('finance-movement-dialog')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('finance-amount-field')),
      '19,99',
    );
    await tester.enterText(
      find.byKey(const ValueKey('finance-concept-field')),
      'Libro',
    );
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('finance-movement-save'));
    await tester.ensureVisible(save);
    expect(tester.widget<FilledButton>(save).enabled, isTrue);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('finance-movement-dialog')), findsNothing);

    final created = repository.movements.values.firstWhere(
      (m) => m.concept == 'Libro',
    );
    expect(created.amountCents, 1999);
    expect(created.kind, MovementKind.expense);
    expect(created.date, testToday);
  });

  testWidgets('marca una compra pendiente como comprada', (tester) async {
    final repository = await pumpFinance(tester);
    await repository.addPendingPurchase(
      const PendingPurchaseDraft(
        name: 'Bici',
        estimatedCents: 45000,
        priority: PurchasePriority.high,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('finance-tab-pending')));
    await tester.pumpAndSettle();
    final bought = find.byKey(const ValueKey('purchase-bought-buy-4'));
    await tester.ensureVisible(bought);
    await tester.tap(bought);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('finance-amount-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('finance-amount-save')));
    await tester.pumpAndSettle();

    expect(repository.purchases['buy-4']!.isBought, isTrue);
    expect(
      repository.movements.values.any((m) => m.pendingPurchaseId == 'buy-4'),
      isTrue,
    );
  });
}
