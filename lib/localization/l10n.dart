import 'package:flutter/widgets.dart';
import 'package:habits/localization/gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// Acceso abreviado a los textos localizados: `context.l10n.myHabits`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
