import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';

/// Documento `users/{uid}/cache/rachas`.
///
/// Es una PROYECCIÓN reconstruible, nunca una autoridad: se puede borrar
/// entera y recalcularse desde los registros y los días protegidos (§31).
/// Ya no cachea rachas por hábito ni por ámbito: solo existe la racha
/// general (§1).
class StreaksDto {
  const StreaksDto({
    required this.rachaActual,
    required this.mejorRacha,
    required this.ultimoDiaActividad,
    required this.calculadoHasta,
    required this.version,
  });

  final int rachaActual;
  final int mejorRacha;
  final String? ultimoDiaActividad;
  final String? calculadoHasta;
  final int version;

  factory StreaksDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return StreaksDto(
      rachaActual: (data[FirestoreFields.rachaActual] as num?)?.toInt() ?? 0,
      mejorRacha: (data[FirestoreFields.mejorRacha] as num?)?.toInt() ?? 0,
      ultimoDiaActividad:
          data[FirestoreFields.ultimoDiaActividad] as String?,
      calculadoHasta: data[FirestoreFields.calculadoHasta] as String?,
      version: (data[FirestoreFields.version] as num?)?.toInt() ?? 0,
    );
  }
}
