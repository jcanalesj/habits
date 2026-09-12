import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/localization/gen/app_localizations.dart';
import 'package:habits/widgets/placeholder_page.dart';

void main() {
  testWidgets('sitúa la acción por encima del safe area y la bottom bar', (
    tester,
  ) async {
    const actionKey = ValueKey('profile-action');
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            viewPadding: EdgeInsets.only(bottom: 34),
          ),
          child: PlaceholderPage(
            title: 'Perfil',
            action: SizedBox(key: actionKey, width: 140, height: 52),
          ),
        ),
      ),
    );

    final screenHeight = tester.getSize(find.byType(Scaffold)).height;
    final actionBottom = tester.getBottomRight(find.byKey(actionKey)).dy;
    expect(
      actionBottom,
      lessThanOrEqualTo(screenHeight - 34 - PlaceholderPage.bottomBarClearance),
    );
    expect(tester.takeException(), isNull);
  });
}
