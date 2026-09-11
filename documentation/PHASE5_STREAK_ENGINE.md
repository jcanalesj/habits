# Fase 5 — Motor de racha general, periodicidad flexible y comodines

Documento de referencia del motor implementado. Complementa a
`documentation/ARCHITECTURE.md` (reglas de arquitectura) y a
`firestore.rules` (garantías de backend).

---

## 1. Principio fundamental

En esta versión de Constanza **solo existe la racha general del usuario**.

> Si el usuario completa al menos un hábito durante un día natural, ese día
> cuenta para su racha general.

Completar 1 hábito o completar 20 produce exactamente el mismo efecto: **+1
día**. Un día natural nunca aporta más de +1.

No existen: rachas por hábito, rachas por ámbito, rachas semanales/mensuales/
anuales, descansos planificados, descansos permitidos ni tareas de
recuperación. El único mecanismo para proteger la racha es el **comodín**.

Los ámbitos siguen existiendo para organizar hábitos, pero no tienen racha.

---

## 2. Fuente de verdad

**Los registros son la fuente de verdad.** La racha es un valor derivado y
reconstruible.

| Dato | Naturaleza |
|---|---|
| `users/{uid}/registros/**` | Fuente de verdad |
| `users/{uid}/diasProtegidos/**` | Fuente de verdad |
| `users/{uid}/comodines/saldo` | Fuente de verdad (entitlement) |
| `users/{uid}/cache/rachas` | **Proyección**, reconstruible, nunca autoridad |

La Home calcula la racha **en vivo** desde los registros y los días
protegidos; no lee la caché para decidir nada. La caché se puede borrar
entera y reconstruirse sin perder información (`RebuildStreakUsecase`).

---

## 3. Algoritmo de racha

`StreakCalculator.calculate()` es **Dart puro**: sin Firebase, sin Riverpod,
sin `BuildContext` y sin `DateTime.now()`. Entradas:

```dart
StreakState calculate({
  required Set<LogicalDate> activityDays,
  required Set<LogicalDate> protectedDays,
  required LogicalDate today,
});
```

Vocabulario:

- **día de actividad**: día con ≥ 1 registro de hábito realmente completado;
- **día protegido**: día sin actividad que un comodín mantiene unido;
- **día mantenido**: de actividad o protegido;
- **cadena**: racha maximal de días mantenidos consecutivos;
- **valor de cadena**: cuántos de sus días son de actividad.

Pasos:

1. Sin actividad → racha 0. **La racha no empieza al crear la cuenta**, sino
   con el primer hábito completado; los días anteriores no suman, no rompen y
   no requieren comodín.
2. `bestStreak` = máximo valor de cadena del histórico. Los días protegidos
   mantienen la continuidad pero **no se cuentan**: `actividad, actividad,
   comodín, actividad` vale **3**.
3. `currentStreak` (determinista):
   - hoy tiene actividad → valor de la cadena que acaba hoy;
   - hoy no, pero ayer está mantenido → valor de la cadena que acaba ayer;
   - en otro caso → 0 (la cadena anterior ya está rota).
4. `rescue` se emite si ayer quedó vacío, sin proteger, y la cadena que
   terminaba antes del hueco tenía valor > 0.

### Estado "racha en peligro"

La racha **no se rompe a las 00:00**. Durante todo el día siguiente existe una
ventana de rescate. Conviven dos valores reales, y el dominio los representa
por separado:

| Campo | Significado |
|---|---|
| `currentStreak` | Valor determinista. Si ayer se perdió, es 0 (o 1 si hoy ya hay actividad). |
| `rescue.streakAtRisk` | La racha que se pierde si no se rescata (p. ej. 24). |
| `rescue.streakIfRescued` | La racha resultante si se usa el comodín ahora (24, o 25 si hoy ya hay actividad). |
| `displayStreak` | **Decisión de presentación**: durante la ventana enseña `streakAtRisk`. |

Ejemplo canónico (racha 24, miércoles vacío):

| Momento | `currentStreak` | `displayStreak` | `status` |
|---|---|---|---|
| Jueves, sin hacer nada | 0 | 24 | `atRisk` |
| Jueves, completa un hábito | 1 | 24 | `atRisk` |
| Jueves, usa el comodín y ya había completado | 25 | 25 | `completedToday` |
| Viernes sin haber rescatado, con actividad del jueves | 1 | 1 | `completedToday`/`pendingToday` |

La ventana se deriva del argumento `today`, así que **caduca sola** al cambiar
de día: no hay estado mutable que expirar ni tarea programada.

---

## 4. Comodines

- Saldo fungible, **máximo 3** (el tope aplica al saldo total, no por origen).
- **+1 comodín gratuito al mes**, acumulable: 0→1→2→3, y 3→3.
- El comodín **protege pero no suma**: mantiene la cadena, no añade un día,
  no crea un registro falso, no marca ningún hábito y no rellena calendarios.
- Solo se puede proteger **el día inmediatamente anterior**, y solo durante el
  día siguiente. Después el pasado queda cerrado, aunque el usuario tenga
  comodines, consiga más, pague o vea anuncios.
- **Nunca se consume solo**: lo decide el usuario.

### Concesión mensual idempotente

No hay cron. Se aplica perezosamente al abrir la app:

```
meses = mesActual - ultimaConcesionYM      // mesActual = año*12 + mes
si meses <= 0 -> no hacer nada
saldo'  = min(3, saldo + meses)
ultimaConcesionYM' = mesActual
```

`ultimaConcesionYM` es **estrictamente monótono** y obligado a ser el mes
actual del servidor. Consecuencias: abrir la app 100 veces el día 1 concede
una sola vez; tres meses sin abrirla conceden lo que tocaba sin pasar de 3;
reinstalar no resetea nada (el estado vive en el servidor).

El mes se calcula en **UTC** (`request.time`), no en la zona del perfil,
porque las Rules no convierten zonas horarias. Siendo un tope de +1/mes con
máximo 3, un desfase de horas **nunca puede conceder de más**.

### Consumo atómico

Una **transacción** de Firestore con dos escrituras:

```
create users/{uid}/diasProtegidos/{AYER}   { dia, createdAt }
update users/{uid}/comodines/saldo         { saldo-1, ultimoDiaProtegido: AYER }
```

Las Rules las atan en **ambas direcciones** con `getAfter()`: no se puede
crear el día protegido sin decrementar el saldo, ni decrementar el saldo sin
crear el día.

Se rompe a propósito la regla "sin transacciones" de la fase 2: las
transacciones no funcionan sin red y **fallan rápido**, que es justo lo que
queremos para un *entitlement*. Preferimos no dejar gastar un comodín sin
conexión antes que permitir una escritura local que el servidor revierta en
silencio. Los registros normales siguen siendo offline-first.

Doble protección del mismo día es **estructuralmente imposible**: el id del
documento *es* el día, y `create` solo aplica si no existe. El doble tap y los
dos dispositivos los resuelve la concurrencia optimista de la transacción.

### Orígenes futuros

`monthly_free` es el único origen implementado. Anuncios recompensados,
compras y Premium **no pueden pasar por el cliente**: las Rules solo admiten
dos transiciones del saldo (concesión mensual y consumo). Cuando lleguen,
entrarán por Admin SDK / Cloud Functions, que saltan las Rules, sumando a
`saldo` y a `concedidosTotal`. El modelo no cambia.

---

## 5. Periodicidades

Objetivos flexibles, **sin selección de días concretos**:

- todos los días (`daily`);
- X veces por semana (`weekly`);
- X veces al mes (`monthly`);
- X veces al año (`yearly`).

"Gimnasio 3 veces/semana" se cumple igual L-X-V que M-J-D: ambos son 3/3.

**La periodicidad NO interviene en la racha general.** Sirve para mostrar el
objetivo, el progreso del periodo, las estadísticas y el futuro sistema de
rangos. `Streak` y `GoalProgress` son conceptos separados, en entidades
distintas y sin nombres compartidos.

Semana = **lunes 00:00 → domingo 23:59:59** en la zona del perfil.

### Línea temporal y cambios diferidos

La periodicidad es una **línea temporal** (`periodicityTimeline`), una lista
ordenada de `{periodicity, since}` donde `since` puede ser futura. El objetivo
vigente un día D es la última entrada con `since <= D`.

No hay ningún campo derivado que pueda quedarse obsoleto y **no hace falta
ninguna escritura de "promoción"** cuando llega la fecha efectiva.

Un cambio **nunca altera el periodo en curso**. Entra en vigor al empezar el
**siguiente periodo natural completo del tipo nuevo** — así no hay periodos
parciales ni objetivos prorrateados:

| Cambio | Hecho un jueves | Entra en vigor |
|---|---|---|
| 3/semana → 12/mes | 10 sep | 1 de octubre |
| 12/mes → 3/semana | 10 sep | lunes siguiente |
| 3/semana → 5/semana | 10 sep | lunes siguiente |
| cualquiera → X/año | 10 sep | 1 de enero |
| cualquiera → diario | 10 sep | mañana |

El objetivo de un periodo es el que estaba vigente **cuando empezó** el
periodo. La UI avisa de la fecha efectiva antes de guardar
(`previewEffectiveDate` + `frequencyChangeDeferred`).

El historial completo queda conservado: es lo que permitirá calcular los
**rangos por hábito** en el futuro (no implementado en esta fase).

---

## 6. Día lógico, zona horaria y DST

El concepto de "día" se basa **siempre** en la zona horaria **IANA** guardada
en el perfil (`users/{uid}.timezone`), nunca en la del dispositivo ni en
abreviaturas como CET/EST.

- `LogicalDate`: un día de calendario sin hora y sin zona. Su aritmética usa
  UTC, que no tiene horario de verano, así que "sumar un día" siempre avanza
  exactamente un día aunque el día real haya durado 23 o 25 horas.
- `LogicalCalendar`: única pieza que conoce zonas horarias. Traduce instantes
  a `LogicalDate` y calcula límites de semana/mes/año.
- `Clock`: el tiempo actual es inyectable; el dominio no llama a
  `DateTime.now()`.

23:59 en Madrid pertenece al día actual; 00:00, al siguiente.

**Cambiar de zona horaria no reinterpreta el pasado.** Un registro guardado
como `2026-09-10` sigue siendo ese día lógico para siempre. La nueva zona solo
afecta a cuál es "hoy", a los registros nuevos y a los límites de periodo
futuros. Un viaje no reescribe la historia.

---

## 7. Registros retroactivos

**No se admiten.** Solo se puede marcar un hábito durante el día actual. Si no
quedó registrado durante el jueves, para Constanza el jueves no tiene ese
registro.

Marcar es `create`, desmarcar es `delete`; **no existe `update`** de un
registro. El histórico es inmutable por construcción.

Dónde se valida cada cosa:

| Capa | Garantía |
|---|---|
| **Dominio** (`ToggleHabitCompletionUsecase`) | "Solo hoy" **exacto**, resuelto con la zona IANA del perfil. |
| **Cliente / UI** | Solo el punto de hoy es interactivo. |
| **Security Rules** | Acota la fecha a `[request.time-36h, request.time+14h]`. **No** puede garantizar "solo hoy". |
| **Backend confiable** | Pendiente. Sería la única garantía estricta. |

---

## 8. Limitaciones de seguridad conocidas

> Esto **no** es seguridad absoluta. Está documentado a propósito y es deuda
> técnica a resolver **antes** de introducir funcionalidades con impacto
> económico o competitivo.

### 8.1. Margen de ~1 día en las fechas (registros y comodines)

> El margen **no es constante a lo largo del día**: depende de la hora UTC,
> porque la ventana se deriva de `request.time`. Lo que sí es determinista:
>
> | Registros | Comodines (día protegido) |
> |---|---|
> | HOY: siempre aceptado | AYER: siempre aceptado |
> | ±2 días: siempre rechazado | −3 días y +1 día: siempre rechazados |
> | AYER: aceptado solo si `horaUTC ≤ 12` | ANTEAYER: solo si `horaUTC ≤ 12` |
> | MAÑANA: aceptado solo si `horaUTC ≥ 10` | HOY: solo si `horaUTC ≥ 10` |
>
> Los tests de Rules calculan el resultado esperado a partir de la hora en
> lugar de fijar uno, para ser deterministas sin fingir una garantía.


Las Security Rules **no tienen base de datos de zonas horarias IANA** ni
pueden convertir zonas. Solo pueden acotar la fecha con `request.time`.

El día legítimo es `date(request.time + offset)` con `offset ∈ [-12h, +14h]`
(rango real de zonas IANA). Sin poder resolver la zona del perfil, la cota más
estrecha demostrable es:

- registros: `request.time - 36h  ≤  dia  ≤  request.time + 14h`
- días protegidos: `request.time - 60h  ≤  dia  ≤  request.time - 10h`

**Qué puede manipular un cliente:** con un SDK directo, crear un registro de
*ayer*, o proteger *anteayer* / *hoy*. Aproximadamente 1 día de margen. No
más: las fechas futuras lejanas y las claramente pasadas se rechazan.

**Por qué se acepta ahora:** es autoengaño, no una explotación económica —
infla su propia racha, que hoy no desbloquea nada. Los comodines siguen
limitados por saldo ≤ 3 y 1 concesión/mes, que **sí** están garantizados.

Los tests de Rules incluyen casos marcados `LIMITACIÓN:` que documentan
explícitamente este margen en lugar de fingir una garantía que no existe.

**Solución real:** Cloud Function que resuelva el día con la zona del perfil y
escriba con Admin SDK, cerrando `registros` y `diasProtegidos` a escritura del
cliente. Requiere plan **Blaze**. No activado.

### 8.2. El valor de la caché de rachas no está validado

Las Rules validan forma y tipos de `cache/rachas`, no el valor. Un cliente
manipulado puede escribir ahí una racha falsa.

Es aceptable **mientras la racha no desbloquee nada**, y queda como invariante
explícito del proyecto:

> Si algún día la racha concede recompensas, su cálculo **tiene** que moverse
> a servidor (`allow create, update: if false` en ese bloque).

La app nunca lee la caché para decidir: calcula la racha en vivo desde los
registros.

### 8.3. Rules no pueden comprobar que un día protegido estuviese vacío

Las Rules no pueden hacer *queries*, solo `get`/`exists` de rutas conocidas,
así que no pueden verificar "no existe ningún registro con `dia == Y`".

**No es un agujero:** proteger un día que sí tuvo actividad gasta un comodín y
no cambia la racha (ese día ya contaba). Es una comprobación de experiencia de
uso, y vive en `UseWildcardUsecase`.

### 8.4. Qué SÍ garantizan las Rules

- aislamiento por usuario;
- `saldo` siempre entre 0 y 3;
- la concesión mensual no se puede duplicar ni adelantar;
- el documento de saldo no se puede borrar (no se puede farmear recreándolo);
- no hay más vías de obtener saldo que la concesión mensual;
- consumo atómico: pagar ⟺ proteger;
- el mismo día no se puede proteger dos veces;
- los días protegidos son inmutables y no borrables;
- los registros son inmutables (sin `update`) y no se pueden crear en hábitos
  eliminados;
- nunca hay hard delete de hábitos;
- la caché está aislada y no es autoridad.

---

## 9. Esquema Firestore

```
users/{uid}
  email, displayName, timezone (IANA), locale, subscription,
  onboardingCompleted, createdAt, updatedAt, lastActiveAt

users/{uid}/ambitos/{id}
  nombre, emoji, colorValue, esPredefinido, orden, createdAt, updatedAt

users/{uid}/habitos/{id}
  nombre, emoji, colorValue, ambitoId,
  periodicidad:          { tipo, veces }          ← config inicial
  cambiosPeriodicidad:   [{ tipo, veces, desde }] ← `desde` puede ser futura
  recordatorioHora, orden, deletedAt, createdAt, updatedAt
  (legacy tolerados, se borran al editar: descansosPermitidos,
   tareaRecuperacion, recuperacionCooldownDias, historialPeriodicidad)

users/{uid}/registros/{habitoId}_{YYYY-MM-DD}      ← FUENTE DE VERDAD
  habitoId, dia, tipo: 'completed', tz, createdAt

users/{uid}/diasProtegidos/{YYYY-MM-DD}            ← el id ES el día
  dia, createdAt

users/{uid}/comodines/saldo                        ← entitlement
  saldo (0..3), ultimaConcesionYM, concedidosTotal,
  ultimoDiaProtegido, updatedAt

users/{uid}/cache/rachas                           ← PROYECCIÓN
  rachaActual, mejorRacha, ultimoDiaActividad,
  calculadoHasta, version, updatedAt
```

Índices compuestos: los dos de la fase 2 (`habitos(deletedAt, orden)` y
`registros(habitoId, dia)`). La fase 5 **no añade ninguno**: los rangos sobre
`dia` y sobre `diasProtegidos.dia` usan índices de campo único automáticos.

---

## 10. Migración

Estado real de `constanza-dev` comprobado el 11-09-2026: **1 usuario, 5
ámbitos predefinidos y nada más** — sin hábitos, sin registros y sin
`cache/rachas`. **No hay nada que migrar y no se ha ejecutado ninguna
migración.**

El código sí lleva compatibilidad, por si aparecen documentos antiguos:

1. **`periodicidad` como string suelto** (`'weekly'`) se lee como
   `{tipo: weekly, veces: 1}` — única lectura razonable del modelo anterior,
   donde la periodicidad no llevaba cantidad. Se normaliza al escribir.
2. **`historialPeriodicidad`** se lee y se reescribe como
   `cambiosPeriodicidad`.
3. **Campos legacy** (`descansosPermitidos`, `tareaRecuperacion`,
   `recuperacionCooldownDias`) siguen **tolerados** en `hasOnly` de las Rules
   y el cliente los borra con `FieldValue.delete()` en cada escritura de
   hábito: cada documento se limpia solo la primera vez que se edita.
   *Por qué tolerados y no prohibidos:* en Firestore un `update` se valida
   contra el documento resultante **completo**, así que quitarlos de `hasOnly`
   impediría editar hábitos creados antes de la fase 5 aunque no se tocasen
   esos campos.
4. **Registros legacy** con `tipo: 'recovery'` o `'plannedRest'` se conservan
   intactos y se siguen leyendo, pero **NO cuentan como actividad real**. Las
   Rules ya no admiten crear ninguno nuevo.

---

## 11. Pantallas conectadas

La fase 5 se usa desde la app, no solo desde tests:

- **Home**: "Nuevo hábito" abre el formulario; tocar un hábito lo edita;
  "Ver todos mis hábitos" cambia a la pestaña Hábitos.
- **Pestaña Hábitos** (`HabitsListPage`): todos los hábitos activos con su
  objetivo y su semana, más botón de alta.
- **Formulario** (`HabitFormPage`, rutas `/habit/new` y `/habit/:id`): alta y
  edición con nombre, emoji, color, ámbito, objetivo flexible y recordatorio;
  soft delete con confirmación.

El cambio de objetivo muestra **antes de guardar** cuándo entrará en vigor
(`frequencyChangeDeferred`), porque nunca altera el periodo en curso. Los
campos simples van por `UpdateHabitUsecase` y el objetivo por
`ChangeHabitPeriodicityUsecase`, que es quien calcula la fecha efectiva.

### Pendiente para una fase posterior

- Retirar los campos legacy de `hasOnly` cuando no quede ninguno.
- Cloud Functions para cerrar el margen de ~1 día (§8.1), obligatorio antes de
  anuncios/compras.
- Agregado por día si el volumen de registros lo justifica (hoy se descarta a
  propósito para no tener una segunda fuente de verdad).
