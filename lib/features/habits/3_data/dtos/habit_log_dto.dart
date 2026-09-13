import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';

/// Documento `users/{uid}/registros/{habitoId}_{YYYY-MM-DD}`.
class HabitLogDto {
  const HabitLogDto({
    required this.id,
    required this.habitoId,
    required this.dia,
    required this.tipo,
    required this.completedCount,
    required this.targetCount,
  });

  final String id;
  final String habitoId;

  /// Día lógico `YYYY-MM-DD`.
  final String dia;

  /// `completed` desde la fase 5. Los documentos antiguos pueden traer
  /// `recovery` o `plannedRest`: se conservan pero no cuentan como
  /// actividad real.
  final String tipo;
  final int completedCount;
  final int targetCount;

  /// Id determinista del registro: marcar es `set`, desmarcar es `delete`.
  static String idFor(String habitoId, String dia) => '${habitoId}_$dia';

  factory HabitLogDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return HabitLogDto(
      id: doc.id,
      habitoId: data[FirestoreFields.habitoId] as String? ?? '',
      dia: data[FirestoreFields.dia] as String? ?? '',
      tipo:
          data[FirestoreFields.tipo] as String? ??
          FirestoreFields.tipoCompleted,
      completedCount:
          (data[FirestoreFields.completedCount] as num?)?.toInt() ?? 1,
      targetCount: (data[FirestoreFields.targetCount] as num?)?.toInt() ?? 1,
    );
  }
}
