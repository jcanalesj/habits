/// Nombres de colecciones y campos en Firestore (ver firestore.rules).
/// Únicos puntos donde se escriben literales de esquema.
abstract final class FirestoreFields {
  static const users = 'users';
  static const ambitos = 'ambitos';
  static const habitos = 'habitos';
  static const registros = 'registros';
  static const diasProtegidos = 'diasProtegidos';
  static const comodines = 'comodines';
  static const saldoDoc = 'saldo';
  static const cache = 'cache';
  static const rachasDoc = 'rachas';

  // Comunes
  static const nombre = 'nombre';
  static const emoji = 'emoji';
  static const colorValue = 'colorValue';
  static const orden = 'orden';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';

  // Perfil
  static const timezone = 'timezone';

  // Ámbitos
  static const esPredefinido = 'esPredefinido';

  // Hábitos
  static const ambitoId = 'ambitoId';
  static const iconId = 'iconId';

  /// Configuración inicial: mapa `{tipo, veces}`. En documentos anteriores a
  /// la fase 5 era un string suelto (`'weekly'`); el mapper lee ambas formas.
  static const periodicidad = 'periodicidad';
  static const tipo = 'tipo';
  static const veces = 'veces';

  /// Línea temporal de cambios de objetivo: `[{tipo, veces, desde}]`, con
  /// `desde` como día lógico que puede ser futuro.
  static const cambiosPeriodicidad = 'cambiosPeriodicidad';
  static const desde = 'desde';
  static const recordatorioHora = 'recordatorioHora';
  static const recordatorioMensaje = 'recordatorioMensaje';
  static const trackingType = 'trackingType';
  static const targetCount = 'targetCount';
  static const completedCount = 'completedCount';
  static const unit = 'unit';
  static const displayGoal = 'displayGoal';
  static const progressIconId = 'progressIconId';
  static const deletedAt = 'deletedAt';

  /// Nombre anterior de [cambiosPeriodicidad] (fase 4). Solo lectura.
  static const legacyHistorialPeriodicidad = 'historialPeriodicidad';

  /// Campos del modelo antiguo de descansos y recuperación, retirados del
  /// motor en la fase 5 (§27/§28). Ya no se escriben; se borran de cada
  /// documento la primera vez que se edita (migración perezosa).
  static const legacyDescansosPermitidos = 'descansosPermitidos';
  static const legacyTareaRecuperacion = 'tareaRecuperacion';
  static const legacyRecuperacionCooldownDias = 'recuperacionCooldownDias';

  static const legacyHabitFields = [
    legacyDescansosPermitidos,
    legacyTareaRecuperacion,
    legacyRecuperacionCooldownDias,
    legacyHistorialPeriodicidad,
  ];

  // Registros
  static const habitoId = 'habitoId';
  static const dia = 'dia';
  static const tz = 'tz';

  /// Único valor de `tipo` que produce la app desde la fase 5. Los valores
  /// antiguos (`recovery`, `plannedRest`) se conservan en los documentos
  /// existentes pero NO cuentan como actividad real.
  static const tipoCompleted = 'completed';

  // comodines/saldo
  static const saldo = 'saldo';
  static const ultimaConcesionYM = 'ultimaConcesionYM';
  static const concedidosTotal = 'concedidosTotal';
  static const ultimoDiaProtegido = 'ultimoDiaProtegido';

  // cache/rachas
  static const rachaActual = 'rachaActual';
  static const mejorRacha = 'mejorRacha';
  static const ultimoDiaActividad = 'ultimoDiaActividad';
  static const calculadoHasta = 'calculadoHasta';
  static const version = 'version';
}
