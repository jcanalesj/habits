import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';
import 'package:habits/features/habits/2_presentation/controllers/home_controller.dart';
import 'package:habits/features/habits/2_presentation/providers/habits_providers.dart';
import 'package:habits/localization/l10n.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting(AppLocalizations l10n, String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning(name);
    if (hour < 20) return l10n.goodAfternoon(name);
    return l10n.goodEvening(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeControllerProvider);
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (summaryAsync) {
          AsyncData(:final value) => _HomeContent(
            summary: value,
            greeting: _greeting(context.l10n, userName),
          ),
          AsyncError(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.somethingWentWrong('$error')),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.summary, required this.greeting});

  final HomeSummary summary;
  final String greeting;

  /// Hábito con recordatorio hoy aún sin completar y con hora más próxima.
  Habit? get _nextReminderHabit {
    final today = LogicalDay.today();
    final pending = summary.habits.where((habit) {
      if (habit.reminderTime == null) return false;
      return !summary.weekLogs.any(
        (log) =>
            log.habitId == habit.id && LogicalDay.isSameDay(log.date, today),
      );
    }).toList()..sort((a, b) => a.reminderTime!.compareTo(b.reminderTime!));
    return pending.isEmpty ? null : pending.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(homeControllerProvider.notifier);
    final nextReminder = _nextReminderHabit;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        HomeHeader(greeting: greeting),
        const SizedBox(height: 20),
        // Rachas: caché derivada (vacía → ceros) hasta el motor de la fase 5.
        GeneralStreakCard(streak: summary.generalStreak),
        const SizedBox(height: 24),
        SectionHeader(
          title: l10n.streaksByAmbito,
          actionLabel: l10n.seeAll,
          onAction: () {},
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: summary.ambitos.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => AmbitoStreakCard(
              ambito: summary.ambitos[index],
              streak: summary.ambitoStreak(summary.ambitos[index].id),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: SectionHeader(title: l10n.myHabits)),
            FilledButton.tonalIcon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.newHabit),
            ),
          ],
        ),
        const SizedBox(height: 12),
        HabitsListCard(
          habits: summary.habits,
          weekLogs: summary.weekLogs,
          streakOf: summary.habitStreak,
          onToggleToday: controller.toggleToday,
          onSeeAll: () {},
        ),
        if (nextReminder != null) ...[
          const SizedBox(height: 16),
          NextReminderCard(
            habit: nextReminder,
            onMarkNow: () => controller.toggleToday(nextReminder.id),
          ),
        ],
      ],
    );
  }
}
