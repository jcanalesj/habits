import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/wildcards_repository.dart';
import 'package:habits/features/habits/1_domain/services/wildcard_policy.dart';

sealed class UseWildcardResult {}

class UseWildcardSuccess extends UseWildcardResult {}

class UseWildcardFailed extends UseWildcardResult {
  UseWildcardFailed(this.failure);

  final WildcardFailure failure;
}

/// Gasta un comodín para proteger el día inmediatamente anterior.
///
/// El comodín nunca se consume solo: el usuario decide usarlo (§24).
/// Protege la racha pero NO crea un registro falso, no marca ningún hábito,
/// no rellena calendarios y no suma un día (§15/§16).
///
/// Las comprobaciones de aquí son de producto y de experiencia de uso. Las
/// garantías duras (atomicidad, saldo ≥ 0, no proteger dos veces el mismo
/// día, no conseguir saldo de la nada) las impone el backend en la
/// transacción y en las Security Rules.
class UseWildcardUsecase {
  const UseWildcardUsecase(this._wildcards);

  final WildcardsRepository _wildcards;

  Future<UseWildcardResult> execute({
    required LogicalDate day,
    required LogicalDate today,
    required Set<LogicalDate> activityDays,
  }) async {
    if (!WildcardPolicy.isWithinRescueWindow(day, today)) {
      return UseWildcardFailed(WildcardFailure.rescueWindowClosed);
    }
    // Proteger un día que sí tuvo actividad gastaría un comodín sin cambiar
    // nada: ese día ya contaba. No es un agujero de seguridad, es un gasto
    // inútil que se evita aquí.
    if (activityDays.contains(day)) {
      return UseWildcardFailed(WildcardFailure.dayHasActivity);
    }

    try {
      final protectedDays = await _wildcards.fetchProtectedDays();
      if (protectedDays.contains(day)) {
        return UseWildcardFailed(WildcardFailure.dayAlreadyProtected);
      }
      final balance = await _wildcards.fetchBalance();
      if (balance == null || !balance.hasAny) {
        return UseWildcardFailed(WildcardFailure.noneAvailable);
      }

      await _wildcards.consumeForDay(day);
      return UseWildcardSuccess();
    } on WildcardException catch (e) {
      return UseWildcardFailed(e.failure);
    } catch (_) {
      return UseWildcardFailed(WildcardFailure.unknown);
    }
  }
}
