import 'package:flutter/material.dart';
import 'package:habits/components/app_form_dialog.dart';
import 'package:habits/localization/l10n.dart';
import 'package:habits/theme/app_theme.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// Color de las acciones destructivas en toda la app.
const dangerColor = Color(0xFFFF5A67);

/// Confirmación destructiva estándar. Devuelve true si el usuario confirma.
Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  String? body,
  String? confirmLabel,
  Key? dialogKey,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: context.palette.scrim,
    builder: (context) => AppFormDialog(
      key: dialogKey,
      hero: const AppDialogHero.cat(
        badge: PhosphorIconsBold.trash,
        color: dangerColor,
        asset: 'assets/images/gatotriste.png',
      ),
      title: title,
      helper: body,
      primaryLabel: confirmLabel ?? context.l10n.delete,
      primaryIcon: PhosphorIconsBold.trash,
      primaryColor: dangerColor,
      primaryKey: const ValueKey('confirm-delete'),
      onPrimary: () => Navigator.pop(context, true),
    ),
  );
  return confirmed ?? false;
}
