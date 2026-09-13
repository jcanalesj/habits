import 'package:flutter/material.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Tarjeta destacada con la racha general del usuario.
///
/// Muestra tres situaciones distintas (§36):
///  - normal: la racha viva y si hoy ya cuenta;
///  - racha en peligro: ayer quedó vacío y todavía se puede rescatar;
///  - saldo de comodines, cuando es relevante.
///
/// Durante la ventana de rescate se enseña la racha ANTERIOR
/// ([StreakState.displayStreak]), no el valor ya roto: es una decisión de
/// presentación, el dominio conserva los dos números por separado.
class GeneralStreakCard extends StatefulWidget {
  const GeneralStreakCard({
    super.key,
    required this.streak,
    required this.wildcards,
    this.onUseWildcard,
  });

  final StreakState streak;
  final WildcardBalance wildcards;

  /// Null si no hay nada que rescatar o si no hay saldo.
  final VoidCallback? onUseWildcard;

  @override
  State<GeneralStreakCard> createState() => _GeneralStreakCardState();
}

class _GeneralStreakCardState extends State<GeneralStreakCard> {
  bool _collapsed = false;

  bool get _atRisk => widget.streak.status == StreakStatus.atRisk;

  String _message(AppLocalizations l10n) => switch (widget.streak.status) {
    StreakStatus.atRisk => l10n.streakAtRiskBody,
    StreakStatus.completedToday => l10n.streakSafeToday,
    StreakStatus.pendingToday => l10n.streakPendingToday,
    StreakStatus.none => l10n.streakStartToday,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    // En peligro el degradado pasa a tonos de alerta para que el estado se
    // lea de un vistazo sin cambiar la estructura de la tarjeta.
    final colors = _atRisk
        ? const [Color(0xFFF97316), Color(0xFFDC2626)]
        : const [AppColors.gradientStart, AppColors.gradientEnd];

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Container(
        key: ValueKey(_collapsed),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/cards/card1.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            if (_collapsed)
              _CompactStreakContent(
                streak: widget.streak,
                wildcards: widget.wildcards,
                atRisk: _atRisk,
                onExpand: () => setState(() => _collapsed = false),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _atRisk ? l10n.streakAtRisk : l10n.generalStreak,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (widget.streak.bestStreak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              l10n.bestStreakLabel(widget.streak.bestStreak),
                              style: textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          key: const Key('collapse-streak-card'),
                          onPressed: () => setState(() => _collapsed = true),
                          tooltip: l10n.collapseStreakCard,
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.18,
                            ),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_up_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.streak.displayStreak}',
                      style: textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                      ),
                    ),
                    Text(
                      l10n.consecutiveDays,
                      style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 185,
                      child: Text(
                        _message(l10n),
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                    ),
                    if (_atRisk && !widget.wildcards.hasAny) ...[
                      const SizedBox(height: 10),
                      Text(
                        l10n.noWildcardsLeft,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                    if (widget.wildcards.available > 0) ...[
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.white.withValues(alpha: 0.76),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: _atRisk ? widget.onUseWildcard : null,
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/protector.png',
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.wildcardsAvailable(
                                      widget.wildcards.available,
                                    ),
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primaryDeep,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactStreakContent extends StatelessWidget {
  const _CompactStreakContent({
    required this.streak,
    required this.wildcards,
    required this.atRisk,
    required this.onExpand,
  });

  final StreakState streak;
  final WildcardBalance wildcards;
  final bool atRisk;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('expand-streak-card'),
        onTap: onExpand,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 8, 11),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atRisk ? l10n.streakAtRisk : l10n.generalStreak,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${streak.displayStreak} ${l10n.days}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (wildcards.hasAny) ...[
                const SizedBox(width: 6),
                _CompactMetricBadge(
                  semanticLabel: l10n.wildcardsAvailable(wildcards.available),
                  icon: Image.asset(
                    'assets/icons/protector.png',
                    width: 35,
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                  value: '${wildcards.available}',
                ),
                const SizedBox(width: 7),
              ],
              if (streak.bestStreak > 0)
                _CompactMetricBadge(
                  semanticLabel: l10n.bestStreakLabel(streak.bestStreak),
                  icon: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFF59E0B),
                    size: 27,
                  ),
                  value: '${streak.bestStreak}',
                ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                onPressed: onExpand,
                tooltip: l10n.expandStreakCard,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: .18),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMetricBadge extends StatelessWidget {
  const _CompactMetricBadge({
    required this.semanticLabel,
    required this.icon,
    required this.value,
  });

  final String semanticLabel;
  final Widget icon;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    container: true,
    child: Container(
      height: 45,
      padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryDeep,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}
