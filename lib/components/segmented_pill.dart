import 'package:flutter/material.dart';
import 'package:habits/theme/app_theme.dart';

/// Selector segmentado de dos a cinco opciones: pista tintada y segmento
/// activo relleno del color primario. Con [expand] cada segmento ocupa el
/// mismo ancho y el control llena la fila; sin él se ajusta al contenido.
class SegmentedPill<T> extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.expand = false,
    this.keyOf,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;
  final bool expand;

  /// Clave por opción para los tests (`ValueKey`).
  final Key Function(T option)? keyOf;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.tint(palette.primary, .06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final option in options)
            if (expand)
              Expanded(child: _segment(context, option))
            else
              _segment(context, option),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, T option) {
    final palette = context.palette;
    final active = option == selected;
    return Semantics(
      button: true,
      selected: active,
      child: InkWell(
        key: keyOf?.call(option),
        onTap: () => onSelected(option),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: active ? palette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          // Las etiquetas largas se encogen en vez de cortarse con puntos
          // suspensivos: en un móvil estrecho cuatro segmentos no caben.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              labelOf(option),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: active ? palette.onPrimary : palette.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
