import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habits/env.dart';
import 'package:habits/firebase_options.dart';

/// Inicializa Firebase y, si [Env.useFirebaseEmulator] está activo, conecta
/// Auth y Firestore a la Emulator Suite local antes de cualquier uso.
///
/// Es el único punto de la app que conoce la configuración de Firebase;
/// las features acceden a través de sus repositorios de `3_data`.
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
  }
}
