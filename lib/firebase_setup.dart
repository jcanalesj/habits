import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:habits/env.dart';
import 'package:habits/features/auth/3_data/repositories/firebase_auth_repository.dart';
import 'package:habits/firebase_options.dart';

/// Inicializa Firebase y, si [Env.useFirebaseEmulator] está activo, conecta
/// Auth y Firestore a la Emulator Suite local antes de cualquier uso.
///
/// Es el único punto de la app que conoce la configuración de Firebase;
/// las features acceden a través de sus repositorios de `3_data`.
/// Clave de preferencias que pide vaciar la caché local de Firestore en el
/// próximo arranque (la deja puesta el cierre de sesión).
const clearFirestoreCacheOnStartKey = 'clear_firestore_cache_on_start';

Future<void> initializeFirebase({bool clearCache = false}) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initializeAppCheck();
  await _initializeCrashlytics();

  // Tras cerrar sesión, los datos del usuario anterior siguen en la caché
  // offline del dispositivo. Solo se puede vaciar antes de usar Firestore,
  // así que se hace aquí, al arrancar.
  if (clearCache) {
    try {
      await FirebaseFirestore.instance.clearPersistence();
    } catch (error) {
      debugPrint('No se pudo vaciar la caché de Firestore: $error');
    }
  }

  // Persistencia offline explícita (doc funcional §9.2): lectura y escritura
  // sin red con sincronización automática, resolución last-write-wins.
  // Debe fijarse antes de cualquier uso de Firestore y antes de conectar el
  // emulador (useFirestoreEmulator hace copyWith sobre estos settings).
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (Env.useFirebaseEmulator) {
    await FirebaseAuth.instance.useAuthEmulator(
      Env.firebaseEmulatorHost,
      Env.authEmulatorPort,
    );
    FirebaseFirestore.instance.useFirestoreEmulator(
      Env.firebaseEmulatorHost,
      Env.firestoreEmulatorPort,
    );
    FirebaseFunctions.instanceFor(
      region: FirebaseAuthRepository.functionsRegion,
    ).useFunctionsEmulator(Env.firebaseEmulatorHost, Env.functionsEmulatorPort);
  }
}

/// App Check: solo la app real (Play Integrity / App Attest) puede usar el
/// backend, no un script con la API key. En depuración se usa el proveedor
/// de debug (su token se registra en la consola de Firebase). Con el
/// emulador no aplica. La ACTIVACIÓN (enforcement) se hace en la consola:
/// ver documentation/RELEASE.md.
Future<void> _initializeAppCheck() async {
  if (Env.useFirebaseEmulator) return;
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
      providerApple: kReleaseMode
          ? const AppleAppAttestWithDeviceCheckFallbackProvider()
          : const AppleDebugProvider(),
    );
  } catch (error) {
    // Sin App Check la app sigue funcionando mientras no esté forzado.
    debugPrint('App Check no disponible: $error');
  }
}

/// Crashlytics: captura los errores de Flutter y los del motor/plataforma.
/// En depuración no se envía nada.
Future<void> _initializeCrashlytics() async {
  if (kIsWeb) return;
  final crashlytics = FirebaseCrashlytics.instance;
  try {
    await crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);
  } catch (error) {
    debugPrint('Crashlytics no disponible: $error');
    return;
  }
  if (!kReleaseMode) return;
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };
}
