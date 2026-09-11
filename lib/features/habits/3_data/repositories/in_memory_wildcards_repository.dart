import 'dart:async';

import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/wildcards_repository.dart';
import 'package:habits/features/habits/1_domain/services/wildcard_policy.dart';

/// [WildcardsRepository] en memoria con el mismo comportamiento observable
/// que Firestore: concesión idempotente, consumo atómico, tope de saldo y
/// negativa a proteger dos veces el mismo día.
class InMemoryWildcardsRepository implements WildcardsRepository {
  InMemoryWildcardsRepository({
    WildcardBalance? balance,
    Set<LogicalDate>? protectedDays,
  }) : _balance = balance,
       _protectedDays = {...?protectedDays};

  WildcardBalance? _balance;
  final Set<LogicalDate> _protectedDays;

  /// Simula la falta de conectividad: los comodines exigen red.
  bool offline = false;

  final _balanceController = StreamController<WildcardBalance?>.broadcast();
  final _protectedController = StreamController<Set<LogicalDate>>.broadcast();

  @override
  Stream<WildcardBalance?> watchBalance() async* {
    yield _balance;
    yield* _balanceController.stream;
  }

  @override
  Future<WildcardBalance?> fetchBalance() async => _balance;

  @override
  Stream<Set<LogicalDate>> watchProtectedDays() async* {
    yield {..._protectedDays};
    yield* _protectedController.stream;
  }

  @override
  Future<Set<LogicalDate>> fetchProtectedDays() async => {..._protectedDays};

  @override
  Future<WildcardBalance> ensureGranted(int currentYearMonth) async {
    _requireConnection();
    final current = _balance;
    final next = current == null
        ? WildcardPolicy.initial(currentYearMonth)
        : WildcardPolicy.applyMonthlyGrants(current, currentYearMonth);
    if (next != current) _emitBalance(next);
    return next;
  }

  @override
  Future<void> consumeForDay(LogicalDate day) async {
    _requireConnection();
    if (_protectedDays.contains(day)) {
      throw const WildcardException(WildcardFailure.dayAlreadyProtected);
    }
    final current = _balance;
    if (current == null || !current.hasAny) {
      throw const WildcardException(WildcardFailure.noneAvailable);
    }
    // Atómico: o se aplican las dos mutaciones o ninguna.
    _protectedDays.add(day);
    _emitBalance(
      current.copyWith(
        available: current.available - 1,
        lastProtectedDay: day,
      ),
    );
    _protectedController.add({..._protectedDays});
  }

  void _requireConnection() {
    if (offline) {
      throw const WildcardException(WildcardFailure.requiresConnection);
    }
  }

  void _emitBalance(WildcardBalance balance) {
    _balance = balance;
    _balanceController.add(balance);
  }

  Future<void> dispose() async {
    await _balanceController.close();
    await _protectedController.close();
  }
}
