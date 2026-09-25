/// Espera razonable a que el servidor confirme una escritura de Firestore.
///
/// Firestore aplica cada escritura a la caché local al instante (los
/// listeners la ven enseguida) y la sube cuando hay red, pero el `Future` de
/// `set`/`update`/`delete`/`commit` no se completa hasta que el servidor
/// confirma: sin conexión, nunca. Esperarlo tal cual deja la interfaz
/// cargando para siempre en modo avión.
///
/// [awaitWrite] espera un momento para capturar los rechazos rápidos (reglas,
/// validación) y, si el servidor no ha contestado, da la escritura por
/// encolada: se enviará sola al recuperar la conexión.
const firestoreWriteConfirmTimeout = Duration(seconds: 3);

Future<void> awaitWrite(Future<void> write) => write
    // `add()` devuelve Future<DocumentReference>: se convierte a Future<void>
    // antes del timeout para que `onTimeout` tenga el tipo correcto.
    .then<void>((_) {})
    // `timeout` sigue escuchando el Future original, así que un error que
    // llegue después no queda como excepción sin tratar.
    .timeout(firestoreWriteConfirmTimeout, onTimeout: () {});
