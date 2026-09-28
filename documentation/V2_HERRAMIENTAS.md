# Documento Funcional — v2 «Herramientas» (Constanza)

> **Estado del documento**: implementado (fases 0–6 en código, 27/09/2026). Recoge las decisiones del 24/09/2026 y las tomadas al implementar (sección 16). Lo marcado como «asunción» es detalle que no condiciona el modelo de datos y puede ajustarse sin coste.
> **Última actualización**: 27/09/2026
> **Documentos relacionados**: `# Documento Funcional — App de Hábitos`, `ARCHITECTURE.md`, `V1_AUDIT.md`, `PHASE5_STREAK_ENGINE.md`.

---

## 1. Introducción y objetivo

La v2 añade a Constanza una **quinta pestaña central, «Herramientas»**, con cinco utilidades de productividad y bienestar que complementan a los hábitos sin mezclarse con ellos:

| Herramienta | Qué resuelve | Color (paleta app) | Icono (Phosphor) |
|---|---|---|---|
| Pomodoro | Bloques de concentración con descansos | `AppColors.flame` | `timer` |
| Pasos | Ver los pasos del día y de la semana desde HealthKit / Health Connect | `AppColors.green` | `footprints` |
| Lista de la compra | Lista personal de cosas que comprar | `AppColors.blue` | `shoppingCart` |
| Finanzas | Control propio del dinero: movimientos, gastos fijos, inversiones y compras pendientes | `AppColors.lilac` | `wallet` |
| Tareas | Lista de tareas con fecha, hora y arrastre de las no terminadas | `AppColors.pink` | `checkSquare` |

Principios que no se negocian:

- **Ninguna herramienta cuenta para la racha ni escribe en `registros`.** Son utilidades, no hábitos.
- **Misma estética que el resto de la app**: se usan los componentes de `lib/components/` y la paleta `context.palette`. Ninguna pantalla define visuales propios que ya existan.
- **Toda la sección será de pago** (casi seguro). Durante el desarrollo queda abierta porque `premiumFeaturesFree` está activo; el bloqueo real llega con compras + Cloud Functions en una fase propia.
- **Datos aislados por usuario**, bajo `users/{uid}`, como todo lo demás. Nada compartido.

---

## 2. Alcance

### Dentro de v2
- Pestaña «Herramientas» con panel de tarjetas y registro de herramientas.
- Las cinco herramientas descritas en las secciones 6–10.
- Componentes reutilizables nuevos (sección 4) extraídos de patrones que hoy son privados de una pantalla.
- Reglas de Firestore para las colecciones nuevas.
- Textos en `es` y `en`.
- Puerta premium **en cliente** sobre el panel (sección 11), inactiva mientras dure el acceso libre.

### Fuera de v2
- Listas de la compra compartidas con otros usuarios.
- Sincronizar tareas o pomodoros con hábitos (por ejemplo, «marcar hábito al terminar un pomodoro»).
- Importar movimientos bancarios, cotizaciones automáticas de inversiones o conversión de divisas.
- Otros datos de salud además de pasos (el usuario se lo plantea; los tipos concretos están pendientes y no bloquean nada porque la capa `health` se diseña para añadir tipos).
- Widgets de pantalla de inicio.

---

## 3. Navegación

### 3.1 Pestaña
- Nueva rama en el `StatefulShellRoute.indexedStack` de `lib/navigation.dart` con **índice 2**. Orden final: Inicio (0), Hábitos (1), **Herramientas (2)**, Estadísticas (3), Perfil (4).
- `AppBottomNavBar` pasa de 4 a 5 `_NavItem`. Icono `squaresFour` (Regular / Fill al seleccionar), etiqueta `navTools` («Herramientas» / «Tools»). La píldora `primarySoft` de selección se mantiene tal cual.
- Ruta de la rama: `/tools` → `ToolsPanelPage`.

### 3.2 Rutas de cada herramienta
- Cada herramienta abre **a pantalla completa fuera del shell**, igual que `/profile/weight`: AppBar transparente, título centrado en w900 y botón atrás. Así el temporizador y los formularios disponen de toda la pantalla y no pelean con la barra inferior.
- Rutas: `/tools/pomodoro`, `/tools/steps`, `/tools/shopping`, `/tools/finance`, `/tools/tasks`. Subrutas de detalle (por ejemplo `/tools/finance/movement/:id`) cuelgan de la de su herramienta.
- Registro: `lib/features/tools/2_presentation/routes/routes.dart` expone `toolsRoutesProvider` (`Provider<List<GoRoute>>`) con la rama del panel, y cada herramienta expone el suyo (`pomodoroRoutesProvider`, …). `goRouterProvider` los observa y los extiende como ya hace con `habitsRoutesProvider`. Los sub-pages de Perfil siguen inline; no se tocan.

### 3.3 Estructura de carpetas
```
lib/features/tools/         # solo panel + registro (ToolDescriptor)
lib/features/pomodoro/
lib/features/steps/
lib/features/shopping/
lib/features/finance/
lib/features/tasks/
```
Cada feature sigue las capas `0_entity / 1_domain / 2_presentation / 3_data` con sus barrels (`entity.dart`, `domain.dart`, `presentation.dart`, `data.dart`), como `habits`. **No** se replica el layout plano de `profile/weight`.

---

## 4. Sistema visual y componentes

### 4.1 Reglas de estilo (heredadas)
- Paleta por `context.palette`; colores de acento por herramienta de `AppColors` (tabla de la sección 1). Fondos de icono con `palette.tint(color, .10)`.
- Tipografía `Theme.of(context).textTheme`: títulos de pantalla y de sección en `headlineSmall` / `titleLarge` w900; cuerpo en `textSecondary` con `height` 1.3–1.42; etiquetas pequeñas a 11–12 px.
- Tarjetas: superficie al .86–.92 de alfa, radio 22 (tarjetas de contenido) o 32 (`SurfaceCard`), borde `palette.border`, sombra `palette.shadow` blur 30 / offset (0,12) solo en tarjetas destacadas.
- Diálogos: `Dialog` transparente → `ConstrainedBox(maxWidth 430)` → `Material(dialogSurface, radio 32)` → scroll con padding (24, 22, 24, 24). Héroe arriba (gato con insignia circular de 42 px, o cuadrado redondeado de 72 px con icono tintado), título `headlineSmall` w900 centrado, ayuda secundaria, campos, CTA `FilledButton` a ancho completo (alto 52–54, radio 18, w800) y `TextButton` de cancelar debajo.
- Hojas inferiores: `showModalBottomSheet` con `showDragHandle: true` y fondo `surfaceElevated`, como `WildcardRescueSheet`.
- CTA principal de pantalla: `FilledButton.icon` a ancho completo con padding vertical 17, radio 20 y etiqueta w900 (patrón de «Registrar peso»). CTA de marketing: `GradientButton`.
- Avisos: `AppNotice.show(...)`; nunca `SnackBar` directo. Errores de carga: `AppErrorView` con reintento. Carga: `CircularProgressIndicator` centrado.
- Padding de página: `EdgeInsets.fromLTRB(20, 8, 20, 40)` en pantallas fuera del shell; `AppBottomNavBar.contentClearance + viewPadding.bottom` abajo en el panel.
- Sin FAB en toda la app: la acción de crear va en el CTA a ancho completo al final del scroll o en el botón tonal junto al `SectionHeader`.
- Colores destructivos: `Color(0xFFFF5A67)` con icono `trash`, como en peso.
- Selección de segmentos: píldora con pista `tint(primary,.06)` y segmento activo relleno `primary` a radio 15 (hoy `_RangeSelector` en peso).

### 4.2 Componentes nuevos en `lib/components/` (fase 0)
Se extraen de código privado existente para que las cinco herramientas los compartan. Se añaden al barrel `components.dart`.

| Componente | Origen | Descripción |
|---|---|---|
| `ToolCard` | nuevo, estilo `_WeightMetricCard` / `_ProfileMetric` | Tarjeta del panel: icono en contenedor de 44 px tintado, título 17 px w900, subtítulo 12 px secundario, **dato vivo** (línea 19 px w900) y `caretRight`. Corona `PremiumActiveTag`-style en la esquina si la herramienta es premium y el usuario no tiene acceso. |
| `MetricTile` | generaliza `_WeightMetricCard` | Tarjeta de métrica (icono, etiqueta, valor, detalle, opcional `onTap`). |
| `SegmentedPill<T>` | generaliza `_RangeSelector` | Selector segmentado de 2–4 opciones. |
| `EmptyStateBlock` | generaliza `_EmptyBlock` | Icono lila de 38 px + texto secundario centrado dentro de la decoración de superficie. |
| `AppFormDialog` | generaliza los diálogos de contraseña / peso | Andamio del diálogo descrito en 4.1: héroe, título, ayuda, `children`, CTA y cancelar, con estado `isBusy` y caja de error inline (rojo .08, radio 14). |
| `AppTextField` | generaliza `_PasswordDialogField` | Campo de formulario no-auth: prefijo Phosphor Bold en `primary`, relleno `surfaceMuted`, `OutlineInputBorder` radio 18, foco `primary` ancho 2. |
| `AmountField` | nuevo sobre `AppTextField` | Entrada de importe con teclado decimal, separador según `intl`, símbolo de moneda como sufijo; devuelve **céntimos enteros**. |
| `ProgressRing` | nuevo (`CustomPainter`, mismo trazo que `_WeightChartPainter`) | Anillo de progreso con grosor 12, pista `tint(color,.12)` y arco en gradiente `gradientStart→gradientEnd` o color plano. Lo usan Pomodoro y Pasos. |
| `DayStrip` | nuevo, reutiliza los puntos de `_WeekDots` | Tira horizontal de 7 días (ayer-hoy-próximos) con el día seleccionado en píldora `primary`. Lo usa Tareas. |
| `ConfirmDeleteDialog` | nuevo sobre `AppFormDialog` | Confirmación destructiva estándar (héroe gato con insignia `trash`). |

Las pantallas de peso y perfil **migran** a estos componentes en la misma fase para que no haya dos versiones del mismo visual (cambio sin efecto visible).

---

## 5. Panel «Herramientas» (`/tools`)

### 5.1 Anatomía
1. `HomeHeader` **no** se repite: el panel abre con `SectionHeader(l10n.toolsTitle)` y una línea secundaria («Utilidades para tu día a día»).
2. Rejilla de `ToolCard` a 2 columnas (relación 1 : 1.05, separación 12). Orden fijo: Tareas, Pomodoro, Lista de la compra, Finanzas, Pasos. Asunción: orden fijo en v2; reordenar personalizado queda para después.
3. Bajo la rejilla, tarjeta informativa `SurfaceCard` con `CatMascot` y texto «Las herramientas no afectan a tu racha» (una sola vez; se oculta al pulsar «Entendido», flag local en `shared_preferences`).

### 5.2 Dato vivo de cada tarjeta
| Herramienta | Dato vivo | Proveedor |
|---|---|---|
| Tareas | «3 pendientes hoy» | `todayTasksSummaryProvider` |
| Pomodoro | «2 pomodoros hoy» | `todayPomodoroCountProvider` |
| Compra | «5 por comprar» | `shoppingPendingCountProvider` |
| Finanzas | saldo del mes (`+120,50 €`) | `monthBalanceProvider` |
| Pasos | «6.240 / 8.000» | `todayStepsProvider` (o «Sin permiso» / «No disponible») |

### 5.3 Registro de herramientas
```dart
final class ToolDescriptor {
  final ToolId id;                 // tasks, pomodoro, shopping, finance, steps
  final String route;              // '/tools/tasks'
  final PhosphorIconData icon;
  final Color accent;              // AppColors.pink …
  final Set<TargetPlatform> platforms; // Pasos: {iOS, android}
  final bool premium;              // true en todas (v2)
}
```
`toolDescriptorsProvider` devuelve la lista filtrada por plataforma. En web/escritorio la tarjeta de Pasos **no aparece** (no se muestra deshabilitada; simplemente no está).

---

## 6. Tareas (`/tools/tasks`)

### 6.1 Objetivo
Lista de tareas con fecha, hora opcional y un mecanismo explícito para arrastrar lo no terminado. Es la herramienta que cubre lo que el usuario llamó «calendario»: la vista por días (`DayStrip`) hace de calendario ligero; no hay vista mensual en v2 (asunción).

### 6.2 Pantalla
1. AppBar transparente «Tareas».
2. `DayStrip` con 7 días centrados en hoy; se puede deslizar a semanas anteriores/siguientes. Día seleccionado por defecto: hoy.
3. `SegmentedPill`: **Día · Próximas · Sin fecha**.
   - *Día*: tareas del día seleccionado, pendientes arriba (ordenadas por hora y luego por `orden`), completadas debajo en una subsección «Completadas» plegada.
   - *Próximas*: pendientes con fecha > hoy agrupadas por día (cabecera secundaria «Mañana», «Jue 1 oct»).
   - *Sin fecha*: pendientes sin fecha.
4. Fila de tarea (`TaskTile`, mismo esqueleto que `HabitListTile`): casilla circular de 28 px a la izquierda (bordes `primary`, relleno `primary` con `check` blanco al completar), título w700 (tachado y secundario si completada), línea secundaria con hora y prioridad, `caretRight`. Deslizar a la izquierda muestra eliminar (fondo rojo .12 + `trash`).
5. Estado vacío: `EmptyStateBlock(checkSquare, «Nada pendiente para hoy»)`.
6. CTA a ancho completo «Nueva tarea» al final del scroll.

### 6.3 Crear / editar (`AppFormDialog`)
Campos: título (obligatorio, máx. 120), nota (opcional, máx. 500), fecha (chip con selector `DatePicker` del tema; «Sin fecha» permitido), hora (opcional, `showReminderTimePicker` reutilizado), prioridad (`SegmentedPill`: Baja · Normal · Alta). La hora solo se puede fijar si hay fecha.

### 6.4 Reglas
- Día lógico según la zona IANA del perfil, con `LogicalDate` (misma utilidad que hábitos). A diferencia de los hábitos, **sí se permiten fechas pasadas y futuras**.
- Completar una tarea guarda `completadaEn` (serverTimestamp) y no se puede «deshacer» pasados 7 días (asunción, evita ediciones históricas raras); antes de eso, tocar la casilla la reabre.
- Prioridad Alta pinta la línea secundaria en `AppColors.flame`.
- **Arrastre de tareas no terminadas** (decisión del 24/09): al abrir la app (o la herramienta) en un día lógico nuevo, si hay tareas pendientes con fecha < hoy se muestra una hoja inferior «Tienes N tareas sin terminar» con la lista y una casilla por tarea (todas marcadas), y dos botones: **«Pasar todas a hoy»** (`FilledButton`) y **«Pasar las seleccionadas»** (`OutlinedButton`, activo si hay selección parcial). «Ahora no» deja las tareas donde están y no vuelve a preguntar hasta el día siguiente (flag local `tasksRolloverAskedFor = YYYY-MM-DD`). Las que se mueven conservan hora y prioridad y guardan `arrastradaDesde` (fecha original) para mostrar una etiqueta «desde el lun 21».
- Recordatorio: si la tarea tiene fecha y hora, se programa una notificación local (misma infraestructura que `reminders`, id derivado del `taskId`) que se cancela al completar, editar o borrar. Sin Cloud Functions no hay notificaciones remotas.
- Borrado: físico (no hay racha que proteger). Confirmación con `ConfirmDeleteDialog` solo si la tarea tiene nota o está en el pasado; las demás se borran con «Deshacer» en el `AppNotice` durante 5 s.

### 6.5 Datos — `users/{uid}/tareas/{taskId}`
| Campo | Tipo | Notas |
|---|---|---|
| `titulo` | string 1–120 | |
| `nota` | string 0–500 | opcional |
| `fecha` | string `YYYY-MM-DD` o null | día lógico |
| `hora` | string `HH:mm` o null | solo si hay fecha |
| `prioridad` | `'baja' \| 'normal' \| 'alta'` | |
| `orden` | int | orden manual dentro del día (v2: se asigna al crear, sin drag & drop) |
| `completadaEn` | timestamp o null | |
| `arrastradaDesde` | string `YYYY-MM-DD` o null | |
| `createdAt` / `updatedAt` | timestamp | `isServerTime` |

Reglas: `read/create/update/delete if isOwner(uid)` + `validTask(d)` con `keys().hasOnly`, longitudes, `isDia(fecha)`, enum de prioridad y `isServerTime` en `createdAt`/`updatedAt`. Índice compuesto: `fecha ASC, orden ASC` y `completadaEn` para la consulta de arrastre (`fecha < hoy && completadaEn == null`).

---

## 7. Pomodoro (`/tools/pomodoro`)

### 7.1 Objetivo
Temporizador de concentración con ciclos trabajo / descanso corto / descanso largo, registro de sesiones completadas y ajustes propios.

### 7.2 Pantalla
1. AppBar «Pomodoro» con acción `gear` a la derecha que abre los ajustes (hoja inferior).
2. Bloque héroe centrado: etiqueta de fase («Concentración» / «Descanso» / «Descanso largo») en 12 px w800 mayúsculas con el color de fase; `ProgressRing` de 260 px con el tiempo restante `mm:ss` en 56 px w900 dentro y debajo «Pomodoro 2 de 4» en secundario.
   - Colores de fase: trabajo `AppColors.flame`, descanso corto `AppColors.green`, descanso largo `AppColors.blue`.
3. Fila de controles: botón principal circular de 72 px (`play` / `pause`, relleno `primary`) y a los lados dos `IconButton` tonales de 52 px: `arrowCounterClockwise` (reiniciar fase) y `skipForward` (saltar fase).
4. Campo opcional «¿En qué trabajas?» (`AppTextField`, máx. 60) que etiqueta la sesión.
5. `MetricTile` ×2: «Hoy» (pomodoros completados) y «Esta semana» (minutos de concentración).
6. Lista «Sesiones de hoy» (hora de inicio, etiqueta, duración) con `EmptyStateBlock(timer, …)`.

### 7.3 Ajustes (hoja inferior)
Concentración 15–60 min (por defecto 25), descanso corto 3–15 (5), descanso largo 10–30 (15), pomodoros por ciclo 2–6 (4), «Iniciar descansos automáticamente» (off), «Iniciar concentración automáticamente» (off), sonido al terminar (on), vibración (on). Selección con ruedas numéricas del mismo estilo que `showReminderTimePicker`.

### 7.4 Reglas
- El temporizador se basa en un **instante de fin** (`endAt`) y no en ticks acumulados: al pausar se guarda el restante; al reanudar se recalcula `endAt`. Sobrevive a cerrar la app: `endAt`, fase, número de pomodoro y etiqueta se persisten en `shared_preferences`; al volver, si `now >= endAt` se cierra la fase como completada.
- Al terminar una fase se dispara una **notificación local** inmediata («¡Concentración terminada! Toca un descanso de 5 min») programada en el momento de iniciar la fase con `flutter_local_notifications` (id fijo `pomodoroNotificationId`), y cancelada al pausar/saltar/reiniciar. Así suena aunque la app esté en segundo plano sin depender de temporizadores en background.
- Solo las fases de **concentración completas** se registran como sesión. Saltar una fase de trabajo no la registra. Un descanso no genera documento.
- Un pomodoro completado hoy incrementa el dato vivo del panel. No toca `registros` ni rachas.
- Sesiones más antiguas de 90 días se pueden borrar desde ajustes («Borrar historial»); no hay borrado automático en v2.

### 7.5 Datos
`users/{uid}/pomodoro/config` (doc único):
`trabajoMin`, `descansoCortoMin`, `descansoLargoMin`, `pomodorosPorCiclo`, `autoDescanso`, `autoTrabajo`, `sonido`, `vibracion`, `updatedAt`.

`users/{uid}/pomodoro/sesiones/items/{sessionId}`:
| Campo | Tipo |
|---|---|
| `dia` | `YYYY-MM-DD` (día lógico) |
| `inicio` | timestamp (cliente, momento real de inicio) |
| `duracionMin` | int 1–60 |
| `etiqueta` | string 0–60 |
| `createdAt` | serverTimestamp |

Reglas: `config` solo `create/update` con `validPomodoroConfig` (rangos de arriba); `sesiones` `create/delete` con `validPomodoroSession`; sin `update` (una sesión no se edita).

---

## 8. Lista de la compra (`/tools/shopping`)

### 8.1 Objetivo
Lista **personal** de cosas por comprar, rápida de usar en el supermercado. Sin compartir (decisión 24/09).

### 8.2 Pantalla
1. AppBar «Lista de la compra» con acción `dotsThreeVertical` → menú (`PopupMenu` del tema): «Vaciar comprados», «Vaciar todo».
2. Barra de entrada rápida fija arriba (`AppTextField` con prefijo `plus` y botón «Añadir» tonal): escribir + Enter añade el artículo y deja el campo listo para el siguiente. Se acepta «2 leche» → cantidad 2, nombre «leche» (asunción: número inicial = cantidad).
3. Sección «Por comprar»: filas `ShoppingTile` (casilla circular igual que en Tareas, nombre w700, cantidad/nota en secundario). Tocar la casilla la pasa a «En el carrito» con animación de tachado; deslizar elimina.
4. Sección «En el carrito» plegada por defecto con contador; sus filas tachadas y en secundario; tocar la casilla las devuelve a «Por comprar».
5. Estado vacío: `EmptyStateBlock(shoppingCart, «Tu lista está vacía»)`.

### 8.3 Reglas
- Una única lista en v2 (asunción coherente con «solo personal»; el modelo deja `listaId` para admitir varias después).
- Los artículos se ordenan por `createdAt` descendente en «Por comprar» y por `compradoEn` descendente en «En el carrito».
- «Vaciar comprados» borra físicamente los marcados tras confirmar (`ConfirmDeleteDialog`). «Vaciar todo» idem.
- Nombre 1–80 caracteres, cantidad 1–999 (opcional), nota 0–120 (opcional). Editar abre un `AppFormDialog` con esos tres campos.
- Funciona offline con la persistencia de Firestore; no se necesita nada adicional.

### 8.4 Datos — `users/{uid}/listasCompra/{listaId}/items/{itemId}`
`listaId` = `'principal'` en v2. Doc de lista: `users/{uid}/listasCompra/principal` con `nombre`, `createdAt`.
Item: `nombre`, `cantidad` (int o null), `nota` (string o null), `compradoEn` (timestamp o null), `createdAt`, `updatedAt`.
Reglas: owner + `validShoppingItem(d)`; se permite `delete`.

---

## 9. Finanzas (`/tools/finance`)

### 9.1 Objetivo
Control propio del dinero, no contabilidad: saber cuánto entra, cuánto sale, qué está comprometido cada mes, cuánto hay invertido y qué compras están planeadas. Cuatro partes aprobadas el 24/09: **movimientos, gastos fijos mensuales, inversiones y compras pendientes**.

### 9.2 Pantalla
1. AppBar «Finanzas» con acción `gear` → ajustes (moneda, día de inicio del mes).
2. Tarjeta héroe del mes (gradiente `tint(primary,.06)→tint(lilac,.06)`, radio 28, como la de peso): «Septiembre» en `headlineSmall` w900, saldo del mes grande (ingresos − gastos − fijos ya registrados), dos líneas «Ingresos» / «Gastos» en secundario y `LinearProgressIndicator` «Fijos registrados 3 de 5». Flechas `caretLeft/Right` para cambiar de mes.
3. `SegmentedPill` de 4: **Movimientos · Fijos · Inversiones · Pendientes**.
4. Contenido según segmento (ver 9.3–9.6), siempre con `EmptyStateBlock` propio y CTA a ancho completo al final («Nuevo movimiento», «Nuevo gasto fijo», «Nueva inversión», «Nueva compra pendiente»).

### 9.3 Movimientos
- Lista del mes agrupada por día (cabecera secundaria «Hoy», «Ayer», «Vie 19 sept»). Fila: icono de categoría en contenedor tintado, concepto w700, categoría en secundario, importe a la derecha (gastos en `textPrimary` con «−», ingresos en `AppColors.green` con «+»).
- Formulario: tipo (`SegmentedPill` Gasto · Ingreso), importe (`AmountField`), concepto (1–80), categoría (chips del tema; predefinidas: Casa, Comida, Transporte, Ocio, Salud, Ropa, Suscripciones, Regalos, Nómina, Otros), fecha (por defecto hoy, se admite pasado), nota opcional.
- Deslizar elimina con «Deshacer» de 5 s.

### 9.4 Gastos fijos mensuales
- Lista de compromisos recurrentes: nombre, importe, «día 5 de cada mes», interruptor activo. Total mensual comprometido en cabecera.
- Un gasto fijo **no crea movimientos solo**. Cada mes aparece en su fila un botón tonal «Registrar en septiembre» que crea el movimiento de gasto (concepto = nombre, categoría = la del fijo, `gastoFijoId` enlazado) y el fijo pasa a «Registrado ✓» para ese mes. Motivo: el usuario controla su dinero a mano; sin Functions no hay quien lo automatice fiablemente en todos los dispositivos.
- Formulario: nombre (1–80), importe, día del mes (1–28 para evitar meses cortos; asunción), categoría, activo.

### 9.5 Inversiones (valor manual)
- Lista: nombre, tipo (chips: Fondos, Acciones, Cripto, Depósito, Inmueble, Otro), «Aportado 1.000 €», «Valor actual 1.120 €», rentabilidad «+120 € (+12 %)» en verde/rojo. Cabecera: total aportado, valor total, rentabilidad total.
- Editar el valor actual es la acción principal de la fila (botón tonal «Actualizar valor»); guarda `valorActualCents` y `valorActualizadoEn`. Sin histórico de valores en v2 (asunción; se puede añadir subcolección después sin migración).
- «Aportar» añade a `aportadoCents` y opcionalmente crea un movimiento de gasto con categoría «Inversión» (interruptor en el formulario, por defecto **on**).

### 9.6 Compras pendientes
- Lista de cosas que se quieren comprar más adelante: nombre, importe estimado, fecha objetivo opcional, prioridad (Baja · Normal · Alta). Ordenada por prioridad y fecha. Total estimado en cabecera.
- Acción principal «Comprado»: crea el movimiento de gasto (con importe real que se pide en un `AppFormDialog` prellenado con el estimado) y marca `compradaEn`. Las compradas pasan a una subsección plegada «Compradas» y se pueden borrar.

### 9.7 Reglas comunes
- **Importes en céntimos enteros** (`int`) + **moneda ISO 4217** en el doc de configuración (`EUR` por defecto según locale `es`, `USD` en `en`; el usuario puede cambiarla). Una sola moneda por usuario en v2; cambiarla **no convierte** importes, solo cambia el símbolo (se avisa en el diálogo).
- Mes «fiscal» configurable: `diaInicioMes` 1–28 (por defecto 1). El héroe y el saldo usan ese rango.
- Formato de importes con `NumberFormat.currency` de `intl` según locale; entrada con `AmountField`.
- Fechas de movimiento como día lógico `YYYY-MM-DD`; se permiten pasadas, no futuras (asunción: un movimiento futuro es una «compra pendiente»).
- Categorías predefinidas por id estable (`casa`, `comida`, …) y traducidas por l10n; sin categorías personalizadas en v2.
- Borrado físico en todas las partes; borrar un gasto fijo no borra los movimientos que generó.

### 9.8 Datos
`users/{uid}/finanzas/config`: `moneda` (ISO, 3 letras), `diaInicioMes` (1–28), `updatedAt`.

`users/{uid}/finanzas/movimientos/items/{id}`: `tipo` (`'gasto'|'ingreso'`), `importeCents` (int > 0, ≤ 100 000 000), `concepto`, `categoria`, `fecha` (`YYYY-MM-DD`), `nota`, `gastoFijoId`, `inversionId`, `compraPendienteId` (todos opcionales/null), `createdAt`, `updatedAt`.

`users/{uid}/finanzas/gastosFijos/items/{id}`: `nombre`, `importeCents`, `diaDelMes` (1–28), `categoria`, `activo` (bool), `registradoMeses` (array de `YYYY-MM`), `createdAt`, `updatedAt`.

`users/{uid}/finanzas/inversiones/items/{id}`: `nombre`, `tipo`, `aportadoCents` (int ≥ 0), `valorActualCents` (int ≥ 0), `valorActualizadoEn` (timestamp), `createdAt`, `updatedAt`.

`users/{uid}/finanzas/comprasPendientes/items/{id}`: `nombre`, `importeEstimadoCents`, `fechaObjetivo` (o null), `prioridad`, `compradaEn` (o null), `movimientoId` (o null), `createdAt`, `updatedAt`.

Reglas: un bloque `match /users/{uid}/finanzas/{docId}` para `config` y cuatro bloques `match /users/{uid}/finanzas/{grupo}/items/{id}` con su `validXxx(d)` (`hasOnly`/`hasAll`, enums, rangos de céntimos, `isDia`, `isServerTime`). Índices: `movimientos` por `fecha DESC`; `comprasPendientes` por `compradaEn, prioridad, fechaObjetivo`.

Nota de diseño: se usa `finanzas/{grupo}/items` en vez de cuatro colecciones raíz bajo `users/{uid}` para que todo lo financiero cuelgue de un único nodo exportable y borrable de una vez (eliminar cuenta, exportar datos).

---

## 10. Pasos (`/tools/steps`)

### 10.1 Objetivo
Podómetro propio de Constanza: cuenta los pasos con el **sensor del dispositivo** (Core Motion en iOS, `TYPE_STEP_COUNTER` en Android) **sin depender de otras apps** (decisión del 27/09/2026, que sustituye a la de usar `health`). Muestra los pasos de hoy frente al objetivo, estima distancia y calorías, lleva la racha de días cumplidos, guarda el total de cada día en la cuenta y enseña la evolución completa desde que se usa Constanza. Solo iOS y Android.

### 10.2 Pantalla
1. AppBar «Pasos» con acción `arrowsClockwise` (volver a leer el sensor).
2. Primer uso: consentimiento con el gato e insignia `footprints` (qué se lee, qué se guarda, que no se comparte). «Permitir» pide el permiso del sistema (Movimiento y forma física / Actividad física). «Ahora no» deja un bloque con CTA para retomarlo.
3. Héroe: `ProgressRing` de 230 px con los pasos de hoy en 46 px w900, «de 8.000» o «¡Objetivo cumplido!», y «Te faltan N pasos». Debajo, punto verde «Contando con el sensor del móvil · Última actualización HH:mm».
4. `MetricTile` ×4 en dos filas: **Distancia** (medida por Core Motion o estimada con la zancada), **Calorías** (estimación), **Racha de objetivo** (días seguidos cumpliendo) y **Media 7 días**.
5. Botón tonal «Cambiar objetivo» (diálogo con −/+ de 500 en 500, 1.000–30.000; por defecto 8.000).
6. Tarjeta **«Tu evolución»** («Desde el 3 jun 2026»): `SegmentedPill` **7 días · 30 días · 1 año · Todo**, gráfico de barras (diario con línea de objetivo en 7 y 30 días; mensual en 1 año y Todo), rejilla de seis datos (total, media diaria, mejor día, días con objetivo, distancia, calorías) y lista: últimos días (con check si cumplen) o meses (con media diaria).
7. Nota al pie: los pasos se cuentan con la app cerrada; conviene abrirla de vez en cuando para guardar el total del día.

### 10.3 Felicitación
Al cruzar el objetivo del día aparece el **gato del gimnasio** (`gatogym.png`) en un `AppFormDialog` («¡Objetivo cumplido! Has dado N pasos hoy…», botón «¡Genial!») acompañado del confeti de `HabitCelebration`. Una sola vez por día lógico (flag local `steps_celebrated_<uid>`).

### 10.4 Estimaciones (`StepsEstimator`)
- Zancada = 41,4 % de la altura del perfil de peso; 0,74 m si no hay perfil. En iOS se prefiere la distancia medida por Core Motion.
- Calorías = km × peso (kg) × 0,57; 70 kg si no hay perfil. Siempre marcadas como estimación.

### 10.5 Reglas
- **iOS**: `CMPedometer.startUpdates(from: inicioDelDía)` da los pasos del día completos (también los dados con la app cerrada; el sistema conserva siete días). Al abrir, `query` rellena los días anteriores que falten en la cuenta.
- **Android**: el sensor entrega un acumulado desde el arranque. `StepLedger` (Dart puro, persistido en `shared_preferences`) convierte cada lectura en pasos del día: primera lectura = referencia; contador menor = reinicio; cambio de día = la diferencia va al día actual. Los pasos entre dos aperturas de la app se atribuyen al día en que se abre (compromiso documentado).
- El día se corta con la zona IANA del perfil. El total nunca baja dentro del mismo día (otro dispositivo puede haber guardado más).
- Guardado en Firestore con 3 s de retardo tras cada cambio y al salir de la pantalla.
- Sin sensor: estado «Sin sensor de pasos» que sigue mostrando el histórico de la cuenta.

### 10.6 Datos
`users/{uid}/pasos/config`: `objetivo` (int 1000–30000), `consentimientoSalud` (bool), `updatedAt`.
`users/{uid}/pasos/{YYYY-MM-DD}`: `pasos` (int 0–200000), `distanciaM` (int o null), `fuente` (`'pedometer'`), `updatedAt`.
Reglas como `peso`: `docId == 'config'` valida config; cualquier otro id debe cumplir `isDia(docId)` y `validStepsDay(d)`.

### 10.7 Nativo
- iOS: `NSMotionUsageDescription`; canales `constanza/pedometer` y `constanza/pedometer/updates` en `AppDelegate.swift` (`PedometerChannel`).
- Android: permiso `ACTIVITY_RECOGNITION` (runtime en Android 10+), `uses-feature stepcounter` opcional; canales en `MainActivity.kt` con `onRequestPermissionsResult`.

---

## 11. Premium

- **Decisión**: toda la sección es de pago. **De momento no se cobra**: `premiumFeaturesFree` mantiene todo abierto y `ToolDescriptor.premium = true` no tiene efecto visible hasta que se desactive.
- Cuando se active el cobro: la pestaña y el panel **siguen visibles para todos** (se ve qué hay). Cada `ToolCard` muestra una corona; al tocar, `requestPremiumAccess(context, ref, dialogBuilder: _PremiumToolsDialog)` con el estilo de `_PremiumMessageLimitDialog` (imagen `premium.png`, título, tres `_PremiumBenefit`, «Ahora no» + botón degradado «Ver planes»). Si hay acceso, navega.
- Las rutas de las herramientas también comprueban `premiumAccessProvider` en un `redirect` a `/tools` para que un deep link no salte la puerta.
- Reglas de Firestore: mientras `premiumFeaturesFree()` sea `true` en `firestore.rules`, las colecciones nuevas no exigen premium. Cuando se cierre, cada `allow create/update` de las secciones 6–10 añade `&& (premiumFeaturesFree() || isPremiumUser(uid))`; la lectura y el borrado se mantienen libres para que un usuario que deja de pagar pueda ver y borrar lo suyo.
- Bloqueo fiable (custom claim con Functions/Blaze) queda en la fase de compras, según `constanza-blaze-pending`.

---

## 12. Transversal

- **Localización**: prefijos `tools*`, `tasks*`, `pomodoro*`, `shopping*`, `finance*`, `steps*` en `app_es.arb` / `app_en.arb`. Placeholders con bloque `@key`; recuentos con sufijo `WithCount`.
- **Offline**: todo funciona con la persistencia de Firestore; Pomodoro y el arrastre de tareas usan además `shared_preferences`. Pasos necesita el dispositivo con datos de salud, no red.
- **Eliminar cuenta**: la Cloud Function de borrado debe incluir las colecciones nuevas (`tareas`, `pomodoro`, `listasCompra`, `finanzas`, `pasos`). Apuntado en `V1_AUDIT` fase 1.
- **Exportar datos** (pendiente de roadmap): el nodo `finanzas` y `tareas` se diseñan para exportarse a CSV sin transformación (campos planos).
- **Analítica/Crashlytics**: eventos `tool_opened{tool}`, `pomodoro_completed`, `task_rolled_over{count}`; sin datos financieros en eventos.
- **Accesibilidad**: todos los iconos-botón con `tooltip`; anillos y barras con `Semantics(label)`; tamaños mínimos táctiles de 44 px.

---

## 13. Fases de implementación

| Fase | Contenido | Entregable verificable |
|---|---|---|
| 0 | Pestaña + `AppShell` a 5 ramas + panel + `ToolDescriptor` + componentes de 4.2 (con migración de peso/perfil) | Panel navegable con 5 tarjetas y datos vivos en «—»; capturas en claro y oscuro |
| 1 | Tareas completa (6) + rules + índices + tests de rules | Crear, completar, arrastrar, recordatorio local |
| 2 | Pomodoro (7) | Ciclo completo con app en segundo plano y notificación |
| 3 | Lista de la compra (8) | Entrada rápida, carrito, vaciar |
| 4 | Finanzas (9) | Cuatro segmentos, saldo del mes, fijos registrables |
| 5 | Pasos (10) + permisos + textos de tienda | Lectura real en iOS y Android; estados sin permiso / no disponible |
| 6 | Puerta premium activa + rules con `isPremiumUser` + redirect | Con `premiumFeaturesFree=false`, tarjetas con corona y paywall |

Estado el 27/09/2026: **todas las fases están implementadas en la rama `v2`**. Las reglas e índices de Firestore están desplegados en `constanza-dev`. La fase 6 queda latente: `premiumFeaturesFree` sigue en `true`, así que la puerta Premium existe pero no bloquea.

---

## 14. Criterios de aceptación (resumen)

- Las cinco tarjetas del panel se ven idénticas en claro y oscuro y usan solo `context.palette` y `AppColors`.
- Marcar tareas, pomodoros, compras, movimientos o pasos **no altera** `registros`, `cache/rachas` ni ninguna racha (test de integración que compara la racha antes y después).
- El temporizador termina a la hora correcta con la app cerrada y la notificación llega en iOS y Android.
- Al cambiar de día con tareas pendientes atrasadas aparece la hoja de arrastre una única vez por día y respeta «todas» / «seleccionadas».
- Los importes se guardan en céntimos enteros y se muestran con el formato del locale; no hay `double` en el modelo de finanzas.
- Sin permiso de salud, la pantalla de pasos explica qué hacer y no falla.
- Las rules rechazan documentos con claves desconocidas, rangos fuera de límite y timestamps de cliente en `createdAt` (tests en `firebase/rules-tests`).
- Todo texto visible existe en `es` y `en`.

---

## 15. Registro de decisiones

- ✔ 24/09/2026 — Nombre «Herramientas»; quinta pestaña central (índice 2).
- ✔ 24/09/2026 — Lista de la compra solo personal.
- ✔ 24/09/2026 — Tareas no terminadas: aviso que ofrece pasar todas o algunas a hoy.
- ✔ 24/09/2026 — Toda la sección de pago, pero abierta durante el desarrollo.
- ✔ 24/09/2026 — «Gastos» pasa a ser «Finanzas» con cuatro partes; céntimos enteros + moneda ISO.
- ✔ 24/09/2026 — Pasos con el paquete `health` (HealthKit + Health Connect).
- ✔ 27/09/2026 — Herramientas a pantalla completa fuera del shell; panel dentro de la rama.
- ✔ 27/09/2026 — Componentes compartidos extraídos a `lib/components/` antes de la primera herramienta.
- ✔ 27/09/2026 — Gastos fijos se registran a mano cada mes (sin automatismo hasta tener Functions).
- ✔ 27/09/2026 — Datos financieros bajo un único nodo `finanzas`.
- 🔲 Pendiente — qué otros datos de salud leer además de pasos.
- 🔲 Pendiente — reordenación personalizada de tarjetas del panel y vista mensual de tareas (fuera de v2).
- 🔲 Pendiente — fecha de activación del cobro (depende de Blaze y compras).

---

## 16. Registro de implementación (27/09/2026)

Desviaciones y detalles decididos al implementar, para que el documento y el código cuenten lo mismo:

- **Borrado siempre con confirmación**: en Tareas, Compra y Finanzas el deslizamiento abre `ConfirmDeleteDialog`; no hay «Deshacer» de 5 s (la app no usa SnackBar y `AppNotice` no admite acciones). La fila no se desliza fuera hasta que Firestore la quita.
- **Ajustes de Pomodoro con pasos (−/+)** en vez de ruedas numéricas: más claro en una hoja inferior con ocho ajustes.
- **Notificaciones de herramientas**: `NotificationsRepository` gana `syncTagged`/`cancelTagged` (payload `tool:<etiqueta>:<id>`) y `cancelHabitReminders`. La sincronización de hábitos ya no cancela las notificaciones de tareas ni del pomodoro; cerrar sesión sí cancela todo.
- **Pomodoro**: el controlador vive con `keepAlive` mientras dura la sesión y se invalida en `session_cleanup`; el estado se guarda en `shared_preferences` por usuario (`pomodoro_state_<uid>`). La notificación de fin lleva `silent` según el ajuste de sonido; la vibración es un `HapticFeedback` en primer plano.
- **Lista de la compra**: una sola lista `principal`; el documento de lista es opcional (las rules lo admiten pero la app no lo escribe).
- **Finanzas**: `formatMoney` usa `NumberFormat.simpleCurrency` (símbolo, no código). Un movimiento no admite fecha futura; el «mes» arranca el día configurado (1–28) y su clave `YYYY-MM` es la del mes en que empieza.
- **Pasos (27/09/2026, segunda versión)**: se retira el paquete `health` y toda su configuración (HealthKit, Health Connect). El contador es nativo (`PedometerSource` sobre canales propios, `FakePedometerSource` para tests), el histórico es completo y viene de Firestore, y la felicitación usa el gato del gimnasio. Ver sección 10.
- **Eliminar cuenta**: la Cloud Function ya borra `users/{uid}` de forma recursiva, así que las colecciones nuevas se van con la cuenta sin cambios en `functions/`.
- **Peso**: la pantalla usa ya `MetricTile`, `EmptyStateBlock`, `SegmentedPill` y `surfaceDecoration` compartidos (sin cambio visible).
- **Tests**: 40 casos nuevos de Dart (componentes de cada herramienta, controladores y páginas) y 62 de reglas contra el emulador. Los seis fallos de reglas preexistentes («gratis…», «premium caducado…», «peso: config no se borra») vienen de la promoción `premiumFeaturesFree` y no de esta sección.
- **Pendiente para publicar**: texto de privacidad con el recuento de pasos (fase 2 de `V1_AUDIT`), probar el contador en un iPhone y un Android reales (el simulador no tiene sensor) y activar el cobro (`premiumFeaturesFree = false` en app, rules y functions).
