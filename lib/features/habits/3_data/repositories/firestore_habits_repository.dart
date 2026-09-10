import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/1_domain/services/logical_day.dart';
import 'package:habits/features/habits/3_data/dtos/ambito_dto.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';
import 'package:habits/features/habits/3_data/dtos/habit_dto.dart';
import 'package:habits/features/habits/3_data/dtos/habit_log_dto.dart';
import 'package:habits/features/habits/3_data/dtos/streaks_dto.dart';
import 'package:habits/features/habits/3_data/mappers/habits_mappers.dart';

/// [HabitsRepository] sobre Firestore, scoped a `users/{userId}`.
///
/// Escribe exactamente los campos que aceptan las Security Rules, con marcas
/// de tiempo del servidor. Nunca usa transacciones (no funcionan offline);
/// cuando una operación necesita varias escrituras atómicas usa un
/// [WriteBatch], que sí se encola y sincroniza sin red.
class FirestoreHabitsRepository implements HabitsRepository {
  FirestoreHabitsRepository({
    required this.userId,
    FirebaseFirestore? firestore,
    String? timezone,
    DateTime Function()? now,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _timezone = timezone,
       _now = now ?? DateTime.now;

  /// Id usado cuando no hay sesión: cualquier acceso lo rechazan las reglas.
  static const anonymousUserId = '_anonymous';

  final String userId;
  final FirebaseFirestore _db;
  final String? _timezone;
  final DateTime Function() _now;

  // ------------------------------------------------------------ referencias

  DocumentReference<Map<String, dynamic>> get _user =>
      _db.collection(FirestoreFields.users).doc(userId);

  CollectionReference<Map<String, dynamic>> get _habitosRaw =>
      _user.collection(FirestoreFields.habitos);

  CollectionReference<Map<String, dynamic>> get _ambitosRaw =>
      _user.collection(FirestoreFields.ambitos);

  CollectionReference<Map<String, dynamic>> get _registrosRaw =>
      _user.collection(FirestoreFields.registros);

  DocumentReference<Map<String, dynamic>> get _rachasRaw =>
      _user.collection(FirestoreFields.cache).doc(FirestoreFields.rachasDoc);

  /// Colecciones tipadas para lectura: el DTO se construye en el converter.
  CollectionReference<HabitDto> get _habitos => _habitosRaw.withConverter(
    fromFirestore: (snapshot, _) => HabitDto.fromSnapshot(snapshot),
    toFirestore: (dto, _) => dto.toEditableMap(),
  );

  CollectionReference<AmbitoDto> get _ambitos => _ambitosRaw.withConverter(
    fromFirestore: (snapshot, _) => AmbitoDto.fromSnapshot(snapshot),
    toFirestore: (dto, _) => dto.toEditableMap(),
  );

  CollectionReference<HabitLogDto> get _registros =>
      _registrosRaw.withConverter(
        fromFirestore: (snapshot, _) => HabitLogDto.fromSnapshot(snapshot),
        toFirestore: (dto, _) => {
          FirestoreFields.habitoId: dto.habitoId,
          FirestoreFields.dia: dto.dia,
          FirestoreFields.tipo: dto.tipo,
        },
      );

  // ---------------------------------------------------------------- lecturas

  @override
  Stream<List<Ambito>> watchAmbitos() => _guardStream(
    _ambitos
        .orderBy(FirestoreFields.orden)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HabitsMappers.ambitoFromDto(doc.data()))
              .toList(growable: false),
        ),
  );

  @override
  Stream<List<Habit>> watchActiveHabits() => _guardStream(
    _habitos
        // Índice compuesto (deletedAt, orden) desplegado en la fase 2.
        .where(FirestoreFields.deletedAt, isNull: true)
        .orderBy(FirestoreFields.orden)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HabitsMappers.habitFromDto(doc.data()))
              .toList(growable: false),
        ),
  );

  @override
  Stream<List<HabitLog>> watchLogsBetween(DateTime from, DateTime to) =>
      _guardStream(
        _registros
            .where(
              FirestoreFields.dia,
              isGreaterThanOrEqualTo: LogicalDay.format(from),
            )
            .where(
              FirestoreFields.dia,
              isLessThanOrEqualTo: LogicalDay.format(to),
            )
            .orderBy(FirestoreFields.dia)
            .snapshots()
            .map(
              (snapshot) => snapshot.docs
                  .map((doc) => HabitsMappers.logFromDto(doc.data()))
                  .toList(growable: false),
            ),
      );

  @override
  Stream<StreaksSnapshot> watchStreaks() => _guardStream(
    _rachasRaw.snapshots().map(
      (snapshot) => snapshot.exists
          ? HabitsMappers.streaksFromDto(StreaksDto.fromSnapshot(snapshot))
          : StreaksSnapshot.empty,
    ),
  );

  @override
  Future<List<HabitLog>> fetchHabitLogs(
    String habitId, {
    DateTime? from,
    DateTime? to,
  }) => _guard(() async {
    // Índice compuesto (habitoId, dia) desplegado en la fase 2.
    Query<HabitLogDto> query = _registros.where(
      FirestoreFields.habitoId,
      isEqualTo: habitId,
    );
    if (from != null) {
      query = query.where(
        FirestoreFields.dia,
        isGreaterThanOrEqualTo: LogicalDay.format(from),
      );
    }
    if (to != null) {
      query = query.where(
        FirestoreFields.dia,
        isLessThanOrEqualTo: LogicalDay.format(to),
      );
    }
    final snapshot = await query.orderBy(FirestoreFields.dia).get();
    return snapshot.docs
        .map((doc) => HabitsMappers.logFromDto(doc.data()))
        .toList(growable: false);
  });

  @override
  Future<Habit?> getHabit(String habitId) => _guard(() async {
    final snapshot = await _habitos.doc(habitId).get();
    final dto = snapshot.data();
    return dto == null ? null : HabitsMappers.habitFromDto(dto);
  });

  // ---------------------------------------------------------------- hábitos

  @override
  Future<Habit> createHabit(HabitDraft draft) => _guard(() async {
    final ref = _habitosRaw.doc();
    final now = _now();
    final habit = Habit(
      id: ref.id,
      name: draft.name,
      ambitoId: draft.ambitoId,
      periodicity: draft.periodicity,
      restDaysAllowed: draft.restDaysAllowed,
      recoveryTask: draft.recoveryTask,
      recoveryCooldownDays: draft.recoveryCooldownDays,
      colorValue: draft.colorValue,
      emoji: draft.emoji,
      reminderTime: draft.reminderTime,
      // Orden monotónico sin consultar: válido offline y sin colisiones.
      order: now.millisecondsSinceEpoch,
      createdAt: now,
    );
    await ref.set({
      ...HabitsMappers.habitToDto(habit).toEditableMap(),
      FirestoreFields.deletedAt: null,
      FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    });
    return habit;
  });

  @override
  Future<void> updateHabit(Habit habit) => _guard(() async {
    await _habitosRaw.doc(habit.id).update({
      ...HabitsMappers.habitToDto(habit).toEditableMap(),
      FirestoreFields.deletedAt: habit.deletedAt == null
          ? null
          : Timestamp.fromDate(habit.deletedAt!),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    });
  });

  @override
  Future<void> softDeleteHabit(String habitId) => _guard(() async {
    await _habitosRaw.doc(habitId).update({
      FirestoreFields.deletedAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    });
  });

  // ---------------------------------------------------------------- ámbitos

  @override
  Future<Ambito> createAmbito(AmbitoDraft draft) => _guard(() async {
    final ref = _ambitosRaw.doc();
    final now = _now();
    final ambito = Ambito(
      id: ref.id,
      name: draft.name,
      emoji: draft.emoji,
      colorValue: draft.colorValue,
      isPredefined: false,
      order: now.millisecondsSinceEpoch,
      createdAt: now,
    );
    await ref.set({
      ...HabitsMappers.ambitoToDto(ambito).toEditableMap(),
      FirestoreFields.esPredefinido: false,
      FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    });
    return ambito;
  });

  @override
  Future<void> updateAmbito(Ambito ambito) => _guard(() async {
    await _ambitosRaw.doc(ambito.id).update({
      ...HabitsMappers.ambitoToDto(ambito).toEditableMap(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    });
  });

  @override
  Future<void> deleteAmbito(String ambitoId) => _guard(() async {
    if (ambitoId == Ambito.generalId) {
      throw const HabitsException(HabitsFailure.generalAmbitoProtected);
    }
    // Todos los hábitos del ámbito (activos y eliminados) pasan a General
    // para no dejar referencias colgando; los registros no se tocan.
    final habits = await _getWithCacheFallback(
      _habitosRaw.where(FirestoreFields.ambitoId, isEqualTo: ambitoId),
    );
    final batch = _db.batch();
    for (final doc in habits.docs) {
      batch.update(doc.reference, {
        FirestoreFields.ambitoId: Ambito.generalId,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }
    batch.delete(_ambitosRaw.doc(ambitoId));
    await batch.commit();
  });

  // -------------------------------------------------------------- registros

  @override
  Future<void> setHabitCompletion({
    required String habitId,
    required DateTime date,
    required bool completed,
    HabitLogType type = HabitLogType.completed,
  }) => _guard(() async {
    final dia = LogicalDay.format(LogicalDay.of(date));
    final ref = _registrosRaw.doc(HabitLogDto.idFor(habitId, dia));
    final existing = await _getDocOrNull(ref);

    if (!completed) {
      // Desmarcar algo no marcado no hace nada (las reglas rechazarían un
      // delete sobre un documento inexistente).
      if (existing != null) await ref.delete();
      return;
    }

    if (existing == null) {
      await ref.set({
        FirestoreFields.habitoId: habitId,
        FirestoreFields.dia: dia,
        FirestoreFields.tipo: type.name,
        FirestoreFields.tz: _timezone ?? _now().timeZoneName,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      });
    } else if (existing[FirestoreFields.tipo] != type.name) {
      // Solo cambia el tipo; createdAt es inmutable para las reglas.
      await ref.update({
        FirestoreFields.tipo: type.name,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }
    // Ya marcado con el mismo tipo: idempotente, sin escritura.
  });

  // ---------------------------------------------------------------- helpers

  /// Datos del documento o null si no existe. Sin red usa la caché local;
  /// si tampoco está en caché se asume que no existe.
  Future<Map<String, dynamic>?> _getDocOrNull(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await ref.get();
    } on FirebaseException {
      try {
        snapshot = await ref.get(const GetOptions(source: Source.cache));
      } on FirebaseException {
        return null;
      }
    }
    return snapshot.exists ? snapshot.data() : null;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getWithCacheFallback(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      return await query.get();
    } on FirebaseException {
      return query.get(const GetOptions(source: Source.cache));
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      throw _toDomain(e);
    }
  }

  Stream<T> _guardStream<T>(Stream<T> stream) => stream.handleError(
    (Object error) => throw _toDomain(error as FirebaseException),
    test: (error) => error is FirebaseException,
  );

  static HabitsException _toDomain(FirebaseException e) {
    final failure = switch (e.code) {
      'permission-denied' => HabitsFailure.permissionDenied,
      'unavailable' || 'deadline-exceeded' => HabitsFailure.network,
      'not-found' => HabitsFailure.habitNotFound,
      _ => HabitsFailure.unknown,
    };
    return HabitsException(failure, message: e.message);
  }
}
