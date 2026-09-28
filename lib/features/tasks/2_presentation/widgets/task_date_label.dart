import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/localization/l10n.dart';
import 'package:intl/intl.dart';

/// "Hoy", "Mañana", "Ayer" o "jue, 1 oct" según la distancia a hoy.
String taskDayLabel(
  AppLocalizations l10n,
  String locale,
  LogicalDate date,
  LogicalDate today,
) {
  final delta = today.differenceInDays(date);
  if (delta == 0) return l10n.tasksToday;
  if (delta == 1) return l10n.tasksTomorrow;
  if (delta == -1) return l10n.tasksYesterday;
  return DateFormat.MMMEd(
    locale,
  ).format(DateTime.utc(date.year, date.month, date.day));
}

/// "lun 21 sept" sin marcadores relativos, para "desde el …".
String taskShortDate(String locale, LogicalDate date) => DateFormat.MMMEd(
  locale,
).format(DateTime.utc(date.year, date.month, date.day));
