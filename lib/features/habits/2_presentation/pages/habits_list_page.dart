import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habits/components/components.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/2_presentation/controllers/home_controller.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Pestaña "Hábitos": todos los hábitos activos con su objetivo y la semana
/// en curso. Tocar uno lleva a su edición.
class HabitsListPage extends ConsumerWidget {
  const HabitsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summaryAsync = ref.watch(homeControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (summaryAsync) {
          AsyncData(:final value) => _Content(summary: value),
          AsyncError(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.somethingWentWrong('$error')),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/habit/new'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newHabit),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(homeControllerProvider.notifier);

    if (summary.habits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.noHabitsYetLong,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        SectionHeader(title: l10n.allHabitsTitle),
        const SizedBox(height: 12),
        HabitsListCard(
          habits: summary.habits,
          weekLogs: summary.weekLogs,
          today: summary.today,
          progressOf: summary.progressOf,
          onToggleToday: controller.toggleToday,
          onHabitTap: (habit) => context.push('/habit/${habit.id}'),
        ),
      ],
    );
  }
}
