import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/features/auth/2_presentation/pages/verify_email_page.dart';
import 'package:habits/localization/gen/app_localizations.dart';

Widget _appUnderTest() {
  return const ProviderScope(
    child: MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: VerifyEmailPage(
        email: 'ejemplo@correo.com',
        displayName: 'constanza',
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('VerifyEmailPage muestra seis casillas y el correo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_appUnderTest());
    await tester.pump();

    expect(find.text('Verifica tu cuenta'), findsOneWidget);
    expect(find.text('ejemplo@correo.com'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text('Verificar'), findsOneWidget);
    expect(find.text('Reenviar código'), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).resizeToAvoidBottomInset,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Verificar incompleto muestra el error sin cambiar el layout', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest());
    await tester.pump();

    final buttonSize = tester.getSize(find.text('Verificar'));
    await tester.tap(find.text('Verificar'));
    await tester.pump();

    expect(
      find.text('Introduce el código completo de 6 dígitos'),
      findsOneWidget,
    );
    expect(tester.getSize(find.text('Verificar')), buttonSize);
  });

  testWidgets('El PIN no permite introducir mas de seis digitos', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest());
    await tester.pump();

    final fields = find.byType(TextField);
    for (var index = 0; index < 5; index++) {
      await tester.enterText(fields.at(index), '${index + 1}');
    }
    await tester.enterText(fields.at(5), '67');
    await tester.pump();

    final pin = List.generate(
      6,
      (index) => tester.widget<TextField>(fields.at(index)).controller!.text,
    ).join();

    expect(pin, '123456');
    expect(pin, hasLength(6));
  });
}
