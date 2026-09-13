import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/components/app_notice.dart';

void main() {
  testWidgets('muestra un aviso flotante accesible y se oculta solo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => AppNotice.show(
                context,
                message: 'Hábito guardado',
                type: AppNoticeType.success,
              ),
              child: const Text('Mostrar'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mostrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hábito guardado'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Hábito guardado'), findsNothing);
  });

  testWidgets('un aviso nuevo reemplaza al anterior', (tester) async {
    late BuildContext noticeContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            noticeContext = context;
            return const Scaffold();
          },
        ),
      ),
    );

    AppNotice.show(noticeContext, message: 'Primero');
    await tester.pump();
    AppNotice.show(
      noticeContext,
      message: 'Segundo',
      type: AppNoticeType.error,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Primero'), findsNothing);
    expect(find.text('Segundo'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });
}
