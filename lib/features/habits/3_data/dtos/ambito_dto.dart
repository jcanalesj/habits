import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';

/// Documento `users/{uid}/ambitos/{id}` tal y como está en Firestore.
class AmbitoDto {
  const AmbitoDto({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.colorValue,
    required this.esPredefinido,
    required this.orden,
    required this.createdAt,
  });

  final String id;
  final String nombre;
  final String emoji;
  final int colorValue;
  final bool esPredefinido;
  final int orden;
  final DateTime? createdAt;

  factory AmbitoDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AmbitoDto(
      id: doc.id,
      nombre: data[FirestoreFields.nombre] as String? ?? '',
      emoji: data[FirestoreFields.emoji] as String? ?? '',
      colorValue: (data[FirestoreFields.colorValue] as num?)?.toInt() ?? 0,
      esPredefinido: data[FirestoreFields.esPredefinido] as bool? ?? false,
      orden: (data[FirestoreFields.orden] as num?)?.toInt() ?? 0,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
    );
  }

  /// Campos editables (esPredefinido es inmutable y no se envía).
  Map<String, dynamic> toEditableMap() => {
    FirestoreFields.nombre: nombre,
    FirestoreFields.emoji: emoji,
    FirestoreFields.colorValue: colorValue,
    FirestoreFields.orden: orden,
  };
}
