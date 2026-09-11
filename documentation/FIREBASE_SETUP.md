# Guía paso a paso — Conectar la app a Firebase (Auth + Firestore)

> **Estado**: fases 0–6 completadas (infraestructura, Authentication real y hábitos en Firestore).
> Pendiente el motor de rachas (cache/rachas se lee pero aún no se escribe). Este documento es la hoja de ruta para sustituir el
> repositorio en memoria (`InMemoryHabitsRepository`) por Firebase, siguiendo la
> arquitectura ya montada: **solo cambia la capa `3_data`**; dominio y presentación no se tocan.
>
> Decisiones de backend aprobadas (10/09/2026): verificación de email por **enlace** nativo,
> Firestore en **eur3**, hábitos con **soft delete** (`deletedAt`), reasignación a `general`
> al borrar un ámbito, y **los registros como única fuente de verdad** (rachas = caché en
> `users/{uid}/cache/rachas`). Las Security Rules en `firestore.rules` las hacen cumplir y
> `firebase/rules-tests/` las prueba contra el emulador.
>
> Leyenda de cada paso: 🧑 lo haces tú (requiere tu cuenta/consola) · 🤖 lo puede hacer Claude Code · 🤝 juntos (comando en tu terminal con tu sesión iniciada).

---

## Fase 0 — Decisiones previas

### 0.1 🧑 Elegir el identificador definitivo de la app

> ✔ **Decidido y aplicado**:
> - Nombre visible: **Constanza** (iOS `CFBundleDisplayName`, Android `android:label`, título localizado en `.arb`).
> - Bundle id / applicationId: **`com.jcanales.constanza`** — aplicado en Android
>   (`namespace`, `applicationId`, paquete de `MainActivity`), iOS (`PRODUCT_BUNDLE_IDENTIFIER`
>   de Runner y RunnerTests) y macOS (`AppInfo.xcconfig`).
>
> Este es el id con el que se registrarán las apps en Firebase (paso 2.1).

### 0.2 🧑 Decidir entornos
Recomendado para el MVP: **un único proyecto Firebase** (`constanza-dev`) y crear el de
producción más adelante, cuando haya release. Alternativa: crear ya `constanza-dev` y
`constanza-prod` con `--dart-define` para elegir entorno (la arquitectura del proyecto ya
contempla `config_*.json`, ver ARCHITECTURE.md §9.1).

---

## Fase 1 — Herramientas e infraestructura

### 1.1 🧑 Instalar Firebase CLI e iniciar sesión
```bash
# macOS
curl -sL https://firebase.tools | bash    # o: npm install -g firebase-tools
firebase login
```

### 1.2 🤝 Instalar FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
# Asegúrate de tener ~/.pub-cache/bin en el PATH
```

### 1.3 🧑 Crear el proyecto Firebase
En la [consola de Firebase](https://console.firebase.google.com) → "Añadir proyecto"
(p. ej. `constanza-dev`). Google Analytics: opcional, se puede desactivar para el MVP.

> También puede hacerse por CLI: `firebase projects:create constanza-dev-XXXX`.

---

## Fase 2 — Conectar el proyecto Flutter

### 2.1 🤝 Registrar las apps y generar la configuración
Desde la raíz del repo, con tu sesión de Firebase iniciada:
```bash
flutterfire configure --project=<id-del-proyecto> --platforms=ios,android
```
Esto genera:
- `lib/firebase_options.dart` (se versiona en git)
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### 2.2 🤖 Añadir dependencias
```bash
flutter pub add firebase_core firebase_auth cloud_firestore
```
> Nota: la primera compilación de iOS tras esto tarda bastante (CocoaPods + SDKs de Firebase).

### 2.3 🤖 Inicializar Firebase en `main.dart`
```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 2.4 🤖 Versiones mínimas
El documento funcional (§10) fija Android 8.0 (API 26) e iOS 14, por encima de los
mínimos que exige Firebase — Claude fija `minSdk = 26` y el deployment target de iOS a 14
si no lo están ya.

---

## Fase 3 — Firestore

### 3.1 🧑 Crear la base de datos
Consola → Build → Firestore Database → "Crear base de datos":
- **Modo producción** (reglas restrictivas desde el inicio).
- **Región**: `eur3` (europe-west) — usuarios en España/UE (requisito RGPD del doc funcional §10).

### 3.2 🤖 Reglas de seguridad
Todo scoped por usuario (`request.auth.uid == userId`, doc funcional §10). Claude crea
`firestore.rules` en el repo y se despliegan con `firebase deploy --only firestore:rules` 🤝:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3.3 Modelo de datos (ya definido en el doc funcional §9.1)
| Colección/Documento | Contenido |
|---|---|
| `users/{userId}` | email, displayName, timezone, locale, subscription (solo backend), onboardingCompleted, timestamps |
| `users/{userId}/ambitos/{ambitoId}` | nombre, emoji, colorValue, esPredefinido, orden, timestamps (sin rachas) |
| `users/{userId}/habitos/{habitoId}` | nombre, emoji, colorValue, ambitoId, periodicidad, historialPeriodicidad, descansosPermitidos, tareaRecuperacion, recuperacionCooldownDias, recordatorioHora, orden, deletedAt (soft delete), timestamps (sin rachas) |
| `users/{userId}/registros/{habitoId}_{YYYY-MM-DD}` | habitoId, dia, tipo (completed/recovery/plannedRest), tz, createdAt — **fuente de verdad** |
| `users/{userId}/cache/rachas` | general, habitos, ambitos, calculadoHasta — caché derivada, reconstruible, puede no existir |

Modelo definitivo aplicado en `firestore.rules`, `FirestoreUserProfileRepository` y `FirestoreHabitsRepository`.

### 3.4 🤖 Persistencia offline
En iOS/Android viene activada por defecto (doc funcional §9.2, last-write-wins). Claude
lo deja explícito en la configuración e incluye un comentario con la decisión.

---

## Fase 3.4 bis — Verificación de email DESACTIVADA (temporal)

Firebase genera los enlaces de sus correos con `apiKey=` vacío en este
proyecto y su página de verificación falla. La causa está diagnosticada y no
es reparable desde fuera: la clave que Auth tiene registrada como clave del
proyecto (`client.apiKey`) es la **clave de Android**, restringida a apps
Android y por tanto inservible en un navegador, y ese campo es de solo
lectura en la API. Viene de haber creado el proyecto por CLI, sin clave de
navegador, registrando Android como primera app.

Mientras tanto la verificación queda desactivada:

| Dónde | Qué |
|---|---|
| `lib/env.dart` | `Env.requireEmailVerification = false` |
| `firestore.rules` | `isOwner()` ya no exige `email_verified` (línea comentada) |
| Alta | No se envía correo; se pasa a `/welcome` |
| `/verify-email` | La pantalla y sus tests siguen en el repo, fuera del flujo |

> ⚠️ **Para reactivarla hay que hacer las DOS cosas**: poner el flag a `true`
> y descomentar `email_verified` en las reglas, y desplegar las reglas. Con
> solo una de las dos, la app deja de funcionar.

Opciones de arreglo definitivo, pendientes de decisión: recrear el proyecto
desde la consola (con app web registrada primero), abrir ticket a soporte de
Firebase, o pasar a enlaces que abran la app (App Links / Universal Links).

---

## Fase 3.5 — Gestor de acciones de correo propio

### Por qué existe
Firebase genera los enlaces de sus correos (verificación, restablecimiento de
contraseña) con `apiKey=` **vacío** en este proyecto, porque se creó por CLI y
no tenía clave de navegador cuando se crearon las plantillas. Su página
alojada no puede resolver el proyecto sin esa clave y responde
*"The selected page mode is invalid"*. Crear una app web después no lo
arregló: los correos nuevos siguen saliendo sin clave.

### Solución
`public/auth/action.html` es un gestor propio publicado en Firebase Hosting
(gratis en Spark). Lleva la clave de navegador explícita —es pública por
diseño— y llama directamente a Identity Toolkit por REST, sin SDK. Cubre
`verifyEmail`, `resetPassword` (con formulario propio) y `recoverEmail`, en
español, siguiendo la paleta de la app.

```bash
firebase deploy --only hosting            # publica en constanza-dev.web.app
firebase emulators:start --only hosting   # pruebas locales en :5010
```

> 🧑 **Paso manual obligatorio**: consola → Authentication → Templates →
> "Personalizar URL de acción" → `https://constanza-dev.web.app/auth/action`.
> Sin esto los correos siguen apuntando a la página rota de Firebase. El
> idioma de la plantilla se cambia en esa misma pantalla.

---

## Fase 4 — Authentication

### 4.1 🧑 Activar el proveedor
Consola → Build → Authentication → Sign-in method → activar **Email/Password**.
(La arquitectura queda preparada para añadir Google/Apple en v2 sin reescritura, doc §8.)

### 4.2 🤖 Feature `auth` completa (nueva feature con las 4 capas)
- `0_entity`: `AppUser`.
- `1_domain`: `AuthRepository` abstracto + usecases (`SignInUsecase`, `SignUpUsecase`,
  `SignOutUsecase`, `SendPasswordResetUsecase`) con sealed results.
- `3_data`: `FirebaseAuthRepository`.
- `2_presentation`: páginas de login/registro/recuperación (componentes en `lib/components/`),
  textos en `.arb` (es/en), guard de navegación en GoRouter (redirect si no hay sesión).
- Verificación de email al registro y flujo estándar de recuperación (asunción del doc §8).

---

## Fase 5 — Sustituir el repositorio en memoria

### 5.1 🤖 `FirestoreHabitsRepository` en `3_data`
- `api/`: wrapper de acceso a Firestore (colecciones tipadas con `withConverter`).
- `mappers/`: DTO (mapas de Firestore) ⇄ entidades de `0_entity`.
- `repositories/firestore_habits_repository.dart`: implementa `HabitsRepository`.

### 5.2 🤖 Cambiar el cableado (una línea)
En `lib/features/habits/2_presentation/providers/habits_providers.dart`:
```dart
final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return FirestoreHabitsRepository(ref.read(firestoreProvider), ref.read(currentUserIdProvider));
});
```
`InMemoryHabitsRepository` se conserva para tests y para `main.mocked.dart`.

### 5.3 🤖 Sembrar ámbitos predefinidos
Al crear una cuenta se escriben los ámbitos predefinidos (Salud, Mente, Desarrollo,
Energía…) en `users/{uid}/ambitos` (doc funcional §4.4).

---

## Fase 6 — Desarrollo local y pruebas

### 6.1 🤝 Emuladores (recomendado)
```bash
firebase emulators:start --only auth,firestore     # UI en http://127.0.0.1:4000
```
La app apunta a los emuladores con un flag de compilación (ver `lib/env.dart`):
```bash
# iOS simulator / macOS
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
# Emulador Android (el host de la máquina es 10.0.2.2)
flutter run --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=FIREBASE_EMULATOR_HOST=10.0.2.2
```
En el emulador de Auth los correos no se envían: los enlaces de verificación y de
restablecimiento se consultan en la UI del emulador (pestaña Authentication) o vía REST
(`GET /emulator/v1/projects/constanza-dev/oobCodes`).

Pruebas de las Security Rules: `cd firebase/rules-tests && npm install && npm test`.

Flujo real de auth contra el emulador (simulador iOS, emuladores levantados):
```bash
flutter test integration_test/auth_flow_emulator_test.dart -d <device-id> \
  --dart-define=USE_FIREBASE_EMULATOR=true
# después, en un proceso nuevo, la persistencia de sesión:
flutter test integration_test/session_persistence_test.dart -d <device-id> \
  --dart-define=USE_FIREBASE_EMULATOR=true
```

### 6.2 🤖 Tests
- Unit tests de mappers y del repositorio con `fake_cloud_firestore` / `firebase_auth_mocks`.
- Los tests de dominio y widgets existentes no cambian (siguen usando el repo en memoria).

---

## Checklist resumen

- [x] 0.1 🧑 Decidir applicationId/bundle id definitivo → `com.jcanales.constanza` ✔
- [x] 0.2 🧑 Decidir entornos → un único proyecto `constanza-dev` para el MVP ✔
- [x] 1.1 🧑 `firebase login` ✔ (CLI instalada en `~/.npm-global/bin`, en PATH vía `.zshrc`)
- [x] 1.2 🤝 Instalar FlutterFire CLI ✔ (1.4.1, `~/.pub-cache/bin`)
- [x] 1.3 🧑 Crear proyecto → `constanza-dev` creado por CLI ✔
- [x] 2.1 🤝 `flutterfire configure` ✔ (apps iOS/Android registradas, `firebase_options.dart` generado)
- [x] 2.2–2.4 🤖 Dependencias + init en `main.dart` + minSdk 26 / iOS 14 ✔
- [x] 3.1 🧑 Crear Firestore → `(default)` en eur3, delete protection ✔ (10/09/2026)
- [x] 3.2 🤖🤝 Reglas de seguridad + índices desplegados ✔ (`firestore.rules`, `firestore.indexes.json`)
- [x] 3.4 🤖 Persistencia offline explícita ✔ (`lib/firebase_setup.dart`, `Settings(persistenceEnabled: true)`)
- [x] 4.1 🧑 Activar Email/Password ✔ (`firebase deploy --only auth`)
- [x] 4.2 🤖 Feature auth completa ✔ (`FirebaseAuthRepository`, verificación por enlace, perfil tras verificar)
- [x] 5.3 🤖 Seed de ámbitos ✔ (se hace al crear el perfil, `FirestoreUserProfileRepository`)
- [x] 5.1–5.2 🤖 `FirestoreHabitsRepository` + cableado por usuario ✔ (streams por snapshots, soft delete, ids de registro deterministas)
- [x] 6.1 🤝 Emuladores configurados en `firebase.json` (Auth 9099, Firestore 8080, UI 4000) ✔
- [x] 6.2 🤖 Tests: unitarios/widget con fakes, reglas (`firebase/rules-tests`), integration tests contra emulador ✔

**Siguiente acción**: decide el punto 0.1 (identificador) y el 0.2 (entornos), haz
`firebase login` y crea el proyecto (1.3). A partir de ahí Claude puede continuar con
todo lo marcado 🤖 en una sesión.
