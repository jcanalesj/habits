import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/shopping/0_entity/entity.dart';
import 'package:habits/features/shopping/2_presentation/pages/shopping_page.dart';
import 'package:habits/features/shopping/2_presentation/providers/shopping_providers.dart';
import 'package:habits/features/shopping/3_data/data.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  test('la entrada rápida separa cantidad y nombre', () {
    final parsed = ShoppingDraft.parseQuick('2 leche');
    expect(parsed.quantity, 2);
    expect(parsed.name, 'leche');
    expect(ShoppingDraft.parseQuick('3x huevos').name, 'huevos');
    expect(ShoppingDraft.parseQuick('pan').quantity, isNull);
    expect(ShoppingDraft.parseQuick('pan').name, 'pan');
    expect(ShoppingDraft.parseQuick('   ').isValid, isFalse);
  });

  testWidgets('añade, marca en el carrito y vacía comprados', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    final repository = InMemoryShoppingRepository(now: () => testInstant);
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      localizedApp(
        const ShoppingPage(),
        overrides: [
          ...env.overrides,
          shoppingRepositoryProvider.overrideWithValue(repository),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Tu lista está vacía. Escribe arriba lo que necesitas.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('shopping-quick-input')),
      '2 leche',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('shopping-quick-input')),
      'pan',
    );
    await tester.tap(find.byKey(const ValueKey('shopping-quick-add')));
    await tester.pumpAndSettle();

    expect(repository.all.length, 2);
    expect(find.text('leche'), findsOneWidget);
    expect(find.text('x2'), findsOneWidget);
    expect(find.text('Por comprar · 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('shopping-toggle-item-1')));
    await tester.pumpAndSettle();
    expect(find.text('Por comprar · 1'), findsOneWidget);
    expect(find.text('En el carrito · 1'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('shopping-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shopping-clear-bought')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-delete')));
    await tester.pumpAndSettle();

    expect(repository.all.length, 1);
    expect(repository.all.single.name, 'pan');
    expect(find.text('En el carrito · 1'), findsNothing);
  });
}
