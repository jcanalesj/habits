import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/steps/0_entity/entity.dart';
import 'package:habits/features/steps/2_presentation/providers/steps_providers.dart';
import 'package:habits/features/steps/2_presentation/widgets/steps_month_calendar.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

class StepsCalendarPage extends ConsumerStatefulWidget {
  const StepsCalendarPage({super.key});

  @override
  ConsumerState<StepsCalendarPage> createState() => _StepsCalendarPageState();
}

class _StepsCalendarPageState extends ConsumerState<StepsCalendarPage> {
  static const _currentMonthPage = 12000;
  late final PageController _controller = PageController(
    initialPage: _currentMonthPage,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stepsControllerProvider);
    final stored =
        ref.watch(stepsHistoryProvider(StepsRange.all)).value ?? const [];
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.stepsHistoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: PageView.builder(
          key: const ValueKey('steps-month-pages'),
          controller: _controller,
          itemCount: _currentMonthPage + 1,
          itemBuilder: (context, page) {
            final offset = page - _currentMonthPage;
            final month = DateTime.utc(
              state.today.year,
              state.today.month + offset,
            );
            final monthDays = <StepsDay>[
              for (final day in stored)
                if (day.day.year == month.year && day.day.month == month.month)
                  if (day.day != state.today) day,
              if (month.year == state.today.year &&
                  month.month == state.today.month)
                StepsDay(day: state.today, steps: state.todaySteps),
            ];
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.palette.border),
                ),
                child: StepsMonthCalendar(
                  month: month,
                  days: monthDays,
                  goal: state.config.goal,
                  locale: locale,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
