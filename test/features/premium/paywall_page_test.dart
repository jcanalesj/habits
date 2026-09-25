import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/premium/0_entity/premium_plan.dart';
import 'package:habits/features/premium/2_presentation/paywall_page.dart';
import 'package:habits/features/premium/3_data/revenuecat_purchases_repository.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  Future<AuthTestEnv> pumpPaywall(
    WidgetTester tester, {
    AuthTestEnv? env,
    bool storeAvailable = true,
  }) async {
    // Pantalla alta: la página entera cabe sin desplazarse, así los tests
    // no dependen del tamaño de la fuente empaquetada.
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final testEnv = env ?? AuthTestEnv(initialUser: verifiedUser);
    if (!storeAvailable) {
      testEnv.purchasesOverride = const UnavailablePurchasesRepository();
    }
    await tester.pumpWidget(
      localizedApp(const PaywallPage(), overrides: testEnv.overrides),
    );
    await tester.pumpAndSettle();
    return testEnv;
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(PaywallPage)));

  testWidgets('muestra los planes con precio, prueba y textos legales', (
    tester,
  ) async {
    await pumpPaywall(tester);

    expect(find.text('Constanza Premium'), findsOneWidget);
    await scrollTo(tester, find.text('Anual'));
    expect(find.text('Mensual'), findsOneWidget);
    expect(find.text('2,99 € al mes'), findsOneWidget);
    expect(find.text('Anual'), findsOneWidget);
    expect(find.text('1 semana gratis · 19,99 € al año'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('paywall-restore')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('se renueva automáticamente'), findsOneWidget);
  });

  testWidgets('comprar desbloquea Premium', (tester) async {
    await pumpPaywall(tester);
    expect(containerOf(tester).read(premiumSubscribedProvider), isFalse);

    await buyPremiumOnPaywall(tester);

    expect(find.byType(PaywallPage), findsNothing);
  });

  testWidgets('cancelar la compra no desbloquea nada', (tester) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.purchases.nextOutcome = PurchaseOutcome.cancelled;
    await pumpPaywall(tester, env: env);

    await buyPremiumOnPaywall(tester);

    expect(find.byType(PaywallPage), findsOneWidget);
    expect(containerOf(tester).read(premiumSubscribedProvider), isFalse);
  });

  testWidgets('restaurar sin compras previas lo explica', (tester) async {
    await pumpPaywall(tester);
    final restore = find.byKey(const ValueKey('paywall-restore'));
    await tester.scrollUntilVisible(
      restore,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(restore);
    await tester.pumpAndSettle();

    expect(find.textContaining('No hemos encontrado compras'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('restaurar una compra anterior desbloquea Premium', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.purchases.restorable = true;
    await pumpPaywall(tester, env: env);
    final restore = find.byKey(const ValueKey('paywall-restore'));
    await tester.scrollUntilVisible(
      restore,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(restore);
    await tester.pumpAndSettle();

    expect(find.byType(PaywallPage), findsNothing);
  });

  testWidgets('sin tienda disponible no se puede comprar', (tester) async {
    await pumpPaywall(tester, storeAvailable: false);

    await scrollTo(tester, find.byKey(const ValueKey('paywall-unavailable')));
    expect(find.byKey(const ValueKey('paywall-unavailable')), findsOneWidget);
    expect(find.byKey(const ValueKey('paywall-continue')), findsNothing);
  });

  testWidgets('con Premium activo ofrece gestionar la suscripción', (
    tester,
  ) async {
    final env = AuthTestEnv(initialUser: verifiedUser);
    env.profiles.premium[verifiedUser.id] = true;
    await pumpPaywall(tester, env: env);

    await scrollTo(tester, find.byKey(const ValueKey('paywall-manage')));
    expect(find.text('Tu suscripción Premium está activa.'), findsOneWidget);
    expect(find.byKey(const ValueKey('paywall-manage')), findsOneWidget);
    expect(find.byKey(const ValueKey('paywall-continue')), findsNothing);
  });
}
