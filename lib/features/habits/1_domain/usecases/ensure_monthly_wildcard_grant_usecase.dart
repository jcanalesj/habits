import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/wildcards_repository.dart';

/// Concede los comodines gratuitos mensuales pendientes.
///
/// Se ejecuta perezosamente al abrir la app; no hay ninguna tarea
/// programada. Es idempotente y resiste abrir y cerrar la app muchas veces,
/// reinstalar y no abrirla durante meses: el estado vive en el servidor y la
/// concesión se deduce de los meses transcurridos, no del hecho de estar
/// abierta el día 1 (§20).
///
/// Falla en silencio a propósito: no poder conceder un comodín (por ejemplo
/// sin red) no debe impedir usar la app.
class EnsureMonthlyWildcardGrantUsecase {
  const EnsureMonthlyWildcardGrantUsecase(this._wildcards);

  final WildcardsRepository _wildcards;

  /// [today] se usa solo para obtener el año/mes actual; la concesión no
  /// depende del día. Debe ser el día en UTC: las reglas validan el mes con
  /// el reloj del servidor.
  Future<WildcardBalance?> execute(LogicalDate today) async {
    try {
      return await _wildcards.ensureGranted(today.yearMonth);
    } on WildcardException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
