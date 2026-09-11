import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/domain.dart';
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
    final pending = summary.habits.where((habit) {
      if (habit.reminderTime == null) return false;
      return !summary.isCompletedOn(habit.id, summary.today);
    }).toList()..sort((a, b) => a.reminderTime!.compareTo(b.reminderTime!));
    return pending.isEmpty ? null : pending.first;
  }

  Future<void> _useWildcard(BuildContext context, WidgetRef ref) async {
    final rescue = summary.streak.rescue;
    if (rescue == null) return;

    final confirmed = await WildcardRescueSheet.show(
      context,
      rescue: rescue,
      available: summary.wildcards.available,
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref.read(homeControllerProvider.notifier).useWildcard();
    if (!context.mounted) return;

    final l10n = context.l10n;
    final message = switch (result) {
      UseWildcardSuccess() => l10n.wildcardUsed,
      UseWildcardFailed(:final failure) => switch (failure) {
        WildcardFailure.noneAvailable => l10n.wildcardErrorNone,
        WildcardFailure.rescueWindowClosed => l10n.wildcardErrorWindowClosed,
        WildcardFailure.requiresConnection => l10n.wildcardErrorConnection,
        _ => l10n.wildcardErrorGeneric,
      },
      null => null,
    };
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        // Única racha de la app: la general del usuario. Ya no hay rachas
        // por ámbito ni por hábito (§1/§29).
        GeneralStreakCard(
          streak: summary.streak,
          wildcards: summary.wildcards,
          onUseWildcard: summary.streak.canRescue && summary.wildcards.hasAny
              ? () => _useWildcard(context, ref)
              : null,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: SectionHeader(title: l10n.myHabits)),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/habit/new'),
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
          today: summary.today,
          progressOf: summary.progressOf,
          onToggleToday: controller.toggleToday,
          onHabitTap: (habit) => context.push('/habit/${habit.id}'),
          // "Ver todos" cambia a la pestaña Hábitos del shell, no apila
          // una pantalla encima.
          onSeeAll: () => context.go('/habits'),
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
