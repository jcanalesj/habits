/// Nombres de colecciones y campos en Firestore (ver firestore.rules).
/// Únicos puntos donde se escriben literales de esquema.
abstract final class FirestoreFields {
  static const users = 'users';
  static const ambitos = 'ambitos';
  static const habitos = 'habitos';
  static const registros = 'registros';
  static const cache = 'cache';
  static const rachasDoc = 'rachas';

  // Comunes
  static const nombre = 'nombre';
  static const emoji = 'emoji';
  static const colorValue = 'colorValue';
  static const orden = 'orden';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';

  // Ámbitos
  static const esPredefinido = 'esPredefinido';

  // Hábitos
  static const ambitoId = 'ambitoId';
  static const periodicidad = 'periodicidad';
  static const historialPeriodicidad = 'historialPeriodicidad';
  static const desde = 'desde';
  static const descansosPermitidos = 'descansosPermitidos';
  static const tareaRecuperacion = 'tareaRecuperacion';
  static const recuperacionCooldownDias = 'recuperacionCooldownDias';
  static const recordatorioHora = 'recordatorioHora';
  static const deletedAt = 'deletedAt';

  // Registros
  static const habitoId = 'habitoId';
  static const dia = 'dia';
  static const tipo = 'tipo';
  static const tz = 'tz';

  // cache/rachas
  static const general = 'general';
  static const actual = 'actual';
  static const mejor = 'mejor';
  static const comodinDisponible = 'comodinDisponible';
  static const ultimoDiaRegistrado = 'ultimoDiaRegistrado';
  static const calculadoHasta = 'calculadoHasta';
}
