import 'package:flutter/material.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Tira horizontal de semanas (lunes a domingo) con el día seleccionado en
/// una píldora primaria y un punto bajo "hoy". Se desliza entre semanas.
///
/// Es el calendario ligero de Tareas: trabaja con [LogicalDate], sin horas
/// ni zonas, como todo lo demás.
class DayStrip extends StatefulWidget {
  const DayStrip({
    super.key,
    required this.selected,
    required this.today,
    required this.onSelected,
    this.markers = const {},
    this.inverted = false,
  });

  final LogicalDate selected;
  final LogicalDate today;
  final ValueChanged<LogicalDate> onSelected;

  /// Días con contenido (p. ej. tareas pendientes): muestran un punto.
  final Set<LogicalDate> markers;
  final bool inverted;

  @override
  State<DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<DayStrip> {
  /// Página central: semanas anteriores a la izquierda, siguientes a la
  /// derecha. Un tope grande sin ser infinito.
  static const _basePage = 520;

  late final PageController _controller = PageController(
    initialPage: _basePage + _weekOffset(widget.selected),
  );

  LogicalDate _startOfWeek(LogicalDate date) =>
      date.addDays(-(date.weekday - DateTime.monday));

  int _weekOffset(LogicalDate date) =>
      _startOfWeek(widget.today).differenceInDays(_startOfWeek(date)) ~/ 7;

  @override
  void didUpdateWidget(DayStrip old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected && _controller.hasClients) {
      final page = _basePage + _weekOffset(widget.selected);
      if (_controller.page?.round() != page) {
        _controller.animateToPage(
          page,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return SizedBox(
      height: 76,
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (context, page) {
          final monday = _startOfWeek(
            widget.today,
          ).addDays((page - _basePage) * 7);
          return Row(
            children: [
              for (var offset = 0; offset < 7; offset++)
                Expanded(
                  child: _DayChip(
                    date: monday.addDays(offset),
                    selected: monday.addDays(offset) == widget.selected,
                    isToday: monday.addDays(offset) == widget.today,
                    marked: widget.markers.contains(monday.addDays(offset)),
                    inverted: widget.inverted,
                    locale: locale,
                    onTap: () => widget.onSelected(monday.addDays(offset)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.marked,
    required this.inverted,
    required this.locale,
    required this.onTap,
  });

  final LogicalDate date;
  final bool selected;
  final bool isToday;
  final bool marked;
  final bool inverted;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final weekday = DateFormat.E(
      locale,
    ).format(DateTime.utc(date.year, date.month, date.day));
    final letter = weekday.replaceAll('.', '').substring(0, 1).toUpperCase();
    final foreground = selected
        ? palette.onPrimary
        : isToday
        ? palette.primary
        : (inverted ? const Color(0xFF90899F) : palette.textSecondary);

    return Semantics(
      button: true,
      selected: selected,
      label: DateFormat.yMMMMEEEEd(
        locale,
      ).format(DateTime.utc(date.year, date.month, date.day)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? (inverted ? null : palette.primary)
                  : isToday
                  ? (inverted
                        ? palette.primary.withValues(alpha: .08)
                        : palette.tint(palette.primary, .08))
                  : Colors.transparent,
              gradient: selected && inverted
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    )
                  : null,
              borderRadius: BorderRadius.circular(18),
              boxShadow: selected && inverted
                  ? [
                      BoxShadow(
                        color: AppColors.gradientEnd.withValues(alpha: .28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  letter,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: selected
                        ? palette.onPrimary
                        : (inverted
                              ? const Color(0xFF666076)
                              : palette.textPrimary),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: marked
                        ? (inverted
                              ? (selected ? Colors.white : palette.primary)
                              : (selected
                                    ? palette.onPrimary
                                    : palette.primary))
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
