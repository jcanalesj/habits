const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const {
  doc, setDoc, getDoc, updateDoc, deleteDoc, serverTimestamp, Timestamp,
  collection, getDocs, query, where, orderBy,
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
  nombre: 'Beber agua', emoji: '💧', colorValue: 0xFF3B82F6, ambitoId: 'salud',
  periodicidad: 'daily', historialPeriodicidad: [], descansosPermitidos: 2,
  tareaRecuperacion: null, recuperacionCooldownDias: 7, recordatorioHora: '18:00',
  orden: 0, deletedAt: null, createdAt: ts(), updatedAt: ts(), ...over,
});
const registro = (over = {}) => ({
  habitoId: 'h1', dia: '2026-09-10', tipo: 'completed', tz: 'Europe/Madrid', createdAt: ts(), ...over,
});
const cache = (over = {}) => ({
  general: { actual: 3, mejor: 10, comodinDisponible: true, ultimoDiaRegistrado: '2026-09-10' },
  habitos: { h1: { actual: 3, mejor: 5 } }, ambitos: { salud: { actual: 3, mejor: 5, comodinDisponible: true } },
  calculadoHasta: '2026-09-10', version: 1, updatedAt: ts(), ...over,
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
  await check('no verificado no crea perfil', false, () => setDoc(U(aliceUnverified), user()));
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
  await check('perfil: lastActiveAt serverTimestamp', true, () => updateDoc(U(alice), { lastActiveAt: ts(), updatedAt: ts() }));
  await check('perfil: update posterior sin tocar lastActiveAt', true, () => updateDoc(U(alice), { locale: 'en', updatedAt: ts() }));
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
  await check('habito periodicidad inválida falla', false, () => setDoc(U(alice, 'habitos', 'h1'), habito({ periodicidad: 'hourly' })));
  await check('habito hora 25:00 falla', false, () => setDoc(U(alice, 'habitos', 'h1'), habito({ recordatorioHora: '25:00' })));
  await check('habito creado ya borrado falla', false, () => setDoc(U(alice, 'habitos', 'h1'), habito({ deletedAt: ts() })));
  await check('habito válido se crea', true, () => setDoc(U(alice, 'habitos', 'h1'), habito()));
  await check('habito h2 con recuperación se crea', true, () => setDoc(U(alice, 'habitos', 'h2'), habito({ nombre: 'Entrenar', tareaRecuperacion: '10 flexiones', recordatorioHora: null })));
  await check('habito h3 se crea', true, () => setDoc(U(alice, 'habitos', 'h3'), habito({ nombre: 'Leer' })));
  await check('habito: reasignar a ambito inexistente falla', false, () => updateDoc(U(alice, 'habitos', 'h1'), { ambitoId: 'nope', updatedAt: ts() }));
  await check('habito: reasignar a general válido', true, () => updateDoc(U(alice, 'habitos', 'h1'), { ambitoId: 'general', updatedAt: ts() }));
  await check('habito: cambiar createdAt falla', false, () => updateDoc(U(alice, 'habitos', 'h1'), { createdAt: ts(), updatedAt: ts() }));
  await check('habito: hard delete falla', false, () => deleteDoc(U(alice, 'habitos', 'h1')));
  await check('habito: soft delete con fecha arbitraria falla', false, () => updateDoc(U(alice, 'habitos', 'h3'), { deletedAt: Timestamp.fromDate(new Date(2020, 0, 1)), updatedAt: ts() }));

  // ---------------- registros (antes de borrar h3)
  await check('registro válido se crea', true, () => setDoc(U(alice, 'registros', 'h1_2026-09-10'), registro()));
  await check('registro en h3 se crea', true, () => setDoc(U(alice, 'registros', 'h3_2026-09-09'), registro({ habitoId: 'h3', dia: '2026-09-09' })));
  await check('registro id no coincide falla', false, () => setDoc(U(alice, 'registros', 'h1_2026-09-11'), registro()));
  await check('registro fecha futura falla', false, () => setDoc(U(alice, 'registros', 'h1_2030-01-01'), registro({ dia: '2030-01-01' })));
  await check('registro dia inválido 2026-13-01 falla', false, () => setDoc(U(alice, 'registros', 'h1_2026-13-01'), registro({ dia: '2026-13-01' })));
  await check('registro dia inexistente 2026-02-30 falla', false, () => setDoc(U(alice, 'registros', 'h1_2026-02-30'), registro({ dia: '2026-02-30' })));
  await check('registro habito inexistente falla', false, () => setDoc(U(alice, 'registros', 'zz_2026-09-10'), registro({ habitoId: 'zz' })));
  await check('registro tipo inválido falla', false, () => setDoc(U(alice, 'registros', 'h1_2026-09-09'), registro({ dia: '2026-09-09', tipo: 'skipped' })));
  await check('registro recovery sin tarea en habito falla', false, () => setDoc(U(alice, 'registros', 'h1_2026-09-08'), registro({ dia: '2026-09-08', tipo: 'recovery' })));
  await check('registro recovery con tarea en h2 válido', true, () => setDoc(U(alice, 'registros', 'h2_2026-09-08'), registro({ habitoId: 'h2', dia: '2026-09-08', tipo: 'recovery' })));
  await check('registro plannedRest válido', true, () => setDoc(U(alice, 'registros', 'h1_2026-09-07'), registro({ dia: '2026-09-07', tipo: 'plannedRest' })));
  await check('registro con campo extra falla', false, () => setDoc(U(alice, 'registros', 'h1_2026-09-06'), registro({ dia: '2026-09-06', racha: 4 })));
  await check('registro: cambiar tipo válido', true, () => updateDoc(U(alice, 'registros', 'h1_2026-09-07'), { tipo: 'completed', updatedAt: ts() }));
  await check('registro: cambiar dia falla', false, () => updateDoc(U(alice, 'registros', 'h1_2026-09-07'), { dia: '2026-09-05' }));
  await check('registro: desmarcar (delete) válido', true, () => deleteDoc(U(alice, 'registros', 'h1_2026-09-07')));
  await check('bob no lee registros de alice', false, () => getDoc(doc(bob, 'users', 'alice', 'registros', 'h1_2026-09-10')));

  // soft delete h3 y comprobar inmutabilidad de su histórico
  await check('habito h3 soft delete válido', true, () => updateDoc(U(alice, 'habitos', 'h3'), { deletedAt: ts(), updatedAt: ts() }));
  await check('registro nuevo en habito borrado falla', false, () => setDoc(U(alice, 'registros', 'h3_2026-09-10'), registro({ habitoId: 'h3', dia: '2026-09-10' })));
  await check('registro histórico de habito borrado no se borra', false, () => deleteDoc(U(alice, 'registros', 'h3_2026-09-09')));
  await check('registro histórico de habito borrado sigue legible', true, () => getDoc(U(alice, 'registros', 'h3_2026-09-09')));
  await check('habito borrado: restaurar (deletedAt null) válido', true, () => updateDoc(U(alice, 'habitos', 'h3'), { deletedAt: null, updatedAt: ts() }));
  await check('habito h3 soft delete de nuevo', true, () => updateDoc(U(alice, 'habitos', 'h3'), { deletedAt: ts(), updatedAt: ts() }));

  // ---------------- consultas reales de la app (validan reglas + índices en emulador)
  await check('query habitos activos ordenados', true, async () => {
    const snap = await getDocs(query(collection(alice, 'users', 'alice', 'habitos'), where('deletedAt', '==', null), orderBy('orden')));
    if (snap.size !== 2) throw new Error('esperaba 2 activos, hay ' + snap.size);
  });
  await check('query registros por habito y rango de dias', true, async () => {
    const snap = await getDocs(query(collection(alice, 'users', 'alice', 'registros'),
      where('habitoId', '==', 'h1'), where('dia', '>=', '2026-09-07'), where('dia', '<=', '2026-09-13'), orderBy('dia')));
    if (snap.size !== 1) throw new Error('esperaba 1 registro, hay ' + snap.size);
  });
  await check('query registros semana (todos los habitos)', true, async () => {
    const snap = await getDocs(query(collection(alice, 'users', 'alice', 'registros'), where('dia', '>=', '2026-09-07'), where('dia', '<=', '2026-09-13')));
    if (snap.size !== 3) throw new Error('esperaba 3 registros, hay ' + snap.size);
  });
  await check('bob no lista registros de alice', false, () => getDocs(collection(bob, 'users', 'alice', 'registros')));

  // ---------------- cache/rachas
  await check('cache válida se escribe', true, () => setDoc(U(alice, 'cache', 'rachas'), cache()));
  await check('cache con id distinto falla', false, () => setDoc(U(alice, 'cache', 'otro'), cache()));
  await check('cache actual negativo falla', false, () => setDoc(U(alice, 'cache', 'rachas'), cache({ general: { actual: -1, mejor: 0, comodinDisponible: true } })));
  await check('cache general con clave extra falla', false, () => setDoc(U(alice, 'cache', 'rachas'), cache({ general: { actual: 1, mejor: 1, comodinDisponible: true, hack: 1 } })));
  await check('cache sin updatedAt servidor falla', false, () => setDoc(U(alice, 'cache', 'rachas'), cache({ updatedAt: Timestamp.now() })));
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
