import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habits/theme/app_theme.dart';

/// Logo de Constanza (assets/logo/logo.png): "C" con degradado, destello
/// interior y hojas.
class ConstanzaLogo extends StatelessWidget {
  const ConstanzaLogo({super.key, this.size = 200});

  /// Alto del logo; el ancho se ajusta a la proporción del asset (3:2).
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/logo.png',
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Wordmark "Constanza" en serif, como en el visual de marca.
class ConstanzaWordmark extends StatelessWidget {
  const ConstanzaWordmark({super.key, this.fontSize = 52});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Constanza',
      style: GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.authBrand,
        letterSpacing: 0.5,
      ),
    );
  }
}
