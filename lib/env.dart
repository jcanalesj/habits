import 'package:flutter/foundation.dart' show kReleaseMode;

/// Configuración de entorno resuelta en tiempo de compilación con
/// `--dart-define` (ver ARCHITECTURE.md §9.1).
///
/// Ejemplos:
/// ```bash
/// # iOS simulator / macOS: emuladores en localhost
/// flutter run --dart-define=USE_FIREBASE_EMULATOR=true
/// # Emulador Android: el host de la máquina es 10.0.2.2
/// flutter run --dart-define=USE_FIREBASE_EMULATOR=true \
///             --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
/// ```
abstract final class Env {
  /// Si es true, Auth y Firestore apuntan a la Firebase Emulator Suite
  /// (puertos definidos en firebase.json) en lugar de a constanza-dev.
  static const useFirebaseEmulator = bool.fromEnvironment(
    'USE_FIREBASE_EMULATOR',
  );

  static const firebaseEmulatorHost = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: '127.0.0.1',
  );

  static const authEmulatorPort = 9099;
  static const firestoreEmulatorPort = 8080;
  static const functionsEmulatorPort = 5001;

  /// Verificación de email obligatoria para entrar y para acceder a los
  /// datos del usuario.
  ///
  /// DESACTIVADA temporalmente: los enlaces que genera Firebase en
  /// `constanza-dev` llegan con `apiKey` vacío y su página de verificación
  /// falla, por un defecto de creación del proyecto que no es reparable
  /// desde fuera (ver documentation/FIREBASE_SETUP.md §3.5).
  ///
  /// Para reactivarla hay que hacer DOS cosas, no solo esta:
  ///   1. Poner esto a `true`.
  ///   2. Volver a exigir `email_verified` en `firestore.rules` (hay un
  ///      comentario marcándolo) y desplegar las reglas.
  static const requireEmailVerification = false;

  /// Web pública (Firebase Hosting) con la política de privacidad, los
  /// términos y la página de borrado de cuenta.
  static const publicSiteUrl = String.fromEnvironment(
    'PUBLIC_SITE_URL',
    defaultValue: 'https://constanza-dev.web.app',
  );

  /// Claves PÚBLICAS del SDK de RevenueCat (no son secretas). Sin ellas las
  /// compras no están disponibles. Ver documentation/RELEASE.md §6.
  static const revenueCatIosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const revenueCatAndroidKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
  );

  /// Fuerza Premium en el cliente para probar sus funciones sin pasar por
  /// la tienda. NUNCA en release: `kReleaseMode` lo apaga aunque se pase el
  /// dart-define. En debug/profile va activo por defecto; se desactiva con
  /// `--dart-define=FORCE_PREMIUM=false`.
  ///
  /// Solo afecta a la app: las reglas de Firestore siguen exigiendo
  /// `subscription.status` real para las funciones Premium. Para probarlas
  /// de verdad, poner en la consola
  /// `users/{uid}.subscription = {status: 'active'}`.
  static const forcePremium =
      !kReleaseMode &&
      bool.fromEnvironment('FORCE_PREMIUM', defaultValue: true);

  /// Login con Google y Apple. Oculto en v1: sin implementar, los revisores
  /// de las tiendas rechazan botones que no hacen nada (App Store 2.1). Si se
  /// activa Google, Apple exige también "Sign in with Apple" (4.8).
  static const socialLoginEnabled = false;
}
