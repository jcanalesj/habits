# Documento Funcional — App de Hábitos (Flutter + Firebase)

> **Estado del documento**: cerrado en su primera versión completa — todas las decisiones estructurales han sido resueltas. Quedan señaladas como "asunción" únicamente aquellas de detalle que no condicionan el modelo de datos y pueden ajustarse sin coste de refactor.
> **Última actualización**: 26/08/2026

---

## 1. Introducción y Objetivos

La aplicación tiene como objetivo ayudar a los usuarios a **crear, mantener y visualizar el progreso de sus hábitos** (diarios, semanales, mensuales o anuales), motivándolos mediante un sistema de rachas y, en el futuro, mecánicas de gamificación (mascota virtual, monedas, tienda).

El objetivo principal es la **motivación y constancia**, no solo el registro pasivo de datos.

---

## 2. Alcance del Proyecto

### MVP (v1)
- Gestión de hábitos (creación, edición, eliminación) con distintas periodicidades.
- Registro/marcado de cumplimiento de hábitos.
- Sistema de rachas (general de la app + por ámbito/etiqueta).
- Ámbitos/etiquetas predefinidos y personalizados — un hábito pertenece a un único ámbito.
- Estadísticas y gráficas de progreso, incluyendo dashboard general.
- Notificaciones/recordatorios (hora fija configurable por hábito).
- Autenticación con email/contraseña.
- Modelo freemium (alcance exacto del muro de pago pendiente de cerrar, ver sección 11).

### Fuera de alcance en v1 (v2 / futuro)
- Mascota virtual.
- Sistema de monedas y tienda.
- Login social (Google / Apple) — arquitectura de auth preparada para ampliarlo sin reescritura.
- Funcionalidades sociales (compartir progreso, retos entre amigos). No se descarta; ver sección 3.
- Modo de notificación inteligente basado en histórico de uso.
- Recompensa publicitaria ("ver anuncio para conseguir un comodín extra").

---

## 3. Actores y Perfiles de Usuario

> ✔ **DECISIÓN CERRADA**
> Un único tipo de cuenta de usuario con dos estados de suscripción: free y premium (freemium). No hay perfiles funcionalmente distintos más allá de qué funciones desbloquea la suscripción.

Sobre el componente social: no se implementa en v1 y no está decidido si llegará en el futuro. Para no cerrar la puerta sin sobre-diseñar ahora, cada documento de datos (hábito, ámbito, racha, registro de cumplimiento) se modela aislado por usuario (scoped por `userId`), sin colecciones compartidas ni referencias cruzadas entre usuarios. Si en el futuro se añade una capa social, se implementaría como colecciones nuevas (ej. "retos", "amistades") sin necesidad de reestructurar lo ya construido.

---

## 4. Gestión de Hábitos

### 4.1 Creación de hábitos
Al crear un hábito, el usuario define:
- **Nombre** del hábito.
- **Ámbito/etiqueta** al que pertenece — uno y solo uno (predefinido o personalizado).
- **Periodicidad**: diario, semanal, mensual o anual.
- **Descansos permitidos** (si aplica): cupo flexible de días de descanso dentro del periodo (ej. "2 de cada 7 días"), consumibles por el usuario en el momento que decida. Una vez agotado el cupo, el resto de días sin cumplimiento cuentan como fallo.
- **Tarea de recuperación** (opcional): acción alternativa más ligera que sustituye el cumplimiento del hábito para no perder la racha del ámbito (ej. hábito = "ir al gym" → recuperación = "10 flexiones"). Límite de uso: una vez cada X días, configurable por hábito (por defecto, 7 días).

### 4.2 Registro de cumplimiento
- El usuario marca el hábito como completado cuando lo realiza.

> ✔ **DECISIÓN CERRADA**
> El "día lógico" cambia a las 00:00 en la zona horaria del dispositivo del usuario. Es el enfoque más simple de implementar y suficiente para v1; no se ofrece corte configurable por horarios nocturnos en esta versión.

- Si un hábito se crea a mitad de un periodo (ej. un hábito semanal creado en miércoles), la racha empieza a contar desde el primer periodo completo siguiente a la creación — no se exige cumplimiento retroactivo de días previos a la creación del hábito.

### 4.3 Edición y eliminación de hábitos

> ✔ **DECISIÓN CERRADA**
> Si el usuario cambia la periodicidad de un hábito con una racha activa, el historial de cumplimientos NO se borra ni se resetea a cero. La racha activa se recalcula a partir de la fecha del cambio, aplicando desde ese momento las reglas de la nueva periodicidad. Esto evita penalizar al usuario borrando su progreso, sin inflar artificialmente una racha que se ganó bajo reglas distintas.

> ✔ **DECISIÓN CERRADA**
> No existe un estado "pausado/archivado" para hábitos. Las únicas acciones disponibles son crear y eliminar. Para periodos de inactividad temporal (vacaciones, lesión, etc.) el usuario debe apoyarse en los descansos planificados configurados en el hábito.

- Eliminar un hábito elimina también su historial de cumplimiento y deja de contar en la racha del ámbito al que pertenecía (a definir en detalle si se conserva un registro histórico oculto para estadísticas agregadas o se borra por completo — pendiente de decisión de producto, no bloquea el desarrollo de v1).

### 4.4 Ámbitos/Etiquetas
- Existen ámbitos predefinidos por la app (ej. Dieta/Alimentación, Ejercicio/Forma física, Estudios...).
- El usuario puede crear ámbitos personalizados.
- Un hábito pertenece a un único ámbito (relación 1:N, confirmado en sección 3).
- Al eliminar un ámbito con hábitos asociados: pendiente de decidir si se bloquea la eliminación, se reasignan a un ámbito "General", o se eliminan en cascada. Recomendado: reasignar a un ámbito "General" por defecto para no destruir datos por accidente.

---

## 5. Sistema de Rachas

Existen dos niveles de racha independientes, con pools de comodines separados entre sí:

### 5.1 Racha general de la app
- Se mantiene registrando cualquier hábito, sin importar cuál, cada día (estilo Duolingo).
- Cuenta con 1 comodín gratuito por semana que perdona un día sin registro.
- No puede recuperarse mediante tareas de recuperación, solo mediante el comodín.

### 5.2 Racha por ámbito/etiqueta
- Cada ámbito (agrupando uno o varios hábitos) tiene su propia racha.
- **Regla de mantenimiento**: basta con completar uno cualquiera de los hábitos de ese ámbito en el periodo correspondiente para mantener la racha del ámbito (no hace falta completarlos todos).
- El ámbito (no cada hábito por separado) tiene un **único pool de comodines** compartido entre todos los hábitos que agrupa. Si el ámbito tiene hábitos con distinta periodicidad, la cadencia de renovación del comodín se rige por el hábito más exigente (ver sección 5.3).
- Los descansos planificados son distintos de los comodines: un descanso planificado no cuenta como fallo ni consume comodín, porque forma parte de la configuración del hábito.
- Las tareas de recuperación permiten salvar la racha del ámbito cuando el hábito original no se cumple, con un límite de uso de 1 vez cada X días (configurable, por defecto 7).

### 5.3 Comodín del ámbito

> ✔ **DECISIÓN CERRADA**
> Cada ámbito tiene un único comodín (no varios, no escalonado por periodicidad). Se renueva de forma fija semanalmente, independientemente de la periodicidad de los hábitos que agrupe el ámbito. Es una regla única y simple para todo el MVP.
>
> La mecánica de conseguir comodines extra (por ejemplo viendo un anuncio recompensado, o mediante compra) queda aparcada para v1.1/v2, junto con el resto de la capa de gamificación (mascota, monedas), ya que comparte la misma lógica de recompensas variables. No condiciona el modelo de datos: cuando se decida, será sumar +1 a un contador ya existente.

### 5.4 Resumen de conceptos a no confundir

| Concepto | Qué es | Consume | Rompe racha si no se usa a tiempo |
|---|---|---|---|
| Descanso planificado | Día "libre" ya previsto en la config. del hábito | Cupo de descansos del periodo | No |
| Comodín | Perdón ante un fallo no previsto | El comodín del ámbito disponible (1 por ámbito, renovación semanal fija) | No, si hay comodín disponible |
| Tarea de recuperación | Acción alternativa más ligera que sustituye el hábito | Uso limitado — 1 vez cada X días (config. por hábito, def. 7 días) | No, si aún no se ha usado |

---

## 6. Estadísticas y Visualización

- Vista tipo calendario de calor (heatmap), similar al de contribuciones de GitHub, mostrando por colores los días completados de cada hábito a lo largo del mes.
- Gráficas adaptadas según la periodicidad del hábito (vista diaria, semanal, mensual, anual).

> ✔ **DECISIÓN CERRADA**
> Sí habrá una pantalla de resumen general (dashboard) que incluye: heatmap agregado de toda la actividad, % de cumplimiento global, mejor racha histórica (general y por ámbito), y comparativa de cumplimiento entre ámbitos.

> ⚠ **ASUNCIÓN — ajustar si no aplica**
> Exportación de datos: se incluye exportación básica a CSV/PDF de las estadísticas como función de v1.1, no crítica para el lanzamiento del MVP. Ajustar si se necesita desde el día uno (ej. por requisitos de RGPD de portabilidad de datos, ver sección 10).

### 6.1 Resumen anual

Pantalla adicional, tipo "año en repaso", que muestra cada hábito con su cuadrícula anual de cumplimiento (una casilla por día, con más o menos intensidad de color según se haya cumplido) y su % de cumplimiento anual junto al nombre. Es una vista de solo lectura pensada para verse puntualmente (fin de año, o bajo demanda desde el dashboard), no un heatmap de uso diario.

> ✔ **DECISIÓN CERRADA**
> Se incluye en v1 dentro del dashboard general, como una sección desplegable o pantalla accesible desde ahí, reutilizando los mismos datos de "registros" ya definidos en el modelo de Firestore (sección 9.1) — no requiere una colección nueva, solo una agregación por año.

---

## 7. Notificaciones

Confirmado que son una funcionalidad clave para evitar la pérdida de rachas.

> ✔ **DECISIÓN CERRADA**
> Para v1: hora fija configurable por hábito (el usuario elige a qué hora quiere el recordatorio). El modo de recordatorio inteligente basado en histórico de cumplimiento queda como mejora activable en una versión futura.

- Se incluyen avisos de urgencia cuando queda poco tiempo para perder una racha (ej. "te quedan 2 horas y no has registrado X"), y avisos cuando el usuario está a punto de agotar el cupo de descansos o comodines disponibles — ambos considerados parte del objetivo central de "evitar pérdida de rachas", por lo que se incluyen en v1.

---

## 8. Autenticación y Cuentas

- v1: registro/login con email y contraseña (Firebase Authentication).
- Futuro: ampliación a login social (Google, Apple), dejando la arquitectura preparada desde el inicio para facilitar esta incorporación.

> ⚠ **ASUNCIÓN — ajustar si no aplica**
> Recuperación de contraseña vía email (flujo estándar de Firebase Auth) y verificación de email al registro se incluyen por defecto en v1 al no haberse mencionado como excluidas.

---

## 9. Arquitectura Técnica

- Frontend: Flutter (iOS + Android).
- Backend: Firebase (Authentication, Firestore como base de datos).

### 9.1 Modelo de datos en Firestore (propuesta base)
- `users/{userId}` — perfil, subscriptionStatus (free | trial | premium), trialEndsAt, timezone.
- `users/{userId}/ambitos/{ambitoId}` — nombre, tipo (predefinido/personalizado), racha activa, mejor racha histórica, pool de comodines.
- `users/{userId}/habitos/{habitoId}` — nombre, ambitoId (referencia única), periodicidad, descansos configurados, tarea de recuperación y su cooldown, historial de cambios de periodicidad, color (asignado automáticamente de una paleta al crear el hábito, editable por el usuario — se usa en heatmap, dashboard y resumen anual).
- `users/{userId}/registros/{registroId}` — fecha (día lógico), habitoId, tipo (cumplido normal / vía tarea de recuperación / vía descanso planificado).
- `users/{userId}/rachaGeneral` — contador, comodín semanal disponible, fecha de último uso.

Este esquema mantiene todo scoped bajo el usuario (sin colecciones globales compartidas), coherente con la decisión de la sección 3 de no cerrar la puerta a una capa social futura sin necesitar reestructurar lo existente.

### 9.2 Funcionamiento offline

> ⚠ **ASUNCIÓN — ajustar si no aplica**
> Se usa la caché local nativa de Firestore (offline persistence) para lectura y escritura sin conexión, con sincronización automática al recuperar red. Estrategia de resolución de conflictos: "último escrito gana" (last-write-wins) por campo, suficiente para v1 dado que es una app de uso mayoritariamente single-device. Revisar si se detecta uso multi-dispositivo simultáneo real.

### 9.3 Zonas horarias

El "día lógico" de cada usuario se calcula según la zona horaria local del dispositivo en el momento del registro (ver decisión en sección 4.2). El campo `timezone` del perfil de usuario se actualiza automáticamente si la app detecta un cambio de zona horaria del dispositivo, para mantener consistencia en el cálculo de rachas si el usuario viaja.

---

## 10. Requisitos No Funcionales

- Rendimiento offline / mala conexión: cubierto por caché local de Firestore (ver 9.2).

> ⚠ **ASUNCIÓN — ajustar si no aplica**
> Seguridad y privacidad: reglas de seguridad de Firestore restringen todo acceso a `request.auth.uid == userId` — un usuario nunca puede leer ni escribir datos de otro. Cumplimiento RGPD: se incluye función de exportación de datos personales y borrado completo de cuenta ("derecho al olvido") accesible desde ajustes, dado que la app opera con usuarios en España/UE.

> ⚠ **ASUNCIÓN — ajustar si no aplica**
> Compatibilidad de versiones mínimas: Android 8.0 (API 26) e iOS 14, en línea con los requisitos mínimos habituales de Firebase SDK y Flutter estable a fecha de este documento. Ajustar según analítica de dispositivos objetivo una vez haya datos reales de usuarios.

- Escalabilidad: sin techo definido explícitamente; el modelo de datos scoped por usuario en Firestore escala de forma nativa sin rediseño para el volumen esperado de una app de hábitos personal.

> ⚠ **ASUNCIÓN — ajustar si no aplica**
> Accesibilidad: soporte de tamaños de fuente dinámicos del sistema y contraste AA como mínimo, siguiendo las guías estándar de accesibilidad de Flutter (Material/Cupertino). Sin requisitos adicionales especificados.

---

## 11. Modelo de Negocio

> ✔ **DECISIÓN CERRADA**
> Freemium. El reparto exacto entre funciones gratuitas y de pago está pendiente de decidir — se está valorando entre (a) limitar el número de hábitos/ámbitos creables en la versión gratuita, o (b) ofrecer 7 días de prueba completa y pasar a pago después. Ambas opciones son compatibles con el modelo de datos propuesto en la sección 9.1 (campo subscriptionStatus + trialEndsAt), por lo que esta decisión no bloquea el desarrollo del MVP y puede cerrarse más adelante sin impacto en la arquitectura.

Función adicional a valorar (ver 5.3): comodín extra mediante anuncio recompensado, compatible con cualquiera de las dos vías freemium anteriores.

---

## 12. Criterios de Aceptación

**Creación de hábito**
- Dado que el usuario completa nombre, ámbito y periodicidad, al guardar el hábito aparece en la lista de hábitos activos del ámbito correspondiente.
- Si no se selecciona un ámbito existente, se ofrece crear uno personalizado sin salir del flujo de creación.

**Registro de cumplimiento**
- Al marcar un hábito como completado antes del corte de las 00:00 (hora local), el día queda registrado como cumplido y la racha correspondiente se incrementa.
- Si el usuario no registra el hábito antes del corte y no quedan descansos ni comodines disponibles, la racha del ámbito se rompe y se refleja visualmente en el heatmap.

**Cálculo de racha**
- La racha de ámbito se mantiene si al menos un hábito de ese ámbito se completa en el periodo, aunque el resto de hábitos del ámbito no se cumplan.
- Al agotarse el comodín semanal del ámbito (ver sección 5.3), el siguiente fallo rompe la racha.

**Edición de periodicidad**
- Al cambiar la periodicidad de un hábito con racha activa, el historial de cumplimiento previo permanece visible en las estadísticas y la racha activa se recalcula desde la fecha del cambio según las nuevas reglas (ver 4.3).

🔲 *Pendiente: completar criterios de aceptación para notificaciones, eliminación de hábito/ámbito, límites freemium, resumen anual y funcionamiento offline.*

---

## 13. Registro de Decisiones y Riesgos Pendientes

- ✔ Cerrado — corte horario del día lógico: 00:00, zona horaria del dispositivo.
- ✔ Cerrado — comodín único por ámbito (no por hábito), renovación fija semanal, independiente de la periodicidad de sus hábitos (ver sección 5.3). Mecánica de comodín extra vía anuncio/pago aparcada para v1.1/v2.
- ✔ Cerrado — frecuencia de tarea de recuperación: cada X días fijos, configurable por hábito.
- ✔ Cerrado — un hábito pertenece a un único ámbito.
- ✔ Cerrado — alcance de estadísticas: heatmap + dashboard general con métricas clave.
- ✔ Cerrado — notificaciones: hora fija en v1, modo inteligente en futuro.
- ✔ Cerrado — modelo de negocio: freemium (reparto free/premium exacto, pendiente).
- ✔ Cerrado — modelo de datos Firestore y estrategia offline (ver sección 9).
- ✔ Cerrado — componente social: no en v1, sin decidir a futuro; modelo de datos aislado por usuario para no bloquear ninguna opción.
- 🔲 Pendiente — reparto exacto de funciones freemium (límite de hábitos vs. prueba de 7 días).
- 🔲 Pendiente — comportamiento exacto al eliminar un ámbito con hábitos asociados (bloquear / reasignar a "General" / cascada).
- 🔲 Pendiente — si se conserva un histórico oculto al eliminar un hábito, o se borra por completo.
- 🔲 Pendiente — validar versiones mínimas de iOS/Android con datos reales de usuarios objetivo.
- 🔲 Pendiente — confirmar si el estado "sin pausa/archivado" (sección 4.3) es definitivo, dado el riesgo de UX en bajas largas (lesión, vacaciones) señalado en revisión.

