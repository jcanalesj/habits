const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const {
  doc, setDoc, getDoc, updateDoc, deleteDoc, serverTimestamp, Timestamp,
  collection, getDocs, query, where, orderBy, writeBatch,
} = require('firebase/firestore');

const RULES = fs.readFileSync(path.join(__dirname, '..', '..', 'firestore.rules'), 'utf8');
const results = [];
async function check(name, expectOk, fn) {
  try {
    if (expectOk) await assertSucceeds(fn()); else await assertFails(fn());
    results.push({ name, ok: true });
  } catch (e) {
    results.push({ name, ok: false, err: String(e.message || e).split('\n')[0] });
  }
}

const ts = () => serverTimestamp();
const user = (over = {}) => ({
  email: 'alice@example.com', displayName: 'Alice', timezone: 'Europe/Madrid',
  locale: 'es', subscription: { status: 'free' }, createdAt: ts(), updatedAt: ts(), ...over,
});
const ambito = (over = {}) => ({
  nombre: 'Salud', emoji: '💜', colorValue: 0xFF8B5CF6, esPredefinido: true, orden: 0,
  createdAt: ts(), updatedAt: ts(), ...over,
});
const habito = (over = {}) => ({
  nombre: 'Beber agua', emoji: '💧', iconId: 'water_drop', colorValue: 0xFF3B82F6, ambitoId: 'salud',
  periodicidad: { tipo: 'daily', veces: 1 }, cambiosPeriodicidad: [],
  recordatorioHora: '18:00',
  trackingType: 'single', targetCount: 1, unit: null,
  displayGoal: null, progressIconId: 'check',
  orden: 0, deletedAt: null, createdAt: ts(), updatedAt: ts(), ...over,
});

// Días lógicos relativos a AHORA: la ventana que aplican las reglas se
// deriva de request.time, así que las fechas fijas caducarían.
const dayKey = (offsetDays) => {
  const d = new Date(Date.now() + offsetDays * 86400000);
  return d.toISOString().slice(0, 10);
};
const HOY = dayKey(0);
const AYER = dayKey(-1);
const ANTEAYER = dayKey(-2);

// Horas transcurridas desde la medianoche UTC. Las ventanas de las Rules se
// derivan de request.time, así que si un día concreto cae dentro o fuera
// DEPENDE DE LA HORA. Calcularlo aquí hace el test determinista sin fingir
// una garantía que no existe.
const horasUtc = () => {
  const n = new Date();
  return n.getUTCHours() + n.getUTCMinutes() / 60;
};
// Registros: request.time-36h <= dia <= request.time+14h
const ayerEntraEnVentanaDeRegistro = () => horasUtc() <= 12;
// Comodines: request.time-60h <= dia <= request.time-10h
const hoyEntraEnVentanaDeRescate = () => horasUtc() >= 10;
const anteayerEntraEnVentanaDeRescate = () => horasUtc() <= 12;

const registro = (over = {}) => ({
  habitoId: 'h1', dia: HOY, tipo: 'completed', tz: 'Europe/Madrid', createdAt: ts(), ...over,
});
const cache = (over = {}) => ({
  rachaActual: 3, mejorRacha: 10, ultimoDiaActividad: HOY,
  calculadoHasta: HOY, version: 2, updatedAt: ts(), ...over,
});

// Mes actual del servidor como entero monótono (año*12 + mes), igual que
// mesActual() en las reglas.
const mesActual = () => {
  const now = new Date();
  return now.getUTCFullYear() * 12 + (now.getUTCMonth() + 1);
};
const saldo = (over = {}) => ({
  saldo: 1, ultimaConcesionYM: mesActual(), concedidosTotal: 1,
  ultimoDiaProtegido: null, updatedAt: ts(), ...over,
});

(async () => {
  const env = await initializeTestEnvironment({
    projectId: 'constanza-dev',
    firestore: { rules: RULES },
  });
  await env.clearFirestore();

  const alice = env.authenticatedContext('alice', { email: 'alice@example.com', email_verified: true }).firestore();
  const aliceUnverified = env.authenticatedContext('alice', { email: 'alice@example.com', email_verified: false }).firestore();
  const bob = env.authenticatedContext('bob', { email: 'bob@example.com', email_verified: true }).firestore();
  const anon = env.unauthenticatedContext().firestore();
  const U = (db, ...p) => doc(db, 'users', 'alice', ...p);

  // ---------------- users/{uid}
  await check('anon no lee perfil', false, () => getDoc(U(anon)));
  // Verificación de email DESACTIVADA (ver lib/env.dart): basta con estar
  // autenticado. Si se reactiva, estas dos aserciones se invierten.
  // Se usa una cuenta aparte (carol) para no dejar creado el perfil de alice.
  const carol = env.authenticatedContext('carol', { email: 'carol@example.com', email_verified: false }).firestore();
  await check('sin verificar sí crea su perfil (verificación desactivada)', true,
    () => setDoc(doc(carol, 'users', 'carol'), user({ email: 'carol@example.com' })));
  await check('sin verificar sí lee su perfil', true, () => getDoc(doc(carol, 'users', 'carol')));
  await check('sin verificar sigue sin tocar datos de otro', false, () => getDoc(U(carol)));
  await check('perfil: email distinto del token falla', false, () => setDoc(U(alice), user({ email: 'otro@example.com' })));
  await check('perfil: subscription premium en create falla', false, () => setDoc(U(alice), user({ subscription: { status: 'premium' } })));
  await check('perfil: campo derivado rachaGeneral falla', false, () => setDoc(U(alice), user({ rachaGeneral: { contador: 99 } })));
  await check('perfil: createdAt de cliente falla', false, () => setDoc(U(alice), user({ createdAt: Timestamp.fromDate(new Date(2020, 0, 1)) })));
  await check('perfil válido se crea', true, () => setDoc(U(alice), user()));
  await check('bob no lee perfil de alice', false, () => getDoc(U(bob)));
  await check('alice lee su perfil', true, () => getDoc(U(alice)));
  await check('perfil: update subscription falla', false, () => updateDoc(U(alice), { subscription: { status: 'premium' }, updatedAt: ts() }));
  await check('perfil: update email falla', false, () => updateDoc(U(alice), { email: 'x@example.com', updatedAt: ts() }));
  await check('perfil: update sin updatedAt falla', false, () => updateDoc(U(alice), { timezone: 'Europe/Lisbon' }));
  await check('perfil: update timezone válido', true, () => updateDoc(U(alice), { timezone: 'Europe/Lisbon', updatedAt: ts() }));
  await check('perfil: modo de zona automático válido', true, () => updateDoc(U(alice), { timezoneAutomatic: true, updatedAt: ts() }));
  await check('perfil: modo de zona no booleano falla', false, () => updateDoc(U(alice), { timezoneAutomatic: 'sí', updatedAt: ts() }));
  await check('perfil: update avatar válido', true, () => updateDoc(U(alice), { avatarId: 'friendly', updatedAt: ts() }));
  await check('perfil: avatar desconocido falla', false, () => updateDoc(U(alice), { avatarId: 'avatar-inventado', updatedAt: ts() }));
  await check('perfil: lastActiveAt serverTimestamp', true, () => updateDoc(U(alice), { lastActiveAt: ts(), updatedAt: ts() }));
  await check('perfil: update posterior sin tocar lastActiveAt', true, () => updateDoc(U(alice), { locale: 'en', updatedAt: ts() }));
  // Escrituras EXACTAS que hace la app, para que un cambio de esquema no
  // vuelva a llegar a producción como permission-denied.
  //
  // updateTimezoneSettings(): zona y modo automático en la misma escritura.
  await check('perfil: cambiar zona y modo a la vez (pantalla de zona horaria)', true,
    () => updateDoc(U(alice), {
      timezone: 'America/New_York', timezoneAutomatic: false, updatedAt: ts(),
    }));
  // create(): el alta siembra avatar por defecto y zona automática.
  const frank = env.authenticatedContext('frank', { email: 'frank@example.com', email_verified: true }).firestore();
  await check('perfil: alta con avatar y zona automática', true,
    () => setDoc(doc(frank, 'users', 'frank'), user({
      email: 'frank@example.com', avatarId: 'traveler', timezoneAutomatic: true,
    })));

  await check('perfil: delete falla', false, () => deleteDoc(U(alice)));
  await check('listar users falla', false, () => getDocs(collection(alice, 'users')));

  // ---------------- ambitos
  await check('ambito general predefinido se crea', true, () => setDoc(U(alice, 'ambitos', 'general'), ambito({ nombre: 'General' })));
  await check('ambito salud predefinido se crea', true, () => setDoc(U(alice, 'ambitos', 'salud'), ambito()));
  await check('ambito general con esPredefinido=false falla', false, () => setDoc(U(alice, 'ambitos', 'mente'), ambito({ esPredefinido: false })));
  await check('ambito custom con esPredefinido=true falla', false, () => setDoc(U(alice, 'ambitos', 'custom1'), ambito({ esPredefinido: true })));
  await check('ambito custom con rachaActual falla', false, () => setDoc(U(alice, 'ambitos', 'custom1'), ambito({ esPredefinido: false, rachaActual: 5 })));
  await check('ambito custom válido se crea', true, () => setDoc(U(alice, 'ambitos', 'custom1'), ambito({ esPredefinido: false, nombre: 'Música' })));
  await check('ambito: cambiar esPredefinido falla', false, () => updateDoc(U(alice, 'ambitos', 'custom1'), { esPredefinido: true, updatedAt: ts() }));
  await check('ambito: renombrar válido', true, () => updateDoc(U(alice, 'ambitos', 'custom1'), { nombre: 'Guitarra', updatedAt: ts() }));
  await check('ambito general no se borra', false, () => deleteDoc(U(alice, 'ambitos', 'general')));
  await check('bob no borra ambito de alice', false, () => deleteDoc(doc(bob, 'users', 'alice', 'ambitos', 'custom1')));
  await check('ambito custom se borra', true, () => deleteDoc(U(alice, 'ambitos', 'custom1')));

  // ---------------- habitos
  await check('habito con ambito inexistente falla', false, () => setDoc(U(alice, 'habitos', 'h1'), habito({ ambitoId: 'nope' })));
  await check('habito sin deletedAt falla', false, () => { const h = habito(); delete h.deletedAt; return setDoc(U(alice, 'habitos', 'h1'), h); });
  await check('habito con rachaActual falla', false, () => setDoc(U(alice, 'habitos', 'h1'), habito({ rachaActual: 3 })));
  await check('habito periodicidad inválida falla', false, () => setDoc(U(alice, 'habitos', 'h1'), habito({ periodicidad: { tipo: 'hourly', veces: 1 } })));
  await check('habito hora 25:00 falla', false, () => setDoc(U(alice, 'habitos', 'h1'), habito({ recordatorioHora: '25:00' })));
  await check('habito creado ya borrado falla', false, () => setDoc(U(alice, 'habitos', 'h1'), habito({ deletedAt: ts() })));
  await check('habito válido se crea', true, () => setDoc(U(alice, 'habitos', 'h1'), habito()));
  await check('habito legacy sin iconId se crea', true, () => { const h = habito({ nombre: 'Legacy' }); delete h.iconId; return setDoc(U(alice, 'habitos', 'legacy'), h); });
  await check('habito legacy de prueba se archiva', true, () => updateDoc(U(alice, 'habitos', 'legacy'), { deletedAt: ts(), updatedAt: ts() }));
  await check('habit iconId demasiado largo falla', false, () => setDoc(U(alice, 'habitos', 'bad-icon'), habito({ iconId: 'x'.repeat(33) })));
  await check('habito con repeticiones se crea', true, () => setDoc(U(alice, 'habitos', 'h8'), habito({
    nombre: 'Beber agua', trackingType: 'repetitions', targetCount: 6,
    unit: 'vasos', displayGoal: '2 L', progressIconId: 'water_glass',
  })));
  await check('habito con objetivo de repeticiones inválido falla', false, () => setDoc(U(alice, 'habitos', 'h9'), habito({ trackingType: 'repetitions', targetCount: 0 })));
  await check('habito h2 se crea', true, () => setDoc(U(alice, 'habitos', 'h2'), habito({ nombre: 'Entrenar', recordatorioHora: null })));
  await check('habito con periodicidad flexible 3/semana se crea', true, () => setDoc(U(alice, 'habitos', 'h4'), habito({ nombre: 'Gimnasio', periodicidad: { tipo: 'weekly', veces: 3 } })));
  await check('habito con periodicidad string suelto (forma antigua) falla', false, () => setDoc(U(alice, 'habitos', 'h5'), habito({ periodicidad: 'weekly' })));
  await check('habito con veces 0 falla', false, () => setDoc(U(alice, 'habitos', 'h5'), habito({ periodicidad: { tipo: 'weekly', veces: 0 } })));
  await check('habito con tipo de periodo inválido falla', false, () => setDoc(U(alice, 'habitos', 'h5'), habito({ periodicidad: { tipo: 'hourly', veces: 1 } })));
  await check('habito con cambiosPeriodicidad válido se crea', true, () => setDoc(U(alice, 'habitos', 'h5'), habito({ nombre: 'Leer 2', cambiosPeriodicidad: [{ tipo: 'monthly', veces: 12, desde: '2026-10-01' }] })));
  // Los campos legacy siguen TOLERADOS para no romper la edición de hábitos
  // creados antes de la fase 5 (ver migración perezosa en firestore.rules).
  await check('habito legacy con descansosPermitidos sigue siendo editable', true, () => setDoc(U(alice, 'habitos', 'h6'), habito({ nombre: 'Legacy', descansosPermitidos: 2, tareaRecuperacion: 'x', recuperacionCooldownDias: 7 })));
  await check('habito h3 se crea', true, () => setDoc(U(alice, 'habitos', 'h3'), habito({ nombre: 'Leer' })));
  await check('habito: reasignar a ambito inexistente falla', false, () => updateDoc(U(alice, 'habitos', 'h1'), { ambitoId: 'nope', updatedAt: ts() }));
  await check('habito: reasignar a general válido', true, () => updateDoc(U(alice, 'habitos', 'h1'), { ambitoId: 'general', updatedAt: ts() }));
  await check('habito: cambiar createdAt falla', false, () => updateDoc(U(alice, 'habitos', 'h1'), { createdAt: ts(), updatedAt: ts() }));
  await check('habito: hard delete falla', false, () => deleteDoc(U(alice, 'habitos', 'h1')));
  await check('habito: soft delete con fecha arbitraria falla', false, () => updateDoc(U(alice, 'habitos', 'h3'), { deletedAt: Timestamp.fromDate(new Date(2020, 0, 1)), updatedAt: ts() }));

  // ---------------- registros (antes de borrar h3)
  await check('registro de hoy se crea', true, () => setDoc(U(alice, 'registros', `h1_${HOY}`), registro()));
  await check('registro parcial 4/6 se crea', true, () => setDoc(U(alice, 'registros', `h8_${HOY}`), registro({ habitoId: 'h8', completedCount: 4, targetCount: 6 })));
  await check('registro parcial puede avanzar a 5/6', true, () => updateDoc(U(alice, 'registros', `h8_${HOY}`), { completedCount: 5 }));
  await check('registro parcial no puede cambiar su objetivo histórico', false, () => updateDoc(U(alice, 'registros', `h8_${HOY}`), { targetCount: 8 }));
  await check('registro no permite superar el objetivo', false, () => updateDoc(U(alice, 'registros', `h8_${HOY}`), { completedCount: 7 }));
  await check('registro en h3 se crea', true, () => setDoc(U(alice, 'registros', `h3_${HOY}`), registro({ habitoId: 'h3', dia: HOY })));
  await check('registro en h2 se crea', true, () => setDoc(U(alice, 'registros', `h2_${HOY}`), registro({ habitoId: 'h2' })));
  await check('registro id no coincide falla', false, () => setDoc(U(alice, 'registros', `h1_${AYER}`), registro()));
  await check('registro fecha futura lejana falla', false, () => setDoc(U(alice, 'registros', 'h1_2030-01-01'), registro({ dia: '2030-01-01' })));
  await check('registro +5 días falla', false, () => setDoc(U(alice, 'registros', `h1_${dayKey(5)}`), registro({ dia: dayKey(5) })));
  await check('registro -5 días falla', false, () => setDoc(U(alice, 'registros', `h1_${dayKey(-5)}`), registro({ dia: dayKey(-5) })));
  await check('registro fecha antigua arbitraria falla', false, () => setDoc(U(alice, 'registros', 'h1_2020-01-01'), registro({ dia: '2020-01-01' })));
  await check('registro dia inválido 2026-13-01 falla', false, () => setDoc(U(alice, 'registros', 'h1_2026-13-01'), registro({ dia: '2026-13-01' })));
  await check('registro dia inexistente 2026-02-30 falla', false, () => setDoc(U(alice, 'registros', 'h1_2026-02-30'), registro({ dia: '2026-02-30' })));
  await check('registro habito inexistente falla', false, () => setDoc(U(alice, 'registros', `zz_${HOY}`), registro({ habitoId: 'zz' })));
  await check('registro tipo inválido falla', false, () => setDoc(U(alice, 'registros', `h2_${HOY}`), registro({ habitoId: 'h2', tipo: 'skipped' })));
  // recovery y plannedRest se retiran del modelo (fase 5): no se pueden crear.
  await check('registro tipo recovery ya no se admite', false, () => setDoc(U(alice, 'registros', `h2_${HOY}`), registro({ habitoId: 'h2', tipo: 'recovery' })));
  await check('registro tipo plannedRest ya no se admite', false, () => setDoc(U(alice, 'registros', `h2_${HOY}`), registro({ habitoId: 'h2', tipo: 'plannedRest' })));
  await check('registro con campo extra falla', false, () => setDoc(U(alice, 'registros', `h2_${HOY}`), registro({ habitoId: 'h2', racha: 4 })));
  await check('registro con updatedAt falla', false, () => setDoc(U(alice, 'registros', `h2_${HOY}`), registro({ habitoId: 'h2', updatedAt: ts() })));
  // Un registro es inmutable: marcar es create, desmarcar es delete.
  await check('registro: update prohibido', false, () => updateDoc(U(alice, 'registros', `h1_${HOY}`), { tipo: 'completed' }));
  await check('registro: cambiar dia falla', false, () => updateDoc(U(alice, 'registros', `h1_${HOY}`), { dia: ANTEAYER }));
  await check('registro: desmarcar (delete) válido', true, () => deleteDoc(U(alice, 'registros', `h2_${HOY}`)));
  await check('bob no lee registros de alice', false, () => getDoc(doc(bob, 'users', 'alice', 'registros', `h1_${HOY}`)));

  // soft delete h3 y comprobar inmutabilidad de su histórico
  await check('habito h3 soft delete válido', true, () => updateDoc(U(alice, 'habitos', 'h3'), { deletedAt: ts(), updatedAt: ts() }));
  // h7 se crea y se borra sin registros, para que este rechazo se deba SOLO
  // a que el hábito está eliminado (la fecha HOY siempre entra en ventana).
  await check('habito h7 se crea', true, () => setDoc(U(alice, 'habitos', 'h7'), habito({ nombre: 'Temporal' })));
  await check('habito h7 soft delete', true, () => updateDoc(U(alice, 'habitos', 'h7'), { deletedAt: ts(), updatedAt: ts() }));
  await check('registro nuevo en habito borrado falla', false, () => setDoc(U(alice, 'registros', `h7_${HOY}`), registro({ habitoId: 'h7', dia: HOY })));
  await check('registro histórico de habito borrado no se borra', false, () => deleteDoc(U(alice, 'registros', `h3_${HOY}`)));
  await check('registro histórico de habito borrado sigue legible', true, () => getDoc(U(alice, 'registros', `h3_${HOY}`)));
  await check('habito borrado: restaurar (deletedAt null) válido', true, () => updateDoc(U(alice, 'habitos', 'h3'), { deletedAt: null, updatedAt: ts() }));
  await check('habito h3 soft delete de nuevo', true, () => updateDoc(U(alice, 'habitos', 'h3'), { deletedAt: ts(), updatedAt: ts() }));

  // ---------------- consultas reales de la app (validan reglas + índices en emulador)
  await check('query habitos activos ordenados', true, async () => {
    const snap = await getDocs(query(collection(alice, 'users', 'alice', 'habitos'), where('deletedAt', '==', null), orderBy('orden')));
    if (snap.size !== 6) throw new Error('esperaba 6 activos, hay ' + snap.size);
  });
  await check('query registros por habito y rango de dias', true, async () => {
    const snap = await getDocs(query(collection(alice, 'users', 'alice', 'registros'),
      where('habitoId', '==', 'h1'), where('dia', '>=', dayKey(-7)), where('dia', '<=', HOY), orderBy('dia')));
    if (snap.size !== 1) throw new Error('esperaba 1 registro, hay ' + snap.size);
  });
  await check('query histórico completo de registros (motor de rachas)', true, async () => {
    const snap = await getDocs(query(collection(alice, 'users', 'alice', 'registros'), orderBy('dia')));
    if (snap.size !== 3) throw new Error('esperaba 3 registros (h1, h3, h8), hay ' + snap.size);
  });

  // ---------------- ventana de fechas: qué es determinista y qué no
  //
  // Cotas de las Rules para registros: [request.time-36h, request.time+14h].
  // De ahí salen tres hechos SIEMPRE ciertos y uno que depende de la hora.
  await check('ventana: HOY siempre se acepta', true,
    () => setDoc(U(alice, 'registros', `h2_${HOY}`), registro({ habitoId: 'h2' })));
  await check('ventana: hace 2 días SIEMPRE se rechaza', false,
    () => setDoc(U(alice, 'registros', `h2_${dayKey(-2)}`), registro({ habitoId: 'h2', dia: dayKey(-2) })));
  await check('ventana: dentro de 2 días SIEMPRE se rechaza', false,
    () => setDoc(U(alice, 'registros', `h2_${dayKey(2)}`), registro({ habitoId: 'h2', dia: dayKey(2) })));
  // LIMITACIÓN CONOCIDA: AYER cae dentro de la ventana solo si aún no han
  // pasado 12 horas UTC. Las Rules no pueden resolver la zona IANA del
  // perfil, así que no hay forma de exigir "solo hoy" desde aquí: eso lo
  // aplican el dominio y el cliente. La garantía estricta exige trusted
  // backend. El test calcula el resultado esperado en vez de fingir uno.
  await check(
    `LIMITACIÓN: ayer ${ayerEntraEnVentanaDeRegistro() ? 'entra' : 'no entra'} en la ventana ahora mismo (margen ~1 día)`,
    ayerEntraEnVentanaDeRegistro(),
    () => setDoc(U(alice, 'registros', `h2_${AYER}`), registro({ habitoId: 'h2', dia: AYER })));
  // Limpieza para no alterar el conteo del histórico en asserts posteriores.
  await check('limpieza: borrar registros de h2', true, async () => {
    const snap = await getDocs(query(collection(alice, 'users', 'alice', 'registros'), where('habitoId', '==', 'h2')));
    for (const d of snap.docs) await deleteDoc(d.ref);
  });
  await check('bob no lista registros de alice', false, () => getDocs(collection(bob, 'users', 'alice', 'registros')));

  // ---------------- comodines: saldo
  const S = (db) => doc(db, 'users', 'alice', 'comodines', 'saldo');
  const DP = (db, dia) => doc(db, 'users', 'alice', 'diasProtegidos', dia);

  await check('saldo: crear con 2 comodines falla', false, () => setDoc(S(alice), saldo({ saldo: 2, concedidosTotal: 2 })));
  await check('saldo: crear con mes distinto del actual falla', false, () => setDoc(S(alice), saldo({ ultimaConcesionYM: mesActual() - 1 })));
  await check('saldo: crear con campo extra falla', false, () => setDoc(S(alice), saldo({ hack: 1 })));
  await check('saldo: crear con updatedAt de cliente falla', false, () => setDoc(S(alice), saldo({ updatedAt: Timestamp.now() })));
  await check('saldo: id distinto de "saldo" falla', false, () => setDoc(doc(alice, 'users', 'alice', 'comodines', 'otro'), saldo()));
  await check('saldo inicial válido se crea (1 comodín)', true, () => setDoc(S(alice), saldo()));
  await check('bob no lee el saldo de alice', false, () => getDoc(S(bob)));
  await check('bob no escribe el saldo de alice', false, () => updateDoc(S(bob), { saldo: 3, updatedAt: ts() }));

  // Concesión mensual: solo hacia el mes actual, monótona y con tope 3.
  await check('saldo: subir sin avanzar de mes falla', false,
    () => updateDoc(S(alice), { saldo: 2, concedidosTotal: 2, updatedAt: ts() }));
  await check('saldo: subir a 3 de golpe sin meses transcurridos falla', false,
    () => updateDoc(S(alice), { saldo: 3, ultimaConcesionYM: mesActual(), concedidosTotal: 3, updatedAt: ts() }));
  await check('saldo: conceder con mes futuro falla', false,
    () => updateDoc(S(alice), { saldo: 2, ultimaConcesionYM: mesActual() + 1, concedidosTotal: 2, updatedAt: ts() }));
  await check('saldo: saldo negativo falla', false,
    () => updateDoc(S(alice), { saldo: -1, updatedAt: ts() }));
  await check('saldo: saldo > 3 falla', false,
    () => updateDoc(S(alice), { saldo: 4, ultimaConcesionYM: mesActual(), concedidosTotal: 4, updatedAt: ts() }));
  await check('saldo: NO se puede borrar (evita farmear recreándolo)', false, () => deleteDoc(S(alice)));

  // Simulamos "el mes pasado" para poder probar la concesión: se retrocede
  // ultimaConcesionYM con una escritura de servidor... no es posible desde el
  // cliente, así que se prueba el rechazo y la concesión real de 1 mes con un
  // usuario nuevo (dave) creado con el mes anterior ya imposible de fijar.
  await check('saldo: no se puede retroceder ultimaConcesionYM', false,
    () => updateDoc(S(alice), { ultimaConcesionYM: mesActual() - 3, updatedAt: ts() }));

  // ---------------- comodines: consumo atómico
  await check('diasProtegidos: crear suelto sin pagar falla', false,
    () => setDoc(DP(alice, AYER), { dia: AYER, createdAt: ts() }));
  await check('saldo: decrementar suelto sin proteger falla', false,
    () => updateDoc(S(alice), { saldo: 0, ultimoDiaProtegido: AYER, updatedAt: ts() }));

  const consumir = (db, dia, over = {}) => {
    const batch = writeBatch(db);
    batch.set(DP(db, dia), { dia, createdAt: ts() });
    batch.update(S(db), { saldo: 0, ultimoDiaProtegido: dia, updatedAt: ts(), ...over });
    return batch.commit();
  };

  // Con saldo 1: todas estas formas inválidas deben fallar POR SU FORMA, no
  // por falta de saldo, así que van antes del consumo válido.
  await check('consumo: proteger una fecha antigua arbitraria falla', false, () => consumir(alice, '2020-01-01'));
  await check('consumo: proteger dentro de 5 días falla', false, () => consumir(alice, dayKey(5)));
  await check('consumo: proteger hace 5 días falla', false, () => consumir(alice, dayKey(-5)));
  await check('consumo: decrementar 2 de golpe falla', false, () => {
    const batch = writeBatch(alice);
    batch.set(DP(alice, AYER), { dia: AYER, createdAt: ts() });
    batch.update(S(alice), { saldo: -1, ultimoDiaProtegido: AYER, updatedAt: ts() });
    return batch.commit();
  });
  await check('consumo: colar una concesión junto al consumo falla', false,
    () => consumir(alice, AYER, { concedidosTotal: 99 }));
  await check('consumo: día protegido con campo extra falla', false, () => {
    const batch = writeBatch(alice);
    batch.set(DP(alice, AYER), { dia: AYER, racha: 99, createdAt: ts() });
    batch.update(S(alice), { saldo: 0, ultimoDiaProtegido: AYER, updatedAt: ts() });
    return batch.commit();
  });
  await check('consumo: id del día distinto del campo dia falla', false, () => {
    const batch = writeBatch(alice);
    batch.set(DP(alice, AYER), { dia: ANTEAYER, createdAt: ts() });
    batch.update(S(alice), { saldo: 0, ultimoDiaProtegido: AYER, updatedAt: ts() });
    return batch.commit();
  });
  await check('consumo atómico válido: paga 1 y protege ayer', true, () => consumir(alice, AYER));
  await check('consumo: proteger el MISMO día otra vez falla', false, () => {
    const batch = writeBatch(alice);
    batch.set(DP(alice, AYER), { dia: AYER, createdAt: ts() });
    batch.update(S(alice), { saldo: 0, ultimoDiaProtegido: AYER, updatedAt: ts() });
    return batch.commit();
  });
  await check('consumo: con saldo 0 no se puede volver a consumir', false,
    () => consumir(alice, ANTEAYER));

  // LIMITACIÓN CONOCIDA, con saldo fresco para que el motivo sea la ventana y
  // no la falta de comodines: igual que con los registros, las Rules no
  // pueden resolver la zona IANA del perfil, así que ANTEAYER puede caer
  // dentro de la ventana [request.time-60h, request.time-10h]. El "solo ayer"
  // exacto lo aplican el dominio y el cliente; la garantía estricta exige
  // trusted backend. Este test documenta el margen real, no lo aprueba.
  // Cada caso usa un usuario nuevo para que el motivo sea la VENTANA y no la
  // falta de saldo.
  const consumirComo = (db, uid, dia) => {
    const batch = writeBatch(db);
    batch.set(doc(db, 'users', uid, 'diasProtegidos', dia), { dia, createdAt: ts() });
    batch.update(doc(db, 'users', uid, 'comodines', 'saldo'),
      { saldo: 0, ultimoDiaProtegido: dia, updatedAt: ts() });
    return batch.commit();
  };

  // Cotas para días protegidos: [request.time-60h, request.time-10h].
  // AYER siempre entra (que es justo lo que el producto necesita) y hace 3
  // días nunca; ANTEAYER y HOY dependen de la hora: ese es el margen.
  const dave = env.authenticatedContext('dave', { email: 'dave@example.com', email_verified: true }).firestore();
  await check('dave: saldo inicial', true, () => setDoc(doc(dave, 'users', 'dave', 'comodines', 'saldo'), saldo()));
  await check('ventana comodín: hace 3 días SIEMPRE se rechaza', false,
    () => consumirComo(dave, 'dave', dayKey(-3)));
  await check(
    `LIMITACIÓN: anteayer ${anteayerEntraEnVentanaDeRescate() ? 'entra' : 'no entra'} en la ventana ahora mismo`,
    anteayerEntraEnVentanaDeRescate(),
    () => consumirComo(dave, 'dave', ANTEAYER));

  const erin = env.authenticatedContext('erin', { email: 'erin@example.com', email_verified: true }).firestore();
  await check('erin: saldo inicial', true, () => setDoc(doc(erin, 'users', 'erin', 'comodines', 'saldo'), saldo()));
  // Proteger "hoy" es inútil (hoy todavía no ha terminado) pero no es un
  // agujero: gasta un comodín sin cambiar la racha. El dominio nunca lo pide.
  await check(
    `LIMITACIÓN: hoy ${hoyEntraEnVentanaDeRescate() ? 'entra' : 'no entra'} en la ventana de rescate ahora mismo`,
    hoyEntraEnVentanaDeRescate(),
    () => consumirComo(erin, 'erin', HOY));
  await check('día protegido: update prohibido', false, () => updateDoc(DP(alice, AYER), { dia: HOY }));
  await check('día protegido: delete prohibido (auditoría)', false, () => deleteDoc(DP(alice, AYER)));
  await check('día protegido: alice lo lee', true, () => getDoc(DP(alice, AYER)));
  await check('bob no lee los días protegidos de alice', false, () => getDoc(DP(bob, AYER)));
  await check('bob no crea días protegidos en alice', false,
    () => setDoc(DP(bob, AYER), { dia: AYER, createdAt: ts() }));

  // ---------------- cache/rachas
  await check('cache válida se escribe', true, () => setDoc(U(alice, 'cache', 'rachas'), cache()));
  await check('cache con id distinto falla', false, () => setDoc(U(alice, 'cache', 'otro'), cache()));
  await check('cache con forma antigua (general/habitos/ambitos) falla', false,
    () => setDoc(U(alice, 'cache', 'rachas'), { general: { actual: 3, mejor: 5, comodinDisponible: true }, habitos: {}, ambitos: {}, calculadoHasta: HOY, updatedAt: ts() }));
  await check('cache racha negativa falla', false, () => setDoc(U(alice, 'cache', 'rachas'), cache({ rachaActual: -1 })));
  await check('cache con clave extra falla', false, () => setDoc(U(alice, 'cache', 'rachas'), cache({ hack: 1 })));
  await check('cache sin version falla', false, () => { const c = cache(); delete c.version; return setDoc(U(alice, 'cache', 'rachas'), c); });
  await check('cache sin updatedAt servidor falla', false, () => setDoc(U(alice, 'cache', 'rachas'), cache({ updatedAt: Timestamp.now() })));
  await check('cache se puede borrar entera (es reconstruible)', true, () => deleteDoc(U(alice, 'cache', 'rachas')));
  await check('bob no escribe cache de alice', false, () => setDoc(doc(bob, 'users', 'alice', 'cache', 'rachas'), cache()));

  // ---------------- fuera del modelo
  await check('colección raíz desconocida falla', false, () => setDoc(doc(alice, 'global', 'x'), { a: 1 }));
  await check('subcolección desconocida falla', false, () => setDoc(U(alice, 'otros', 'x'), { a: 1 }));

  await env.cleanup();
  const failed = results.filter(r => !r.ok);
  for (const r of results) console.log((r.ok ? 'PASS ' : 'FAIL ') + r.name + (r.err ? '  -> ' + r.err : ''));
  console.log(`\n${results.length - failed.length}/${results.length} pruebas OK`);
  process.exit(failed.length ? 1 : 0);
})().catch(e => { console.error('ERROR', e); process.exit(2); });
