# Auditoría pre-v1 — Constanza

Fecha: 24/09/2026 · Rama: `feature/refine-statistics-and-navigation`

Estado general: `flutter analyze` sin avisos · `flutter test` 356 ✅ / 1 ❌
(`test/features/habits/data/firestore_habits_repository_test.dart:106`, ver D4).

Leyenda de prioridad: 🔴 bloquea la publicación · 🟠 fallo visible para el
usuario · 🟡 mejorable · ⚪ menor. Un ✅ delante del ID indica que ya está
resuelto en código (el detalle está en la sección 4, "Registro de cambios").

---

## 1. Hallazgos

### A. Tiendas, legal y publicación

| ID | Prio | Hallazgo | Dónde |
|---|---|---|---|
| ✅ A1 | 🔴 | No existe "Eliminar cuenta". Apple (5.1.1(v)) y Google Play lo exigen, y Play pide además una URL web de borrado. Las reglas impiden al cliente borrar sus datos y no hay backend, así que los datos quedarían huérfanos (incumple el RGPD). | `lib/features/profile/profile_page.dart:170`, `firestore.rules:167,255,323,439,478` |
| ✅ A2 | 🔴 | "Términos" y "Política de privacidad" parecen enlaces pero no son pulsables, y no existen las páginas. Las dos tiendas exigen la política dentro de la app, y más aún con datos de salud (peso). | `lib/features/auth/2_presentation/pages/register_page.dart:516-527` |
| ✅ A3 | 🔴 | La release de Android se firma con la clave de debug y Google Play la rechaza. | `android/app/build.gradle.kts:38-43` |
| A4 | 🔴 | La app apunta al proyecto `constanza-dev`; no hay proyecto de producción. | `lib/firebase_options.dart:56,64`, `.firebaserc`, `google-services.json`, `GoogleService-Info.plist` |
| A5 | 🔴 | La verificación de email está desactivada en la app y en las reglas: cualquiera puede registrarse con un correo ajeno. | `lib/env.dart:38`, `firestore.rules:46-50` |
| ✅ A6 | 🔴 | Los botones de login con Google y Apple solo muestran "Próximamente". Apple rechaza funciones de relleno (2.1). | `lib/features/auth/2_presentation/pages/login_page.dart:72-79,229-237` |
| ✅ A7 | 🔴 | Falta `PrivacyInfo.xcprivacy` en iOS (UserDefaults es una API de "motivo requerido"). También falta `ITSAppUsesNonExemptEncryption` en `Info.plist`. | `ios/Runner/` |
| ✅ A8 | 🟡 | No hay App Check y las API keys no están restringidas. | `lib/firebase_setup.dart` |
| ✅ A9 | 🟡 | No hay Crashlytics: no se ven los fallos en producción. | — |
| ✅ A10 | 🟡 | `google_fonts` descarga las fuentes en tiempo de ejecución, lo que expone la IP del usuario (RGPD) y hace que falle la fuente sin conexión. | `lib/theme/app_theme.dart:334`, `lib/components/constanza_logo.dart:33` |
| ✅ A11 | ⚪ | Metadatos de plantilla: `version: 0.1.0` sin número de build, la descripción "A new Flutter project." en `pubspec.yaml` y en el README, y `CFBundleName` en minúsculas. | `pubspec.yaml`, `README.md`, `ios/Runner/Info.plist:18` |
| ✅ A12 | ⚪ | `public/auth/action.html` usa `innerHTML` con el email, y el hosting no tiene cabeceras de seguridad (CSP, `X-Frame-Options`, `Referrer-Policy`). | `public/auth/action.html:218`, `firebase.json` |
| ✅ A13 | ⚪ | `.firebase/hosting.*.cache` está commiteado. `MainActivity` tiene `exported="true"`, pero no hace falta porque los alias ya la lanzan. | `.gitignore`, `android/app/src/main/AndroidManifest.xml:17` |

### B. Premium y pagos

| ID | Prio | Hallazgo | Dónde |
|---|---|---|---|
| ✅ B1 | 🔴 | El botón "Ver planes" activa Premium gratis y para siempre en el dispositivo (SharedPreferences), para cualquier cuenta que inicie sesión en él. | `lib/features/profile/premium/premium_gate.dart:13-27`, `lib/features/habits/2_presentation/welcome/cold_start_welcome.dart:101-110` |
| ✅ B2 | 🔴 | No hay pasarela de pago: `subscription.status` solo lo puede escribir un backend, y ese backend no existe. | `lib/features/auth/3_data/repositories/firestore_user_profile_repository.dart:105-110` |
| ✅ B3 | 🟠 | Los límites Premium solo se aplican en el cliente: 5 hábitos, `themeMode: 'dark'` y `recordatorioMensaje` se pueden saltar con la API. Solo `customMotivationMessages` está protegido en las reglas. | `lib/features/habits/2_presentation/pages/habits_list_page.dart:20,38`, `firestore.rules:190,304-309,357` |
| ✅ B4 | 🟡 | El diálogo anuncia "Estadísticas avanzadas", pero las estadísticas no tienen ningún bloqueo. | `lib/features/habits/2_presentation/pages/habits_list_page.dart:151` |
| ✅ B5 | 🟡 | El tema oscuro queda disponible mientras la suscripción aún está cargando (`_isPremium != false`). | `lib/features/profile/appearance/theme_mode_preferences.dart:138` |
| ✅ | — | Correcto: el cliente no puede escribir `subscription` (`firestore.rules:150,160`). | — |

### C. Cuenta, sesión y flujos de autenticación

| ID | Prio | Hallazgo | Dónde |
|---|---|---|---|
| ✅ C1 | 🟠 | Cerrar sesión no limpia nada local. Siguen sonando los recordatorios del usuario anterior (con los nombres de sus hábitos), y se heredan el tema, el icono y el acceso Premium de prueba. La caché de Firestore sigue en disco y los providers que no son `autoDispose` no se reinician. | `lib/features/auth/2_presentation/controllers/auth_controller.dart:18`, `lib/features/auth/1_domain/usecases/sign_out_usecase.dart:19` |
| ✅ C2 | 🟡 | No se puede cambiar la contraseña ni el email desde dentro de la app. | `lib/features/profile/profile_page.dart` |
| ✅ C3 | 🟡 | "¿Olvidaste tu contraseña?" se queda en "Enlace enviado" hasta reiniciar la app, porque el provider no es `autoDispose`. Pasa lo mismo con los controllers de login, registro y verificación. | `lib/features/auth/2_presentation/controllers/forgot_password_controller.dart:67` |
| ✅ C4 | 🟡 | Si falla la escritura en Firestore al editar el nombre, el error queda sin tratar y el nombre de Auth deja de coincidir con el del perfil. | `lib/features/profile/profile_page.dart:30`, `lib/features/auth/2_presentation/controllers/auth_controller.dart:25-35` |
| ✅ C5 | ⚪ | Cerrar sesión no pide confirmación e ignora `SignOutFailed`. | `lib/components/sign_out_button.dart:16` |
| ✅ C6 | ⚪ | Solo aplica si se reactiva la verificación: "usar otra cuenta" no limpia `justRegisteredProvider`, y `verificationSent` persiste entre usuarios. | `verify_email_page.dart:96`, `verify_email_controller.dart:97` |

### D. Hábitos, rachas y fechas

| ID | Prio | Hallazgo | Dónde |
|---|---|---|---|
| ✅ D1 | 🟠 | **El "hoy" no cambia a medianoche.** Si la app vuelve de segundo plano al día siguiente, marcar un hábito escribe el registro en el día anterior, la racha se calcula mal y se puede gastar un comodín fuera de la ventana. | `lib/features/habits/2_presentation/providers/habits_providers.dart:40`, `watch_home_summary_usecase.dart:39` |
| ✅ D2 | 🟠 | Sin conexión, los `await` de las escrituras no terminan nunca y la UI se queda cargando: el formulario de hábito no se cierra y lo mismo pasa con el peso. | `lib/features/habits/3_data/repositories/firestore_habits_repository.dart:229,240,255,316,333,366`, `habit_form_page.dart:162` |
| D3 | 🟠 | Cada arranque lee todo el histórico de `registros` y además el año entero: coste de Firestore sin límite. | `firestore_habits_repository.dart:126-131`, `watch_home_summary_usecase.dart:44-51` |
| ✅ D4 | 🟠 | El `since` inicial de la periodicidad se deriva de `createdAt` con la zona del dispositivo y la ordenación no es estable. Es la causa del test que falla. | `lib/features/habits/3_data/mappers/habits_mappers.dart:42-65` |
| D5 | 🟡 | Mientras carga el perfil, el día lógico se calcula en UTC en vez de en la zona del perfil. | `habits_providers.dart:21-37` |
| ✅ D6 | 🟡 | En la primera semana de enero no se cargan los registros de los días de diciembre de esa semana. | `watch_home_summary_usecase.dart:44-45,79-83` |
| ✅ D7 | 🟡 | `updateHabit` reescribe el documento entero desde una copia antigua: puede resucitar un hábito borrado en otro dispositivo o pisar sus cambios. | `firestore_habits_repository.dart:239-251` |
| ✅ D8 | 🟡 | Reordenar son N escrituras sueltas sin batch y el error no se trata. | `home_controller.dart:204-214` |
| ✅ D9 | 🟡 | Comodines: el mes del cliente (zona del perfil) no coincide con el de las reglas (UTC), así que la concesión se rechaza al principio de cada mes. | `ensure_monthly_wildcard_grant_usecase.dart:24`, `firestore.rules:96` |
| ✅ D10 | 🟡 | Los hábitos con formato antiguo (fase 4) no se pueden borrar, ni tampoco sus ámbitos. Solo importa si quedan datos antiguos. | `firestore_habits_repository.dart:254,305`, `firestore.rules:344-353` |
| ✅ D11 | ⚪ | Doble toque rápido al marcar → error aunque el registro se ha creado. | `firestore_habits_repository.dart:327-349` |
| ✅ D12 | ⚪ | Al pasar un hábito de repeticiones a simple con progreso parcial hoy, ya no se puede completar ese día. | `firestore_habits_repository.dart:337` |
| ✅ D13 | ⚪ | A partir del cambio de periodicidad número 51, las reglas rechazan la edición (el límite es 50). | `change_habit_periodicity_usecase.dart:77`, `firestore.rules:355` |
| ✅ D14 | ⚪ | `syncCache` hace una lectura y una escritura en cada emisión y nadie lee esa caché. | `rebuild_streak_usecase.dart:37-52` |
| ✅ D15 | ⚪ | Editar un hábito son dos escrituras separadas (datos y periodicidad), así que puede quedar un guardado parcial. | `habit_form_page.dart:221-262` |

### E. Recordatorios

| ID | Prio | Hallazgo | Dónde |
|---|---|---|---|
| ✅ E1 | 🟠 | No se reprograman al conceder el permiso, al cambiar de zona horaria ni cuando llega la zona real tras arrancar en UTC. La huella no incluye ni la zona ni el permiso. | `lib/features/habits/2_presentation/controllers/home_controller.dart:66-81` |
| ✅ E2 | 🟠 | Poner una hora de recordatorio en un hábito no pide el permiso: el usuario nunca recibe el aviso y tampoco se le informa. | `habit_form_page.dart`, `reminder_time_picker.dart` |
| ✅ E3 | 🟡 | Si no se abre la app en 7 días, dejan de llegar los recordatorios. | `reminder_scheduler.dart:19` |
| ✅ E4 | 🟡 | Hay una condición de carrera entre dos `sync` seguidos: puede sonar el aviso de un hábito ya completado. | `local_notifications_repository.dart:119-164` |
| ✅ E5 | ⚪ | El día del cambio de hora (otoño), `nowMinutes` se calcula mal. Si la sincronización falla, no se reintenta. Los ids de notificación no son estables y `cancelAll` borraría avisos de futuras herramientas. | `home_controller.dart:80,134`, `habit_reminder.dart:29` |

### F. Errores e interfaz

| ID | Prio | Hallazgo | Dónde |
|---|---|---|---|
| ✅ F1 | 🟠 | Las pantallas de error muestran la excepción en crudo y no tienen botón de reintentar. En la Home, basta con que falle un stream cosmético para bloquear toda la pantalla. | `home_page.dart:55`, `habits_list_page.dart:70`, `statistics_page.dart:94`, `habit_calendars_page.dart:59` |
| ✅ F2 | 🟠 | Varias acciones fallan en silencio: marcar un hábito, cambiar repeticiones, reordenar, guardar zona horaria o avatar (valor optimista sin revertir). | `home_page.dart:204`, `home_controller.dart:171`, `timezone_page.dart:73`, `avatar_picker_page.dart:158` |
| ✅ F3 | 🟡 | Estadísticas y calendarios crean un stream nuevo en cada rebuild (parpadeo y listeners extra), y si el stream falla, el spinner no acaba nunca. | `statistics_page.dart:70-80`, `habit_calendars_page.dart:73,123` |
| ✅ F4 | 🟡 | El formulario de hábito muestra "no se ha podido guardar" cuando lo que ha fallado es la carga, y hace `setState` después de un `await` sin comprobar `mounted`. | `habit_form_page.dart:206,245,260,311` |
| ✅ F5 | 🟡 | Peso: no se puede borrar una medición, un reloj adelantado hace que las reglas rechacen el guardado, el alta son dos escrituras separadas y `updateGoal(null)` choca con las reglas. | `firestore.rules:255,265,293`, `weight_page.dart:128`, `firestore_weight_repository.dart:77` |
| ✅ F6 | ⚪ | Accesibilidad: faltan `tooltip`/`Semantics` en los botones sociales, mostrar contraseña, flechas de mes y botones ±. | ver informe de UI |
| ✅ F7 | ⚪ | Textos sin localizar: etiquetas de iconos, nombres de ciudades en la zona horaria y "Nickname" en español. | `progress_icon_picker.dart:24`, `habit_icon_catalog.dart:26`, `timezone_page.dart:22` |
| ✅ F8 | ⚪ | El router no tiene `errorBuilder`, los calendarios no tienen estado vacío y hay código muerto (`placeholder_page.dart`, `placeholder_content.dart`). | `navigation.dart` |

---

## 2. Cómo se conecta el pago (resumen)

1. **Pago dentro de la app, con Apple y Google.** Para funciones digitales no se permite Stripe ni PayPal. La comisión es del 15 % con los programas para pequeños desarrolladores.
2. **Cuentas:**
   - Apple Developer (99 $/año), con el acuerdo de apps de pago, datos bancarios y datos fiscales firmados en App Store Connect.
   - Google Play Console (25 $, un solo pago), con su perfil de pagos.
3. **Productos:** una suscripción mensual y una anual, con prueba gratis opcional, dadas de alta en las dos tiendas.
4. **RevenueCat (`purchases_flutter`):**
   - Hace las compras, valida los recibos y gestiona renovaciones, cancelaciones y "Restaurar compras".
   - Se identifica a cada usuario con `Purchases.logIn(uid)`, usando su uid de Firebase.
   - Es gratis hasta unos 2.500 $ al mes de ingresos.
5. **Backend:**
   - El webhook de RevenueCat llama a una Cloud Function, y esa función escribe `users/{uid}.subscription`.
   - `watchIsPremium` ya lee ese campo, así que no hay que tocarlo.
   - Hace falta el plan **Blaze**.
6. **Pantalla de planes (paywall):** precio, periodo, texto de renovación automática, enlaces a Términos y Privacidad, "Restaurar compras" y enlace a gestionar la suscripción.
7. **Pruebas:**
   - iOS: usuarios sandbox o un archivo StoreKit Configuration.
   - Android: testers de licencia y la pista de pruebas internas. Los productos no funcionan hasta que la app está subida a alguna pista.

---

## 3. Lista de tareas

👤 = lo tiene que hacer una persona (cuentas, consolas, claves, textos legales); no se puede resolver solo con código.

### Fase 1 — Infraestructura (desbloquea lo demás)
- [ ] 👤 Crear el proyecto Firebase `constanza-prod` y activar el plan Blaze. (A4)
- [ ] 👤 Separar dev y prod con `--dart-define` o flavors, y regenerar `firebase_options`, `google-services.json` y `GoogleService-Info.plist`. (A4)
- [ ] 👤 Desplegar reglas e índices en prod. (A4)
- [x] Inicializar Cloud Functions (`functions/`, TypeScript, `europe-west1`, emulador en el puerto 5001). (A1, B2)
- [ ] 👤 Arreglar las URL de acción de email en prod, reactivar `requireEmailVerification` y `email_verified` en las reglas. (A5)
- [x] Configurar `signingConfigs.release` desde `android/key.properties` y añadir `key.properties`, `*.jks` y `*.keystore` a `.gitignore`. (A3)
- [ ] 👤 Crear el keystore de subida y `android/key.properties`, y activar Play App Signing (ver `documentation/RELEASE.md`). (A3)

### Fase 2 — Requisitos de tienda y legales
- [x] Borradores de Política de privacidad, Términos y página de borrado en `public/` (incluyen los datos de salud). (A2)
- [ ] 👤 Completar los `[COMPLETAR: …]` (titular, NIF, email, fecha), revisarlos con asesoría legal y desplegar el hosting. (A2)
- [x] Añadir `url_launcher` y hacer pulsables los enlaces del registro; añadirlos también en Perfil › Legal y en la pantalla de planes. (A2)
- [x] Consentimiento explícito de datos de salud antes del cuestionario de peso (con enlace a la política y test); se guarda `consentimientoSalud` en la config. (A2)
- [x] Cloud Functions `deleteAccount` (callable, exige login reciente) y `cleanupDeletedUser` (Auth onDelete). (A1)
- [ ] 👤 Desplegar las funciones (requiere Blaze; ver `RELEASE.md` §2). (A1)
- [x] "Eliminar cuenta" en Perfil › Cuenta: explica qué se borra, avisa de cancelar la suscripción en la tienda, pide la contraseña, reautentica y limpia el dispositivo. (A1)
- [x] Página web `public/delete-account.html` para Google Play. (A1)
- [x] Ocultar los botones de Google y Apple en la v1 (`Env.socialLoginEnabled`). (A6)
- [x] Añadir `PrivacyInfo.xcprivacy` y `ITSAppUsesNonExemptEncryption = false`. (A7)
- [ ] 👤 Rellenar las fichas de privacidad: Data Safety en Play y etiquetas de privacidad en App Store. (A2, A7)
- [x] Pasar la versión a `1.0.0+1`, actualizar la descripción y el README, y poner `CFBundleName` como "Constanza". (A11)

### Fase 3 — Fallos visibles para el usuario
- [x] Hacer que el día se actualice solo: timer hasta la medianoche lógica + `AppLifecycleListener.onResume` → invalidar `todayProvider`. Recalcular `today` en `toggleToday` y `useWildcard`. (D1)
- [x] Cerrar sesión con limpieza: `cancelAll()`, preferencias, icono clásico, tema claro e invalidar los providers de acceso (`lib/session_cleanup.dart`). (C1)
- [x] La caché offline de Firestore se vacía en el siguiente arranque tras cerrar sesión (`clear_firestore_cache_on_start`). (C1)
- [x] Añadir la zona horaria y el permiso a la huella de los recordatorios, y volver a sincronizar tras conceder el permiso y al volver a la app. (E1)
- [x] No programar recordatorios mientras la zona horaria del perfil está cargando. (E1, D5)
- [x] Pedir el permiso de notificaciones al guardar un hábito con hora, o avisar si está denegado. (E2)
- [x] Serializar la sincronización de recordatorios (cola en `HomeController`). (E4)
- [x] Añadir un aviso diario de respaldo más allá de los 7 días. (E3)
- [x] Que las escrituras no bloqueen la UI sin conexión: `awaitWrite` con `timeout` tratado como "encolado" (`lib/firestore_write.dart`). (D2)
- [x] Crear un widget común de error, con mensaje localizado y botón de reintentar, y usar valores por defecto para los streams cosméticos de la Home. (F1)
- [x] Mostrar `AppNotice` cuando falle marcar, cambiar repeticiones, reordenar, guardar zona horaria, avatar o nombre, y revertir los valores optimistas. (F2, C4)
- [x] La configuración inicial va siempre primera y la ordenación es estable; el test vuelve a pasar. (D4)

### Fase 4 — Premium y pagos
- [ ] 👤 Darse de alta en Apple Developer y Google Play Console, y completar los acuerdos, el banco y los impuestos.
- [ ] 👤 Decidir los precios, si habrá prueba gratis y si las estadísticas o las Herramientas serán Premium. (B4)
- [x] Mientras tanto, el diálogo ya no anuncia "Estadísticas avanzadas" (no existen): anuncia "Hazla tuya" (tema, iconos, avatares, mensajes). (B4)
- [ ] 👤 Crear los productos de suscripción en App Store Connect y en Play Console.
- [ ] 👤 Crear el proyecto en RevenueCat, con el entitlement `premium` y las offerings.
- [x] Integrar `purchases_flutter` (`lib/features/premium/`): `configure` perezoso, `logIn(uid)` con la sesión y `logOut` al cerrarla; claves por `--dart-define`.
- [x] Cloud Function `revenuecatWebhook`: valida la cabecera, pregunta a la API de RevenueCat el estado real (sin depender del orden de los eventos) y escribe `users/{uid}.subscription` con `expiresAt`. (B2)
- [x] Pantalla de planes (`PaywallPage`) con precio y periodo, prueba gratis, aviso de renovación, "Restaurar compras", "Gestionar suscripción" y enlaces legales; accesible también desde Perfil › Constanza Premium.
- [x] Sustituir el acceso de prueba de `requestPremiumAccess` por la pantalla de planes y eliminar `premium_preview_enabled`. (B1)
- [x] Reglas: tema oscuro y `recordatorioMensaje` solo con Premium vigente (comprobando `expiresAt`), sin bloquear a quien caduca. Límite de 5 hábitos en servidor con la función `enforceFreeHabitLimit`. (B3)
- [x] No conceder el tema oscuro mientras la suscripción está cargando. (B5)
- [ ] 👤 Probar con sandbox de iOS y con la pista de pruebas internas de Android: compra, renovación, cancelación, restauración y cambio de cuenta.

### Fase 5 — Calidad, coste y robustez
- [ ] 👤 **Decisión pendiente** — Reducir lecturas (D3). Las dos opciones contradicen la decisión aprobada de que `registros` es la única fuente de verdad y `cache/rachas` nunca decide: (a) agregado mensual `actividad/{YYYY-MM}` escrito en el mismo batch que cada registro, o (b) consulta acotada a los últimos N días usando `cache/rachas.mejorRacha` como suelo. Sin decidirlo, el coste por usuario sigue creciendo con el histórico. Recomendación: (a), porque mantiene la verdad en escrituras del cliente validadas por reglas y no depende de la caché.
- [x] Que `updateHabit` nunca escriba `deletedAt`. (D7)
- [x] Reordenar con `WriteBatch` (`HabitsRepository.reorderHabits`). (D8)
- [x] Edición de hábito en una sola escritura: `ChangeHabitPeriodicityUsecase.plan` + `UpdateHabitUsecase(timeline:)`. (D15)
- [x] Cargar la primera semana de enero desde el inicio de la semana (con test). (D6)
- [x] Hacer que la concesión de comodines use el mes del servidor (UTC) y reintentarla al volver a la app. (D9)
- [x] Borrar hábito y borrar ámbito incluyen la migración de los hábitos con formato antiguo. (D10)
- [x] Peso: permitir borrar mediciones, tolerar un reloj adelantado en las reglas, hacer el alta con batch y corregir `updateGoal(null)`. (F5)
- [ ] 👤 Desplegar las reglas (`firebase deploy --only firestore:rules`). (F5)
- [x] Mover estadísticas y calendarios a `StreamProvider.family` y tratar el caso de error. (F3)
- [x] Formulario de hábito: usar un mensaje propio para el error de carga y comprobar `mounted`. (F4)
- [x] Hacer `autoDispose` el de recuperar contraseña y reiniciar los demás al cerrar sesión. (C3)
- [x] "Cambiar contraseña" en Perfil › Cuenta, con reautenticación. (C2)
- [x] App Check en la app (Play Integrity / App Attest; proveedor debug fuera de release; desactivado con el emulador). (A8)
- [ ] 👤 Registrar las apps en Firebase › App Check, activar el enforcement en Firestore y Auth, y restringir las API keys en Google Cloud (ver `RELEASE.md` §1). (A8)
- [x] Crashlytics (`FlutterError.onError` + `PlatformDispatcher.onError`, solo en release; plugin Gradle; datos de fallos declarados en `PrivacyInfo.xcprivacy`). (A9)
- [ ] 👤 Activar Crashlytics en la consola de Firebase del proyecto de producción. (A9)
- [x] Fuentes Inter y Playfair Display en `assets/fonts/` (con sus licencias OFL registradas) y `allowRuntimeFetching = false`. (A10)
- [x] Reglas: cada frase de motivación es texto de ≤160 caracteres y la última entrada de `cambiosPeriodicidad` tiene forma válida (tope 400). (M2, D13)
- [x] Tests de reglas ampliados (Premium, peso) y datos de prueba corregidos: 172/172 contra el emulador. (B6)
- [x] Tests de `HomeController` (recordatorios con y sin permiso, sin reprogramar de más, cambio de día y guardia contra registros en el día anterior) con `InMemoryNotificationsRepository`.
- [x] Tests de los repositorios de Firestore: peso (alta atómica, borrar, objetivo) y hábitos (migración de formato antiguo al borrar/reasignar, reorden en batch). Han destapado y arreglado un fallo real en `awaitWrite` con `collection.add()` (registrar peso habría fallado).

### Fase 6 — Pulido
- [x] Estado vacío en los calendarios. (F8)
- [x] Accesibilidad: tooltips en mostrar/ocultar contraseña, flechas de mes y botones ±. (F6)
- [x] Localizadas las etiquetas de iconos, las ciudades de la zona horaria y "Nickname" → "Apodo". (F7)
- [x] `errorBuilder` en el router (pantalla "no existe" con botón al inicio) y código muerto eliminado. (F8)
- [x] Confirmación al cerrar sesión y aviso si falla. (C5)
- [x] Doble toque protegido en `HomeController`; el progreso parcial se sustituye al pasar a hábito simple; límite de cambios a 400; `syncCache` solo cuando cambia la racha. (D11–D14)
- [x] `.firebase/` en `.gitignore` y fuera del repo. (A13)
- [x] Hosting: usar `textContent` en `action.html` y añadir cabeceras de seguridad (`X-Frame-Options`, CSP `frame-ancestors`, `Referrer-Policy`, `nosniff`, HSTS). (A12)
- [x] ~~`exported="false"` en `MainActivity`~~ — descartado: con los alias de icono, `flutter run`/`adb` lanzan `MainActivity` por nombre y dejaría de arrancar; el riesgo real es nulo porque no recibe datos de otros intents. (A13)
- [x] Día del cambio de hora, ids de notificación estables y reintento de sincronización. (E5)

---

## 4. Registro de cambios

### 24/09/2026 — primera tanda

- **Tiendas:** botones sociales ocultos tras `Env.socialLoginEnabled`; firma de release desde `android/key.properties` (con debug como respaldo local); `PrivacyInfo.xcprivacy` añadido al target; `ITSAppUsesNonExemptEncryption = false`; `CFBundleName` "Constanza"; versión `1.0.0+1`; README real; `.firebase/` fuera del repo.
- **Día lógico (D1):** `todayProvider` se refresca con un temporizador hasta la medianoche lógica y al volver de segundo plano (`systemStateTickProvider` en `lib/app_lifecycle.dart`, disparado por un `AppLifecycleListener` en `HabitsApp`). La Home depende de él y `toggleToday`, `setTodayCount` y `useWildcard` descartan la acción si la Home estaba desfasada.
- **Recordatorios:** la huella incluye zona y permiso; se resincroniza al volver a la app y al conceder el permiso; no se programa hasta tener la zona del perfil; sincronizaciones en cola (sin carreras); la huella se guarda al terminar; minutos de reloj de pared (`LogicalCalendar.minutesOfDay`); aviso diario de respaldo tras el horizonte de 7 días; ids FNV-1a estables; se pide el permiso al poner una hora (formulario y Ajustes › Notificaciones).
- **Sin conexión (D2):** `awaitWrite` (`lib/firestore_write.dart`) en todas las escrituras de hábitos, ámbitos, registros, perfil y peso.
- **Datos:** `updateHabit` no envía `deletedAt`; reordenar en un `WriteBatch`; la configuración inicial de periodicidad siempre primera y orden estable; la semana de fin de año carga los días del año anterior; comodines con el mes del servidor.
- **Sesión (C1):** `lib/session_cleanup.dart` cancela avisos, restaura el icono clásico, quita el acceso de prueba, vuelve al tema claro e invalida los flujos de acceso. Recuperar contraseña es `autoDispose`.
- **Errores (F1–F4, C4):** `AppErrorView` con reintento en Home, Hábitos, Estadísticas, Calendarios, formulario y notificaciones; avisos de error al marcar, cambiar repeticiones, reordenar, zona horaria, avatar y nombre (con reversión del valor optimista); el nombre se guarda primero en el perfil y después en Auth; estadísticas y calendarios usan `logsBetweenProvider`.
- **Peso (F5):** borrar mediciones (UI + reglas), alta en un solo batch (`completeOnboarding`), margen de 5 min para el reloj en las reglas, `updateGoal` sin null.
- **Premium (B5):** el tema oscuro ya no se concede mientras carga la suscripción; si llega Premium después, se aplica el oscuro guardado.
- Tests: 363 ✅ (`flutter analyze` sin avisos).

### 24/09/2026 — segunda tanda

- **Borrar cuenta (A1):** `AuthRepository.reauthenticate/updatePassword/deleteAccount`, `DeleteAccountUsecase` y `ChangePasswordUsecase` (con tests), diálogos en `lib/features/profile/account/`, Cloud Functions `deleteAccount` y `cleanupDeletedUser`. La cuenta y los datos se borran en servidor; el dispositivo se limpia igual que al cerrar sesión.
- **Legal (A2):** `lib/legal_links.dart` (`Env.publicSiteUrl`), enlaces pulsables en el registro, sección Perfil › Legal y borradores en `public/privacy.html`, `public/terms.html` y `public/delete-account.html`.
- **Premium (B1–B4):** nueva feature `lib/features/premium/` (RevenueCat + tienda simulada para tests). `isPremiumProvider` combina Firestore (fiable) y la tienda (inmediata tras comprar); el acceso de prueba ha desaparecido. "Ver planes" abre `PaywallPage`. Webhook `revenuecatWebhook` y `enforceFreeHabitLimit` en Functions. Reglas con `isPremiumUser`/`subscriptionIsPremium`. `watchIsPremium` respeta `expiresAt`.
- **Hosting (A12):** `textContent` en `action.html` y cabeceras de seguridad en `firebase.json`.
- **Guía de publicación:** `documentation/RELEASE.md` con todos los pasos 👤 (Firebase prod, Blaze, secretos, keystore, tiendas, RevenueCat).
- Tests: 374 ✅ Flutter · 172 ✅ reglas (emulador) · `functions` compila.

### 24/09/2026 — tercera tanda

- **Salud/RGPD:** diálogo de consentimiento antes del cuestionario de peso; sin aceptar no se guarda nada.
- **Sesión:** la caché offline de Firestore se vacía en el siguiente arranque tras cerrar sesión; confirmación al cerrar sesión.
- **Datos:** edición de hábito atómica; migración de hábitos antiguos al borrar/reasignar; doble toque; sustitución del progreso parcial; `syncCache` solo cuando cambia la racha; reglas con validación de listas.
- **UI:** `errorBuilder` del router; tooltips; textos localizados; código muerto fuera.
- **Fuentes:** empaquetadas, sin descargas en tiempo de ejecución.
- Tests: 374 ✅ Flutter · 177 ✅ reglas · `functions` compila.

### 24/09/2026 — cuarta tanda

- **Seguridad y diagnóstico:** App Check y Crashlytics inicializados en `firebase_setup.dart` (ambos inertes en depuración y con el emulador); plugin de Crashlytics en Gradle; manifiesto de privacidad ampliado (datos de fallos, API de tiempo de arranque).
- **Tests:** `HomeController` cubierto (6 tests) y `InMemoryNotificationsRepository` en el entorno de tests, que además elimina el ruido del plugin de notificaciones en el resto de la suite. `resyncReminders` ya no reprograma si nada ha cambiado.
- **Pendiente de decisión:** D3 (coste de lecturas), porque cualquiera de las soluciones toca la decisión aprobada sobre la fuente de verdad.

### 24/09/2026 — cierre

- **Fallo real corregido:** `awaitWrite` fallaba en tiempo de ejecución con `collection.add()` (tipo de `onTimeout`); afectaba a registrar una medición de peso. Detectado por los tests nuevos de `FirestoreWeightRepository`.
- **Estado final:** `flutter analyze` sin avisos · **389** tests Flutter ✅ · **177** tests de reglas ✅ (emulador) · `functions` compila.
- **Lo que queda es de una persona (👤):** proyecto Firebase de producción y Blaze, despliegues (reglas, funciones, hosting), keystore, cuentas de Apple/Google, productos y RevenueCat, textos legales definitivos, fichas de privacidad, App Check/Crashlytics en consola, pruebas de compra en sandbox. Y una **decisión de diseño** (D3, coste de lecturas).

### 25/09/2026 — flag de pruebas Premium

- `Env.forcePremium`: Premium forzado en el cliente para probar sus funciones. Activo por defecto en debug/profile, se apaga con `--dart-define=FORCE_PREMIUM=false` y es **imposible en release** (`!kReleaseMode`). Los tests lo apagan siempre (`withoutForcedPremium`).
- Solo afecta a la app: las reglas siguen exigiendo `subscription.status` real (tema oscuro, mensaje del recordatorio). Para probar eso, poner en la consola `users/{uid}.subscription = {status: 'active'}`.
- ⚠️ Antes de publicar no hay que tocar nada, pero conviene recordar que un build `--profile` también lo tendría activo.
