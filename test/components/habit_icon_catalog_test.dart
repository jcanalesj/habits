import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habits/components/habit_icon_catalog.dart';
import 'package:habits/components/progress_icon_picker.dart';

void main() {
  group('HabitIconCatalog', () {
    test('resuelve IDs estables y usa fallback para uno desconocido', () {
      expect(HabitIconCatalog.getById('water_drop').id, 'water_drop');
      expect(HabitIconCatalog.getAsset('book'), endsWith('/book.svg'));
      expect(HabitIconCatalog.contains('running'), isTrue);
      expect(
        HabitIconCatalog.getById('removed_icon').id,
        HabitIconCatalog.fallbackId,
      );
    });

    test('puede inferir un icono al editar datos legacy', () {
      expect(HabitIconCatalog.idForLegacyEmoji('💧'), 'water_drop');
      expect(HabitIconCatalog.idForLegacyEmoji('🛸'), isNull);
    });
  });

  group('HabitProgressIcon', () {
    test('resuelve variantes empty y filled sin exponer rutas a la UI', () {
      final drop = ProgressIconCatalog.getById('water_drop');
      expect(drop.emptyAssetPath, endsWith('constanza_water_drop_empty.svg'));
      expect(drop.filledAssetPath, endsWith('constanza_water_drop_thin.svg'));
      expect(
        ProgressIconCatalog.getById('unknown').id,
        ProgressIconCatalog.fallbackId,
      );
    });

    testWidgets('renderiza tanto el estado pendiente como completado', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Row(
            children: [
              HabitProgressIcon(
                key: ValueKey('empty'),
                iconId: 'water_drop',
                completed: false,
              ),
              HabitProgressIcon(
                key: ValueKey('filled'),
                iconId: 'water_drop',
                completed: true,
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(SvgPicture), findsNWidgets(2));
      expect(find.byType(AnimatedSwitcher), findsNWidgets(2));
      expect(find.byKey(const ValueKey('empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('filled')), findsOneWidget);
    });
  });
}
