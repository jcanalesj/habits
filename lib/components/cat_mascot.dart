import 'package:flutter/material.dart';

/// Recorte reutilizable del gato de la identidad visual de la app.
class CatMascot extends StatelessWidget {
  const CatMascot({super.key, required this.size, this.circular = true});

  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E1FF),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size * .25),
      ),
      child: Transform.scale(
        scale: 2.15,
        alignment: const Alignment(.62, .48),
        child: Image.asset(
          'assets/images/cards/card1.png',
          fit: BoxFit.cover,
          alignment: const Alignment(.72, .46),
        ),
      ),
    );
  }
}
