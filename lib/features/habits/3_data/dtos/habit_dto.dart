import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';

/// Documento `users/{uid}/habitos/{id}` tal y como está en Firestore.
class HabitDto {
  const HabitDto({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.colorValue,
    required this.ambitoId,
    required this.periodicidad,
    required this.historialPeriodicidad,
    required this.descansosPermitidos,
    required this.tareaRecuperacion,
    required this.recuperacionCooldownDias,
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
  final String periodicidad;

  /// Lista de `{periodicidad, desde}` con `desde` como día lógico.
  final List<Map<String, dynamic>> historialPeriodicidad;
  final int descansosPermitidos;
  final String? tareaRecuperacion;
  final int recuperacionCooldownDias;
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
      periodicidad: data[FirestoreFields.periodicidad] as String? ?? 'daily',
      historialPeriodicidad:
          (data[FirestoreFields.historialPeriodicidad] as List?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          const [],
      descansosPermitidos:
          (data[FirestoreFields.descansosPermitidos] as num?)?.toInt() ?? 0,
      tareaRecuperacion: data[FirestoreFields.tareaRecuperacion] as String?,
      recuperacionCooldownDias:
          (data[FirestoreFields.recuperacionCooldownDias] as num?)?.toInt() ??
          7,
      recordatorioHora: data[FirestoreFields.recordatorioHora] as String?,
      orden: (data[FirestoreFields.orden] as num?)?.toInt() ?? 0,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
      deletedAt: (data[FirestoreFields.deletedAt] as Timestamp?)?.toDate(),
    );
  }

  /// Campos editables del documento (sin marcas de tiempo).
  Map<String, dynamic> toEditableMap() => {
    FirestoreFields.nombre: nombre,
    FirestoreFields.emoji: emoji,
    FirestoreFields.colorValue: colorValue,
    FirestoreFields.ambitoId: ambitoId,
    FirestoreFields.periodicidad: periodicidad,
    FirestoreFields.historialPeriodicidad: historialPeriodicidad,
    FirestoreFields.descansosPermitidos: descansosPermitidos,
    FirestoreFields.tareaRecuperacion: tareaRecuperacion,
    FirestoreFields.recuperacionCooldownDias: recuperacionCooldownDias,
    FirestoreFields.recordatorioHora: recordatorioHora,
    FirestoreFields.orden: orden,
  };
}
