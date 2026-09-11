import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';

/// Documento `users/{uid}/habitos/{id}` tal y como está en Firestore.
///
/// Lee tanto el esquema de la fase 5 como el anterior: `periodicidad` pudo
/// guardarse como string suelto y la línea temporal se llamaba
/// `historialPeriodicidad`. La normalización se hace al leer y el documento
/// queda migrado la primera vez que se escribe (migración perezosa, sin
/// tocar datos en masa).
class HabitDto {
  const HabitDto({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.colorValue,
    required this.ambitoId,
    required this.periodicidad,
    required this.cambiosPeriodicidad,
    required this.recordatorioHora,
    required this.orden,
    required this.createdAt,
    required this.deletedAt,
  });

  final String id;
  final String nombre;
  final String emoji;
  final int colorValue;
  final String ambitoId;

  /// `{tipo, veces}` ya normalizado.
  final Map<String, dynamic> periodicidad;

  /// Lista de `{tipo, veces, desde}` con `desde` como día lógico.
  final List<Map<String, dynamic>> cambiosPeriodicidad;
  final String? recordatorioHora;
  final int orden;

  /// Null mientras el serverTimestamp está pendiente (escritura local aún
  /// no confirmada por el servidor).
  final DateTime? createdAt;
  final DateTime? deletedAt;

  factory HabitDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return HabitDto(
      id: doc.id,
      nombre: data[FirestoreFields.nombre] as String? ?? '',
      emoji: data[FirestoreFields.emoji] as String? ?? '',
      colorValue: (data[FirestoreFields.colorValue] as num?)?.toInt() ?? 0,
      ambitoId: data[FirestoreFields.ambitoId] as String? ?? '',
      periodicidad: normalizePeriodicidad(data[FirestoreFields.periodicidad]),
      cambiosPeriodicidad: _readTimeline(data),
      recordatorioHora: data[FirestoreFields.recordatorioHora] as String?,
      orden: (data[FirestoreFields.orden] as num?)?.toInt() ?? 0,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
      deletedAt: (data[FirestoreFields.deletedAt] as Timestamp?)?.toDate(),
    );
  }

  /// Acepta el mapa nuevo `{tipo, veces}` y el string suelto de la fase 4.
  ///
  /// Migración autorizada: un `periodicidad: 'weekly'` antiguo se interpreta
  /// como "1 vez por semana", que es la única lectura razonable del modelo
  /// anterior, donde la periodicidad no llevaba cantidad.
  static Map<String, dynamic> normalizePeriodicidad(Object? raw) {
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      return {
        FirestoreFields.tipo: map[FirestoreFields.tipo] as String? ?? 'daily',
        FirestoreFields.veces:
            (map[FirestoreFields.veces] as num?)?.toInt() ?? 1,
      };
    }
    if (raw is String) {
      return {FirestoreFields.tipo: raw, FirestoreFields.veces: 1};
    }
    return {FirestoreFields.tipo: 'daily', FirestoreFields.veces: 1};
  }

  static List<Map<String, dynamic>> _readTimeline(Map<String, dynamic> data) {
    final raw =
        data[FirestoreFields.cambiosPeriodicidad] ??
        data[FirestoreFields.legacyHistorialPeriodicidad];
    if (raw is! List) return const [];
    return [
      for (final entry in raw.whereType<Map>())
        () {
          final map = Map<String, dynamic>.from(entry);
          final periodicity = normalizePeriodicidad(
            map.containsKey(FirestoreFields.tipo)
                ? map
                : map[FirestoreFields.periodicidad],
          );
          return <String, dynamic>{
            FirestoreFields.tipo: periodicity[FirestoreFields.tipo],
            FirestoreFields.veces: periodicity[FirestoreFields.veces],
            FirestoreFields.desde: map[FirestoreFields.desde] as String? ?? '',
          };
        }(),
    ];
  }

  /// Campos editables del documento (sin marcas de tiempo).
  Map<String, dynamic> toEditableMap() => {
    FirestoreFields.nombre: nombre,
    FirestoreFields.emoji: emoji,
    FirestoreFields.colorValue: colorValue,
    FirestoreFields.ambitoId: ambitoId,
    FirestoreFields.periodicidad: periodicidad,
    FirestoreFields.cambiosPeriodicidad: cambiosPeriodicidad,
    FirestoreFields.recordatorioHora: recordatorioHora,
    FirestoreFields.orden: orden,
  };
}
