import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/theme/app_theme.dart';

/// Punto único de entrada a las funciones Premium. Con suscripción devuelve
/// `true` sin mostrar nada; si no, abre siempre [dialogBuilder], aunque ya
/// se haya usado el acceso de prueba.
///
/// Mientras no haya pasarela de pago, el CTA "Ver planes" del diálogo (que
/// cierra con `true`) activa el acceso de prueba y deja continuar con la
/// acción que el usuario estaba haciendo.
Future<bool> requestPremiumAccess(
  BuildContext context,
  WidgetRef ref, {
  required WidgetBuilder dialogBuilder,
}) async {
  if (ref.read(premiumSubscribedProvider)) return true;
  final accepted = await showDialog<bool>(
    context: context,
    barrierColor: context.palette.scrim,
    builder: dialogBuilder,
  );
  if (accepted != true || !context.mounted) return false;
  ref.read(premiumPreviewEnabledProvider.notifier).enable();
  return true;
}
