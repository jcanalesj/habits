import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/features/habits/2_presentation/welcome/cold_start_welcome.dart';
import 'package:habits/features/premium/2_presentation/paywall_page.dart';
import 'package:habits/theme/app_theme.dart';

/// Punto único de entrada a las funciones Premium. Con suscripción devuelve
/// `true` sin mostrar nada; si no, abre [dialogBuilder], que explica la
/// función, y su CTA "Ver planes" (que cierra con `true`) lleva a la
/// pantalla de planes. Devuelve true solo si el usuario acaba con Premium.
Future<bool> requestPremiumAccess(
  BuildContext context,
  WidgetRef ref, {
  required WidgetBuilder dialogBuilder,
}) async {
  if (ref.read(premiumSubscribedProvider)) return true;
  final wantsPlans = await showDialog<bool>(
    context: context,
    barrierColor: context.palette.scrim,
    builder: dialogBuilder,
  );
  if (wantsPlans != true || !context.mounted) return false;
  return showPaywall(context);
}
