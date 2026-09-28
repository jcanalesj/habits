import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/finance/0_entity/entity.dart';
import 'package:habits/features/finance/1_domain/domain.dart';
import 'package:habits/features/habits/0_entity/logical_date.dart';
import 'package:habits/firestore_write.dart';

/// Todo lo financiero cuelga de `users/{uid}/finanzas`:
///   config                         ajustes
///   movimientos/items/{id}         gastos e ingresos
///   gastosFijos/items/{id}         compromisos mensuales
///   inversiones/items/{id}         valor manual
///   comprasPendientes/items/{id}   lista de deseos con importe
class FirestoreFinanceRepository implements FinanceRepository {
  FirestoreFinanceRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _db;

  static const collection = 'finanzas';
  static const configDoc = 'config';
  static const movementsDoc = 'movimientos';
  static const fixedDoc = 'gastosFijos';
  static const investmentsDoc = 'inversiones';
  static const pendingDoc = 'comprasPendientes';
  static const itemsCollection = 'items';

  CollectionReference<Map<String, dynamic>> get _root =>
      _db.collection('users').doc(userId).collection(collection);
  DocumentReference<Map<String, dynamic>> get _config => _root.doc(configDoc);
  CollectionReference<Map<String, dynamic>> _items(String group) =>
      _root.doc(group).collection(itemsCollection);

  static FieldValue get _now => FieldValue.serverTimestamp();

  // ------------------------------------------------------------- config

  @override
  Stream<FinanceConfig> watchConfig() =>
      _config.snapshots().map((snapshot) => configFromData(snapshot.data()));

  static FinanceConfig configFromData(Map<String, dynamic>? data) {
    if (data == null) return const FinanceConfig();
    final config = FinanceConfig(
      currency: data['moneda'] as String? ?? 'EUR',
      monthStartDay: (data['diaInicioMes'] as num?)?.toInt() ?? 1,
    );
    return config.isValid ? config : const FinanceConfig();
  }

  @override
  Future<void> saveConfig(FinanceConfig config) => awaitWrite(
    _config.set({
      'moneda': config.currency,
      'diaInicioMes': config.monthStartDay,
      'updatedAt': _now,
    }),
  );

  // -------------------------------------------------------- movimientos

  @override
  Stream<List<Movement>> watchMovementsBetween(
    LogicalDate from,
    LogicalDate to,
  ) => _items(movementsDoc)
      .where('fecha', isGreaterThanOrEqualTo: from.key)
      .where('fecha', isLessThanOrEqualTo: to.key)
      .snapshots()
      .map((snapshot) {
        final movements = <Movement>[
          for (final document in snapshot.docs)
            ?movementFromData(document.id, document.data()),
        ];
        movements.sort((a, b) => b.date.compareTo(a.date));
        return movements;
      });

  static Movement? movementFromData(String id, Map<String, dynamic> data) {
    final date = LogicalDate.tryParse(data['fecha'] as String?);
    final amount = (data['importeCents'] as num?)?.toInt();
    final concept = data['concepto'];
    if (date == null || amount == null || concept is! String) return null;
    return Movement(
      id: id,
      kind: data['tipo'] == 'ingreso'
          ? MovementKind.income
          : MovementKind.expense,
      amountCents: amount,
      concept: concept,
      category: FinanceCategory.parse(data['categoria'] as String?),
      date: date,
      note: data['nota'] as String?,
      fixedCostId: data['gastoFijoId'] as String?,
      investmentId: data['inversionId'] as String?,
      pendingPurchaseId: data['compraPendienteId'] as String?,
    );
  }

  static Map<String, dynamic> _movementData(MovementDraft draft) => {
    'tipo': draft.kind == MovementKind.income ? 'ingreso' : 'gasto',
    'importeCents': draft.amountCents,
    'concepto': draft.concept.trim(),
    'categoria': draft.category.name,
    'fecha': draft.date.key,
    'nota': (draft.note?.trim().isEmpty ?? true) ? null : draft.note!.trim(),
    'gastoFijoId': draft.fixedCostId,
    'inversionId': draft.investmentId,
    'compraPendienteId': draft.pendingPurchaseId,
  };

  Map<String, dynamic> _newMovementData(MovementDraft draft) => {
    ..._movementData(draft),
    'createdAt': _now,
    'updatedAt': _now,
  };

  @override
  Future<String> addMovement(MovementDraft draft) async {
    final reference = _items(movementsDoc).doc();
    await awaitWrite(reference.set(_newMovementData(draft)));
    return reference.id;
  }

  @override
  Future<void> updateMovement(String id, MovementDraft draft) => awaitWrite(
    _items(
      movementsDoc,
    ).doc(id).update({..._movementData(draft), 'updatedAt': _now}),
  );

  @override
  Future<void> deleteMovement(String id) =>
      awaitWrite(_items(movementsDoc).doc(id).delete());

  // -------------------------------------------------------- gastos fijos

  @override
  Stream<List<FixedCost>> watchFixedCosts() =>
      _items(fixedDoc).snapshots().map((snapshot) {
        final costs = <FixedCost>[
          for (final document in snapshot.docs)
            ?fixedCostFromData(document.id, document.data()),
        ];
        costs.sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth));
        return costs;
      });

  static FixedCost? fixedCostFromData(String id, Map<String, dynamic> data) {
    final name = data['nombre'];
    final amount = (data['importeCents'] as num?)?.toInt();
    final day = (data['diaDelMes'] as num?)?.toInt();
    if (name is! String || amount == null || day == null) return null;
    return FixedCost(
      id: id,
      name: name,
      amountCents: amount,
      dayOfMonth: day,
      category: FinanceCategory.parse(data['categoria'] as String?),
      active: data['activo'] as bool? ?? true,
      loggedMonths: {
        for (final month in (data['registradoMeses'] as List?) ?? const [])
          if (month is String) month,
      },
    );
  }

  static Map<String, dynamic> _fixedData(FixedCostDraft draft) => {
    'nombre': draft.name.trim(),
    'importeCents': draft.amountCents,
    'diaDelMes': draft.dayOfMonth,
    'categoria': draft.category.name,
    'activo': draft.active,
  };

  @override
  Future<String> addFixedCost(FixedCostDraft draft) async {
    final reference = _items(fixedDoc).doc();
    await awaitWrite(
      reference.set({
        ..._fixedData(draft),
        'registradoMeses': <String>[],
        'createdAt': _now,
        'updatedAt': _now,
      }),
    );
    return reference.id;
  }

  @override
  Future<void> updateFixedCost(String id, FixedCostDraft draft) => awaitWrite(
    _items(fixedDoc).doc(id).update({..._fixedData(draft), 'updatedAt': _now}),
  );

  @override
  Future<void> deleteFixedCost(String id) =>
      awaitWrite(_items(fixedDoc).doc(id).delete());

  @override
  Future<void> logFixedCost(
    FixedCost cost, {
    required String monthKey,
    required LogicalDate date,
  }) {
    final batch = _db.batch()
      ..set(
        _items(movementsDoc).doc(),
        _newMovementData(
          MovementDraft(
            kind: MovementKind.expense,
            amountCents: cost.amountCents,
            concept: cost.name,
            category: cost.category,
            date: date,
            fixedCostId: cost.id,
          ),
        ),
      )
      ..update(_items(fixedDoc).doc(cost.id), {
        'registradoMeses': FieldValue.arrayUnion([monthKey]),
        'updatedAt': _now,
      });
    return awaitWrite(batch.commit());
  }

  // ---------------------------------------------------------- inversiones

  @override
  Stream<List<Investment>> watchInvestments() =>
      _items(investmentsDoc).snapshots().map((snapshot) {
        final investments = <Investment>[
          for (final document in snapshot.docs)
            ?investmentFromData(document.id, document.data()),
        ];
        investments.sort(
          (a, b) => b.currentValueCents.compareTo(a.currentValueCents),
        );
        return investments;
      });

  static Investment? investmentFromData(String id, Map<String, dynamic> data) {
    final name = data['nombre'];
    final contributed = (data['aportadoCents'] as num?)?.toInt();
    final value = (data['valorActualCents'] as num?)?.toInt();
    if (name is! String || contributed == null || value == null) return null;
    return Investment(
      id: id,
      name: name,
      type: InvestmentType.parse(data['tipo'] as String?),
      contributedCents: contributed,
      currentValueCents: value,
      valueUpdatedAt: (data['valorActualizadoEn'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> _investmentData(InvestmentDraft draft) => {
    'nombre': draft.name.trim(),
    'tipo': draft.type.name,
    'aportadoCents': draft.contributedCents,
    'valorActualCents': draft.currentValueCents,
  };

  @override
  Future<String> addInvestment(InvestmentDraft draft) async {
    final reference = _items(investmentsDoc).doc();
    await awaitWrite(
      reference.set({
        ..._investmentData(draft),
        'valorActualizadoEn': _now,
        'createdAt': _now,
        'updatedAt': _now,
      }),
    );
    return reference.id;
  }

  @override
  Future<void> updateInvestment(String id, InvestmentDraft draft) => awaitWrite(
    _items(investmentsDoc).doc(id).update({
      ..._investmentData(draft),
      'valorActualizadoEn': _now,
      'updatedAt': _now,
    }),
  );

  @override
  Future<void> deleteInvestment(String id) =>
      awaitWrite(_items(investmentsDoc).doc(id).delete());

  @override
  Future<void> updateInvestmentValue(String id, int currentValueCents) =>
      awaitWrite(
        _items(investmentsDoc).doc(id).update({
          'valorActualCents': currentValueCents,
          'valorActualizadoEn': _now,
          'updatedAt': _now,
        }),
      );

  @override
  Future<void> contributeToInvestment(
    Investment investment,
    int cents, {
    LogicalDate? movementDate,
  }) {
    final batch = _db.batch()
      ..update(_items(investmentsDoc).doc(investment.id), {
        'aportadoCents': investment.contributedCents + cents,
        'valorActualCents': investment.currentValueCents + cents,
        'valorActualizadoEn': _now,
        'updatedAt': _now,
      });
    if (movementDate != null) {
      batch.set(
        _items(movementsDoc).doc(),
        _newMovementData(
          MovementDraft(
            kind: MovementKind.expense,
            amountCents: cents,
            concept: investment.name,
            category: FinanceCategory.investment,
            date: movementDate,
            investmentId: investment.id,
          ),
        ),
      );
    }
    return awaitWrite(batch.commit());
  }

  // ---------------------------------------------------- compras pendientes

  @override
  Stream<List<PendingPurchase>> watchPendingPurchases() =>
      _items(pendingDoc).snapshots().map((snapshot) {
        final purchases = <PendingPurchase>[
          for (final document in snapshot.docs)
            ?purchaseFromData(document.id, document.data()),
        ];
        purchases.sort(comparePendingPurchases);
        return purchases;
      });

  static PendingPurchase? purchaseFromData(
    String id,
    Map<String, dynamic> data,
  ) {
    final name = data['nombre'];
    final estimated = (data['importeEstimadoCents'] as num?)?.toInt();
    if (name is! String || estimated == null) return null;
    return PendingPurchase(
      id: id,
      name: name,
      estimatedCents: estimated,
      priority: PurchasePriority.parse(data['prioridad'] as String?),
      targetDate: LogicalDate.tryParse(data['fechaObjetivo'] as String?),
      boughtAt: (data['compradaEn'] as Timestamp?)?.toDate(),
      movementId: data['movimientoId'] as String?,
    );
  }

  static Map<String, dynamic> _purchaseData(PendingPurchaseDraft draft) => {
    'nombre': draft.name.trim(),
    'importeEstimadoCents': draft.estimatedCents,
    'prioridad': draft.priority.name,
    'fechaObjetivo': draft.targetDate?.key,
  };

  @override
  Future<String> addPendingPurchase(PendingPurchaseDraft draft) async {
    final reference = _items(pendingDoc).doc();
    await awaitWrite(
      reference.set({
        ..._purchaseData(draft),
        'compradaEn': null,
        'movimientoId': null,
        'createdAt': _now,
        'updatedAt': _now,
      }),
    );
    return reference.id;
  }

  @override
  Future<void> updatePendingPurchase(String id, PendingPurchaseDraft draft) =>
      awaitWrite(
        _items(
          pendingDoc,
        ).doc(id).update({..._purchaseData(draft), 'updatedAt': _now}),
      );

  @override
  Future<void> deletePendingPurchase(String id) =>
      awaitWrite(_items(pendingDoc).doc(id).delete());

  @override
  Future<void> markPurchased(
    PendingPurchase purchase, {
    required int amountCents,
    required LogicalDate date,
  }) {
    final movement = _items(movementsDoc).doc();
    final batch = _db.batch()
      ..set(
        movement,
        _newMovementData(
          MovementDraft(
            kind: MovementKind.expense,
            amountCents: amountCents,
            concept: purchase.name,
            category: FinanceCategory.other,
            date: date,
            pendingPurchaseId: purchase.id,
          ),
        ),
      )
      ..update(_items(pendingDoc).doc(purchase.id), {
        'compradaEn': _now,
        'movimientoId': movement.id,
        'updatedAt': _now,
      });
    return awaitWrite(batch.commit());
  }
}
