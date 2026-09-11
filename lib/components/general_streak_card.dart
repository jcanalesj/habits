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
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _atRisk ? l10n.streakAtRisk : l10n.generalStreak,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${streak.displayStreak}',
                style: textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const Spacer(),
              if (streak.bestStreak > 0)
                Text(
                  l10n.bestStreakLabel(streak.bestStreak),
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
            ],
          ),
          Text(
            l10n.consecutiveDays,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _message(l10n),
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          if (_atRisk) ...[
            const SizedBox(height: 14),
            if (wildcards.hasAny)
              FilledButton.icon(
                onPressed: onUseWildcard,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: colors.last,
                ),
                icon: const Text('🃏', style: TextStyle(fontSize: 16)),
                label: Text(l10n.useWildcard),
              )
            else
              // Sin saldo no se ofrece ninguna acción: las vías de anuncio y
              // de compra todavía no existen y no se simulan (§24/§50).
              Text(
                l10n.noWildcardsLeft,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
          if (wildcards.available > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('🃏', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.wildcardsAvailable(wildcards.available),
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
