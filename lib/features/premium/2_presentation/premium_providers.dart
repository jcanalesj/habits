import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habits/env.dart';
import 'package:habits/features/auth/2_presentation/controllers/auth_controller.dart';
import 'package:habits/features/premium/1_domain/purchases_repository.dart';
// Capa de inyección de dependencias: único punto que conoce 3_data.
import 'package:habits/features/premium/3_data/revenuecat_purchases_repository.dart';

/// Premium forzado para pruebas (ver [Env.forcePremium]). Es un provider
/// para que los tests lo apaguen.
final forcePremiumProvider = Provider<bool>((ref) => Env.forcePremium);

/// Acceso completo temporal, independiente del estado de la suscripción.
/// Se mantiene como provider para poder desactivarlo en tests de paywall.
final premiumFeaturesFreeProvider = Provider<bool>(
  (ref) => Env.premiumFeaturesFree,
);

/// Tienda de la plataforma. Sin clave para ella, compras no disponibles.
final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) {
  if (kIsWeb) return const UnavailablePurchasesRepository();
  final key = Platform.isIOS
      ? Env.revenueCatIosKey
      : Platform.isAndroid
      ? Env.revenueCatAndroidKey
      : '';
  if (key.isEmpty) return const UnavailablePurchasesRepository();
  return RevenueCatPurchasesRepository(key);
});

/// Premium según la tienda, para el usuario con sesión. Asocia las compras
/// al uid de Firebase antes de escuchar.
final storeEntitlementProvider = StreamProvider<bool>((ref) async* {
  final userId = ref.watch(authControllerProvider.select((a) => a.value?.id));
  final purchases = ref.watch(purchasesRepositoryProvider);
  if (userId == null || !purchases.isAvailable) {
    yield false;
    return;
  }
  try {
    await purchases.identify(userId);
  } catch (error) {
    debugPrint('No se pudo identificar al usuario en la tienda: $error');
    yield false;
    return;
  }
  yield* purchases.watchEntitlement();
});
