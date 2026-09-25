# Constanza

App de hábitos (Flutter + Firebase) con racha general, comodines, recordatorios
locales y registro de peso.

## Documentación

- [Arquitectura](documentation/ARCHITECTURE.md)
- [Configuración de Firebase](documentation/FIREBASE_SETUP.md)
- [Motor de rachas](documentation/PHASE5_STREAK_ENGINE.md)
- [Publicación en tiendas](documentation/RELEASE.md)
- [Auditoría pre-v1 y tareas pendientes](documentation/V1_AUDIT.md)

## Desarrollo

```bash
flutter pub get
flutter test
# Contra la Firebase Emulator Suite
firebase emulators:start
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

## Versionado

`pubspec.yaml` → `version: X.Y.Z+N`. Hay que incrementar `N` (build) en cada
subida a App Store Connect o Google Play.
