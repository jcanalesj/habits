import 'package:flutter/material.dart';
import 'package:habits/components/periodicity_label.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Selector de objetivo: tipo de periodo + cuántas veces.
///
/// No pide días concretos a propósito (§8): el objetivo es flexible y da
/// igual qué días de la semana se cumpla.
class PeriodicityField extends StatelessWidget {
  const PeriodicityField({
    super.key,
    required this.value,
    required this.onChanged,
    this.deferredNotice,
  });

  final Periodicity value;
  final ValueChanged<Periodicity> onChanged;

  /// Aviso de cuándo entrará en vigor el cambio. Se muestra ANTES de
  /// guardar, porque un cambio de objetivo nunca altera el periodo en curso
  /// (§10).
  final String? deferredNotice;

  String _typeLabel(AppLocalizations l10n, PeriodicityType type) =>
      switch (type) {
        PeriodicityType.daily => l10n.periodicityDailyLabel,
        PeriodicityType.weekly => l10n.goalPeriodWeek,
        PeriodicityType.monthly => l10n.goalPeriodMonth,
        PeriodicityType.yearly => l10n.goalPeriodYear,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final maxTimes = _maxTimesFor(value.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in PeriodicityType.values)
              ChoiceChip(
                label: Text(_typeLabel(l10n, type)),
                selected: value.type == type,
                onSelected: (_) => onChanged(
                  Periodicity(
                    type: type,
                    // Al cambiar de tipo se recorta la cantidad a lo que cabe
                    // en el periodo nuevo (7 en una semana, 31 en un mes…).
                    timesPerPeriod: value.timesPerPeriod
                        .clamp(1, _maxTimesFor(type))
                        .toInt(),
                  ),
                ),
              ),
          ],
        ),
        if (value.type != PeriodicityType.daily) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.habitTimesLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: value.timesPerPeriod > 1
                    ? () => onChanged(
                        value.copyWith(
                          timesPerPeriod: value.timesPerPeriod - 1,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${value.timesPerPeriod}',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: value.timesPerPeriod < maxTimes
                    ? () => onChanged(
                        value.copyWith(
                          timesPerPeriod: value.timesPerPeriod + 1,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          PeriodicityLabel.of(l10n, value),
          style: textTheme.bodyMedium?.copyWith(
            color: palette.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (deferredNotice != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.tint(AppColors.flame, .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: AppColors.flame,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    deferredNotice!,
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Tope coherente con el tipo: no cabe más de un registro por día.
  static int _maxTimesFor(PeriodicityType type) => switch (type) {
    PeriodicityType.daily => 1,
    PeriodicityType.weekly => 7,
    PeriodicityType.monthly => 31,
    PeriodicityType.yearly => 366,
  };
}
