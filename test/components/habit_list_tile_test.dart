import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/components/habit_list_tile.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/gen/app_localizations.dart';
import 'package:habits/theme/app_theme.dart';

void main() {
  testWidgets(
    'las repeticiones compactas se adaptan sin desbordar en pantallas estrechas',
    (tester) async {
      const today = LogicalDate(2026, 9, 28);
      final habit = Habit(
        id: 'agua-ocho-veces',
        name: 'Beber agua varias veces al día',
        ambitoId: 'salud',
        periodicityTimeline: const [
          PeriodicityEntry(periodicity: Periodicity.daily, since: today),
        ],
        colorValue: AppColors.lilac.toARGB32(),
        emoji: '💧',
        trackingType: HabitTrackingType.repetitions,
        targetCount: 8,
        progressIconId: 'water_drop',
        createdAt: DateTime(2026, 9, 28),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 240,
                child: HabitListTile(
                  habit: habit,
                  weekLogs: const [],
                  today: today,
                  mode: HabitTileMode.trackCompact,
                  onToggleToday: () {},
                  onSetDailyCount: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('habit-repetitions-scroll-agua-ocho-veces')),
        findsOneWidget,
      );
    },
  );
}
