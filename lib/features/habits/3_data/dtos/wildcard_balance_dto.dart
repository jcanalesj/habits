import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';

/// Documento `users/{uid}/comodines/saldo`.
///
/// FUENTE DE VERDAD del saldo, no caché. Las Security Rules validan cada
/// transición: solo se admite la concesión mensual y el consumo atado a un
/// día protegido; cualquier otra mutación se rechaza (§38).
class WildcardBalanceDto {
  const WildcardBalanceDto({
    required this.saldo,
    required this.ultimaConcesionYM,
    required this.concedidosTotal,
    required this.ultimoDiaProtegido,
  });

  final int saldo;
  final int ultimaConcesionYM;
  final int concedidosTotal;
  final String? ultimoDiaProtegido;

  factory WildcardBalanceDto.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return WildcardBalanceDto(
      saldo: (data[FirestoreFields.saldo] as num?)?.toInt() ?? 0,
      ultimaConcesionYM:
          (data[FirestoreFields.ultimaConcesionYM] as num?)?.toInt() ?? 0,
      concedidosTotal:
          (data[FirestoreFields.concedidosTotal] as num?)?.toInt() ?? 0,
      ultimoDiaProtegido: data[FirestoreFields.ultimoDiaProtegido] as String?,
    );
  }
}

/// Documento `users/{uid}/diasProtegidos/{YYYY-MM-DD}`. El id ES el día, lo
/// que hace estructuralmente imposible proteger dos veces el mismo día.
class ProtectedDayDto {
  const ProtectedDayDto({required this.dia, required this.createdAt});

  final String dia;
  final DateTime? createdAt;

  factory ProtectedDayDto.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return ProtectedDayDto(
      dia: data[FirestoreFields.dia] as String? ?? doc.id,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
    );
  }
}
