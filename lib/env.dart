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
}
