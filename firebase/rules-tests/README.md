# Pruebas de Security Rules (Firestore)

Batería de pruebas de comportamiento de `firestore.rules` ejecutada contra el
emulador de Firestore. Cubre aislamiento entre usuarios, email verificado,
campos derivados prohibidos, inmutables, soft delete de hábitos, ids de
registros, fechas inválidas/futuras y las consultas reales de la app.

## Requisitos

- Node 22+, Firebase CLI (`firebase --version`) y Java 21+ (emulador).

## Ejecutar en local

```bash
cd firebase/rules-tests
npm install
npm test            # arranca el emulador, ejecuta las pruebas y lo apaga
```

Si ya tienes el emulador levantado (`firebase emulators:start`):

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run test:no-emulator
```

## CI

El script `npm test` devuelve código distinto de cero si alguna prueba falla.
Ejemplo de job (GitHub Actions):

```yaml
- uses: actions/setup-node@v4
  with: { node-version: 22 }
- uses: actions/setup-java@v4
  with: { distribution: temurin, java-version: 21 }
- run: npm install -g firebase-tools
- run: cd firebase/rules-tests && npm ci && npm test
```

Ejecutar estas pruebas antes de cada `firebase deploy --only firestore:rules`.
