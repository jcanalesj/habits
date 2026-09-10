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
}
