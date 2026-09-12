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
class GeneralStreakCard extends StatelessWidget {
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

  bool get _atRisk => streak.status == StreakStatus.atRisk;

  String _message(AppLocalizations l10n) => switch (streak.status) {
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

    return Container(
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
                    if (streak.bestStreak > 0)
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
                          l10n.bestStreakLabel(streak.bestStreak),
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${streak.displayStreak}',
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
                if (_atRisk && !wildcards.hasAny) ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n.noWildcardsLeft,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ],
                if (wildcards.available > 0) ...[
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.white.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: _atRisk ? onUseWildcard : null,
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
                                l10n.wildcardsAvailable(wildcards.available),
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
    );
  }
}
