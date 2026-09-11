import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/wildcards_repository.dart';
import 'package:habits/features/habits/1_domain/services/wildcard_policy.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';
import 'package:habits/features/habits/3_data/dtos/wildcard_balance_dto.dart';
import 'package:habits/features/habits/3_data/mappers/habits_mappers.dart';

/// [WildcardsRepository] sobre Firestore.
///
/// A diferencia del repositorio de hábitos, este SÍ usa transacciones, y es
/// una decisión deliberada (§25/§39):
///
///  - conceder y consumir un comodín deben ser atómicos y no admiten
///    reintentos ciegos ni escrituras locales optimistas;
///  - las transacciones de Firestore no funcionan sin red y fallan rápido,
///    que es exactamente el comportamiento que queremos para un entitlement:
///    preferimos no dejar gastar un comodín sin conexión a permitir una
///    escritura que el servidor revierta después en silencio;
///  - la concurrencia optimista de la transacción resuelve el doble tap y
///    los dos dispositivos a la vez: la segunda ejecución relee el saldo ya
///    decrementado y el `create` del día protegido falla porque ya existe.
class FirestoreWildcardsRepository implements WildcardsRepository {
  FirestoreWildcardsRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _user =>
      _db.collection(FirestoreFields.users).doc(userId);

  DocumentReference<Map<String, dynamic>> get _saldo => _user
      .collection(FirestoreFields.comodines)
      .doc(FirestoreFields.saldoDoc);

  CollectionReference<Map<String, dynamic>> get _diasProtegidos =>
      _user.collection(FirestoreFields.diasProtegidos);

  // ---------------------------------------------------------------- lecturas

  @override
  Stream<WildcardBalance?> watchBalance() => _guardStream(
    _saldo.snapshots().map(
      (snapshot) => snapshot.exists
          ? HabitsMappers.wildcardBalanceFromDto(
              WildcardBalanceDto.fromSnapshot(snapshot),
            )
          : null,
    ),
  );

  @override
  Future<WildcardBalance?> fetchBalance() => _guard(() async {
    final snapshot = await _saldo.get();
    if (!snapshot.exists) return null;
    return HabitsMappers.wildcardBalanceFromDto(
      WildcardBalanceDto.fromSnapshot(snapshot),
    );
  });

  @override
  Stream<Set<LogicalDate>> watchProtectedDays() => _guardStream(
    _diasProtegidos
        .orderBy(FirestoreFields.dia)
        .snapshots()
        .map(_daysOf),
  );

  @override
  Future<Set<LogicalDate>> fetchProtectedDays() => _guard(() async {
    final snapshot = await _diasProtegidos.orderBy(FirestoreFields.dia).get();
    return _daysOf(snapshot);
  });

  static Set<LogicalDate> _daysOf(QuerySnapshot<Map<String, dynamic>> snap) => {
    for (final doc in snap.docs)
      ?LogicalDate.tryParse(ProtectedDayDto.fromSnapshot(doc).dia),
  };

  // -------------------------------------------------------------- escrituras

  /// Crea el saldo inicial o aplica las concesiones mensuales pendientes.
  ///
  /// Idempotente: la aritmética la decide [WildcardPolicy] y las Security
  /// Rules la revalidan, de modo que repetir la llamada el mismo mes no
  /// concede nada aunque el cliente insista.
  @override
  Future<WildcardBalance> ensureGranted(int currentYearMonth) =>
      _guard(() async {
        return _db.runTransaction((transaction) async {
          final snapshot = await transaction.get(_saldo);

          if (!snapshot.exists) {
            final initial = WildcardPolicy.initial(currentYearMonth);
            transaction.set(_saldo, {
              FirestoreFields.saldo: initial.available,
              FirestoreFields.ultimaConcesionYM: initial.lastGrantYearMonth,
              FirestoreFields.concedidosTotal: initial.grantedTotal,
              FirestoreFields.ultimoDiaProtegido: null,
              FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
            });
            return initial;
          }

          final current = HabitsMappers.wildcardBalanceFromDto(
            WildcardBalanceDto.fromSnapshot(snapshot),
          );
          final granted = WildcardPolicy.applyMonthlyGrants(
            current,
            currentYearMonth,
          );
          if (granted == current) return current;

          transaction.update(_saldo, {
            FirestoreFields.saldo: granted.available,
            FirestoreFields.ultimaConcesionYM: granted.lastGrantYearMonth,
            FirestoreFields.concedidosTotal: granted.grantedTotal,
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          });
          return granted;
        });
      });

  /// Consume un comodín y protege [day] en una sola transacción.
  ///
  /// Las dos escrituras viajan juntas y las Security Rules las atan en
  /// ambas direcciones con `getAfter()`: no se puede crear el día protegido
  /// sin decrementar el saldo, ni decrementar el saldo sin crear el día.
  @override
  Future<void> consumeForDay(LogicalDate day) => _guard(() async {
    await _db.runTransaction((transaction) async {
      final dayRef = _diasProtegidos.doc(day.key);
      final saldoSnapshot = await transaction.get(_saldo);
      final daySnapshot = await transaction.get(dayRef);

      if (daySnapshot.exists) {
        throw const WildcardException(WildcardFailure.dayAlreadyProtected);
      }
      if (!saldoSnapshot.exists) {
        throw const WildcardException(WildcardFailure.noneAvailable);
      }

      final balance = HabitsMappers.wildcardBalanceFromDto(
        WildcardBalanceDto.fromSnapshot(saldoSnapshot),
      );
      if (!balance.hasAny) {
        throw const WildcardException(WildcardFailure.noneAvailable);
      }

      transaction.set(dayRef, {
        FirestoreFields.dia: day.key,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      });
      transaction.update(_saldo, {
        FirestoreFields.saldo: balance.available - 1,
        FirestoreFields.ultimoDiaProtegido: day.key,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    });
  });

  // ---------------------------------------------------------------- helpers

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on WildcardException {
      rethrow;
    } on FirebaseException catch (e) {
      throw _toDomain(e);
    }
  }

  Stream<T> _guardStream<T>(Stream<T> stream) => stream.handleError(
    (Object error) => throw _toDomain(error as FirebaseException),
    test: (error) => error is FirebaseException,
  );

  static WildcardException _toDomain(FirebaseException e) {
    final failure = switch (e.code) {
      'permission-denied' => WildcardFailure.permissionDenied,
      // Sin red la transacción no llega a ejecutarse: es el comportamiento
      // buscado para un entitlement, no un error que haya que disimular.
      'unavailable' || 'deadline-exceeded' || 'aborted' =>
        WildcardFailure.requiresConnection,
      _ => WildcardFailure.unknown,
    };
    return WildcardException(failure, message: e.message);
  }
}
