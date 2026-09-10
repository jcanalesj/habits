import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:habits/theme/app_dimensions.dart';

/// Botón principal con degradado morado, flecha opcional y estado de carga.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingArrow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool trailingArrow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      child: Container(
        height: AppDimensions.buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.gradientEnd.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // Escala la etiqueta si no cabe (idiomas largos, fuentes
                // grandes) en lugar de desbordar.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (trailingArrow) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
