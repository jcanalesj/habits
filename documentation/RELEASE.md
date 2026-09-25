# Publicación de Constanza

Guía de los pasos que **no se pueden hacer desde el código**: cuentas,
consolas, claves y textos legales. Cada paso indica qué hallazgo de
[V1_AUDIT.md](V1_AUDIT.md) resuelve.

---

## 1. Firebase de producción (A4)

1. Crear el proyecto `constanza-prod` en la consola de Firebase.
   - Firestore en `eur3` (igual que dev).
   - Authentication con email/contraseña.
2. Pasarlo al plan **Blaze**. Lo exigen las Cloud Functions (borrar la cuenta
   y el webhook de Premium). Conviene fijar una alerta de presupuesto
   (por ejemplo 10 €/mes).
3. Añadirlo al repo:
   ```bash
   firebase use --add            # alias: prod
   flutterfire configure --project=constanza-prod \
     --out=lib/firebase_options_prod.dart
   ```
   Hoy la app solo tiene `firebase_options.dart` (dev). Hay dos opciones
   para elegir el entorno en compilación: sustituir el fichero antes de
   compilar la release, o usar flavors. Además hay que cambiar
   `google-services.json` y `GoogleService-Info.plist`.
4. Arreglar la acción de email (ver `FIREBASE_SETUP.md` §3.5) y reactivar la
   verificación (A5):
   - `lib/env.dart` → `requireEmailVerification = true`;
   - `firestore.rules` → descomentar `request.auth.token.email_verified`.
5. Desplegar:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,functions,hosting -P prod
   ```
6. Compilar la release apuntando a la web pública de producción:
   `--dart-define=PUBLIC_SITE_URL=https://<dominio-prod>`.
7. **App Check** (A8). La app ya lo activa sola (Play Integrity en Android,
   App Attest con DeviceCheck de respaldo en iOS, proveedor de depuración
   fuera de release). En la consola:
   - Firebase › App Check › registrar la app Android (huella SHA-256 de la
     clave de subida y de Play App Signing) y la app iOS (Team ID);
   - en depuración, copiar el token de debug que sale por consola y darlo de
     alta en App Check › Manage debug tokens;
   - activar el **enforcement** en Firestore y Authentication solo cuando
     todos los builds en uso ya envíen tokens (si no, dejan de funcionar);
   - Google Cloud › Credentials: restringir las API keys por aplicación
     Android (paquete + SHA), bundle iOS y referrers web del Hosting.
8. **Crashlytics** (A9): activarlo en Firebase › Crashlytics para el proyecto
   de producción. La app solo envía informes en modo release. En iOS, para
   ver las trazas simbolizadas, Xcode sube los dSYM con el script de
   Crashlytics (`Pods/FirebaseCrashlytics/run`) en una *Run Script phase*
   del target Runner; FlutterFire lo añade con `flutterfire configure`.

## 2. Cloud Functions (A1, B2)

Código en `functions/` (TypeScript, Node 22, región `europe-west1`).

| Función | Qué hace |
|---|---|
| `deleteAccount` (callable) | Borra `users/{uid}` con todas sus subcolecciones y después el usuario de Auth. Exige haber iniciado sesión en los últimos 5 minutos (la app reautentica antes). |
| `cleanupDeletedUser` (Auth onDelete) | Red de seguridad: si la cuenta se borra desde la consola, sus datos también se borran. |
| `revenuecatWebhook` (HTTP) | Recibe los eventos de RevenueCat, pregunta a su API el estado real y escribe `users/{uid}.subscription`. |

```bash
cd functions && npm install && npm run build
# Secretos del webhook (se piden por consola):
firebase functions:secrets:set REVENUECAT_WEBHOOK_AUTH -P prod
firebase functions:secrets:set REVENUECAT_API_KEY -P prod
firebase deploy --only functions -P prod
```

En local: `firebase emulators:start` y
`flutter run --dart-define=USE_FIREBASE_EMULATOR=true` (las funciones usan el
puerto 5001).

## 3. Firma de Android (A3)

```bash
keytool -genkey -v -keystore ~/constanza-upload.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

Crear `android/key.properties`. Está en `.gitignore`: **no se sube nunca**.
Guarda también una copia del `.jks` y de las contraseñas en un gestor de
contraseñas.

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/Users/<tu-usuario>/constanza-upload.jks
```

Sin este fichero la release se firma con la clave de debug, que sirve para
probar en local pero **Google Play la rechaza**. Al crear la app en Play
Console hay que activar **Play App Signing**.

## 4. Textos legales (A2)

Hay borradores en `public/privacy.html`, `public/terms.html` y
`public/delete-account.html`. Antes de publicar:

- completar todo lo marcado `[COMPLETAR: …]`: titular, NIF, dirección, email
  de contacto y fecha;
- revisarlos con asesoría legal, sobre todo por los datos de salud del
  registro de peso;
- desplegar el hosting.

La app los abre desde el registro y desde Perfil › Legal
(`Env.publicSiteUrl`).

## 5. Tiendas

### App Store Connect
- Apple Developer Program (99 $/año).
- En *Agreements, Tax, and Banking*: firmar **Paid Apps** y rellenar los datos
  bancarios y fiscales. Sin esto no funcionan las compras.
- Crear la app con el bundle `com.jcanales.constanza`.
- URL de privacidad: `https://<dominio>/privacy`.
- Etiquetas de privacidad: coinciden con `ios/Runner/PrivacyInfo.xcprivacy`
  (email, nombre, id de usuario, salud y contenido del usuario, vinculados
  a la identidad y sin rastreo).
- Crear el grupo de suscripciones *Premium* con los productos mensual y
  anual (ver §6).
- Para las pruebas de compra: crear usuarios de Sandbox.

### Google Play Console
- Cuenta de desarrollador (25 $, un solo pago) y perfil de pagos.
- Crear la app `com.jcanales.constanza` y subir un AAB a **Pruebas
  internas**. Los productos no se pueden probar hasta que haya un AAB subido.
- *Seguridad de los datos*: los mismos tipos de datos que en iOS, incluidos
  los datos de salud.
- *Eliminación de datos*: URL `https://<dominio>/delete-account`.
- Crear las suscripciones (ver §6).
- Añadir testers de licencia.

## 6. Premium con RevenueCat (B1, B2)

1. Crear el proyecto en RevenueCat y añadir las apps de iOS (con la clave de
   la App Store Connect API) y de Android (con la cuenta de servicio de
   Play).
2. Crear el entitlement **`premium`** y asociarle los productos de las dos
   tiendas.
3. Crear la offering **`default`** con los paquetes mensual y anual.
4. En *Integrations › Webhooks*:
   - URL: la de `revenuecatWebhook`
     (`https://europe-west1-<proyecto>.cloudfunctions.net/revenuecatWebhook`);
   - cabecera Authorization: el mismo valor que el secreto
     `REVENUECAT_WEBHOOK_AUTH`.
5. Compilar la app con las claves públicas del SDK:
   ```bash
   flutter build appbundle \
     --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx \
     --dart-define=PUBLIC_SITE_URL=https://<dominio>
   flutter build ipa \
     --dart-define=REVENUECAT_IOS_KEY=appl_xxx \
     --dart-define=PUBLIC_SITE_URL=https://<dominio>
   ```
   Sin claves, la pantalla de planes indica que las compras no están
   disponibles y nadie obtiene Premium.

## 7. Versionado

Antes de cada subida, subir el número de build en `pubspec.yaml`
(`1.0.0+1` → `1.0.0+2`).
