import 'package:flutter/material.dart';
import 'package:habits/components/constanza_logo.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';

/// Cabecera de marca para las pantallas de auth: logo, wordmark,
/// separador y lema en dos líneas.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.logoSize = 150,
    this.wordmarkSize = 40,
    this.spacing = 12,
  });

  final double logoSize;
  final double wordmarkSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Column(
      children: [
        ConstanzaLogo(size: logoSize),
        ConstanzaWordmark(fontSize: wordmarkSize),
        SizedBox(height: spacing),
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          l10n.taglineLine1,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          l10n.taglineLine2,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Pie de marca: loto + "Tu mejor versión, cada día."
class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.spa_outlined, size: 26, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          context.l10n.brandFooter,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
