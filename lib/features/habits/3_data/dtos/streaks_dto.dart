import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';

/// Documento `users/{uid}/cache/rachas` (caché derivada, puede no existir).
class StreaksDto {
  const StreaksDto({
    required this.generalActual,
    required this.generalMejor,
    required this.generalComodinDisponible,
    required this.ultimoDiaRegistrado,
    required this.habitos,
    required this.ambitos,
    required this.calculadoHasta,
  });

  final int generalActual;
  final int generalMejor;
  final bool generalComodinDisponible;
  final String? ultimoDiaRegistrado;

  /// `{habitoId: {actual, mejor}}`
  final Map<String, Map<String, dynamic>> habitos;

  /// `{ambitoId: {actual, mejor, comodinDisponible}}`
  final Map<String, Map<String, dynamic>> ambitos;
  final String? calculadoHasta;

  factory StreaksDto.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final general = _asMap(data[FirestoreFields.general]);
    return StreaksDto(
      generalActual: (general[FirestoreFields.actual] as num?)?.toInt() ?? 0,
      generalMejor: (general[FirestoreFields.mejor] as num?)?.toInt() ?? 0,
      generalComodinDisponible:
          general[FirestoreFields.comodinDisponible] as bool? ?? true,
      ultimoDiaRegistrado:
          general[FirestoreFields.ultimoDiaRegistrado] as String?,
      habitos: _asMapOfMaps(data['habitos']),
      ambitos: _asMapOfMaps(data['ambitos']),
      calculadoHasta: data[FirestoreFields.calculadoHasta] as String?,
    );
  }

  static Map<String, dynamic> _asMap(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static Map<String, Map<String, dynamic>> _asMapOfMaps(Object? value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        if (entry.value is Map)
          entry.key as String: Map<String, dynamic>.from(entry.value as Map),
    };
  }
}
