import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habits/firestore_write.dart';
import 'package:habits/features/habits/0_entity/entity.dart';
import 'package:habits/features/habits/1_domain/exceptions/habits_exception.dart';
import 'package:habits/features/habits/1_domain/repositories/habits_repository.dart';
import 'package:habits/features/habits/3_data/dtos/ambito_dto.dart';
import 'package:habits/features/habits/3_data/dtos/firestore_fields.dart';
import 'package:habits/features/habits/3_data/dtos/habit_dto.dart';
import 'package:habits/features/habits/3_data/dtos/habit_log_dto.dart';
import 'package:habits/features/habits/3_data/dtos/streaks_dto.dart';
import 'package:habits/features/habits/3_data/mappers/habits_mappers.dart';

/// [HabitsRepository] sobre Firestore, scoped a `users/{userId}`.
///
/// Escribe exactamente los campos que aceptan las Security Rules, con marcas
/// de tiempo del servidor. Los datos normales son offline-first: nunca usa
/// transacciones (no funcionan sin red) y cuando necesita atomicidad usa un
/// [WriteBatch], que sí se encola y sincroniza. Los comodines, que son
/// entitlements, viven en [FirestoreWildcardsRepository] y sí usan
/// transacción a propósito.
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
          FirestoreFields.completedCount: dto.completedCount,
          FirestoreFields.targetCount: dto.targetCount,
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
  Stream<List<HabitLog>> watchLogsBetween(LogicalDate from, LogicalDate to) =>
      _guardStream(
        _registros
            .where(FirestoreFields.dia, isGreaterThanOrEqualTo: from.key)
            .where(FirestoreFields.dia, isLessThanOrEqualTo: to.key)
            .orderBy(FirestoreFields.dia)
            .snapshots()
            .map((snapshot) => _mapLogs(snapshot.docs)),
      );

  /// Histórico completo de días con actividad real.
  ///
  /// Se suscribe a TODOS los registros: es lo que exige poder reconstruir la
  /// racha de forma determinista desde la fuente de verdad. Tras la primera
  /// carga, Firestore sirve desde caché local y el listener solo entrega
  /// deltas, así que el coste recurrente es bajo. Si algún día el volumen lo
  /// justifica, el siguiente paso sería un agregado por día; se ha
  /// descartado ahora a propósito para no tener una segunda fuente de verdad.
  @override
  Stream<Set<LogicalDate>> watchActivityDays() => _guardStream(
    _registros
        .orderBy(FirestoreFields.dia)
        .snapshots()
        .map((snapshot) => _activityDaysOf(snapshot.docs)),
  );

  @override
  Future<Set<LogicalDate>> fetchActivityDays() => _guard(() async {
    final snapshot = await _registros.orderBy(FirestoreFields.dia).get();
    return _activityDaysOf(snapshot.docs);
  });

  @override
  Stream<StreakCacheEntry?> watchStreakCache() => _guardStream(
    _rachasRaw.snapshots().map(
      (snapshot) => snapshot.exists
          ? HabitsMappers.streakCacheFromDto(StreaksDto.fromSnapshot(snapshot))
          : null,
    ),
  );

  @override
  Future<StreakCacheEntry?> fetchStreakCache() => _guard(() async {
    final snapshot = await _rachasRaw.get();
    if (!snapshot.exists) return null;
    return HabitsMappers.streakCacheFromDto(StreaksDto.fromSnapshot(snapshot));
  });

  @override
  Future<void> saveStreakCache(StreakCacheEntry entry) => _guard(() async {
    await _rachasRaw.set({
      FirestoreFields.rachaActual: entry.currentStreak,
      FirestoreFields.mejorRacha: entry.bestStreak,
      FirestoreFields.ultimoDiaActividad: entry.lastActivityDay?.key,
      FirestoreFields.calculadoHasta: entry.calculatedThrough.key,
      FirestoreFields.version: entry.algorithmVersion,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    });
  });

  @override
  Future<void> clearStreakCache() => _guard(() async => _rachasRaw.delete());

  @override
  Future<List<HabitLog>> fetchHabitLogs(
    String habitId, {
    LogicalDate? from,
    LogicalDate? to,
  }) => _guard(() async {
    // Índice compuesto (habitoId, dia) desplegado en la fase 2.
    Query<HabitLogDto> query = _registros.where(
      FirestoreFields.habitoId,
      isEqualTo: habitId,
    );
    if (from != null) {
      query = query.where(
        FirestoreFields.dia,
        isGreaterThanOrEqualTo: from.key,
      );
    }
    if (to != null) {
      query = query.where(FirestoreFields.dia, isLessThanOrEqualTo: to.key);
    }
    final snapshot = await query.orderBy(FirestoreFields.dia).get();
    return _mapLogs(snapshot.docs);
  });

  @override
  Future<Habit?> getHabit(String habitId) => _guard(() async {
    final snapshot = await _habitos.doc(habitId).get();
    final dto = snapshot.data();
    return dto == null ? null : HabitsMappers.habitFromDto(dto);
  });

  // ---------------------------------------------------------------- hábitos

  @override
  Future<Habit> createHabit(HabitDraft draft, {required LogicalDate today}) =>
      _guard(() async {
        final ref = _habitosRaw.doc();
        final now = _now();
        final habit = Habit(
          id: ref.id,
          name: draft.name,
          ambitoId: draft.ambitoId,
          periodicityTimeline: [
            PeriodicityEntry(periodicity: draft.periodicity, since: today),
          ],
          colorValue: draft.colorValue,
          emoji: draft.emoji,
          iconId: draft.iconId,
          reminderTime: draft.reminderTime,
          reminderMessage: draft.reminderMessage,
          trackingType: draft.trackingType,
          targetCount: draft.targetCount,
          unit: draft.unit,
          displayGoal: draft.displayGoal,
          progressIconId: draft.progressIconId,
          // Orden monotónico sin consultar: válido offline y sin colisiones.
          order: now.millisecondsSinceEpoch,
          createdAt: now,
        );
        await awaitWrite(
          ref.set({
            ...HabitsMappers.habitToDto(habit).toEditableMap(),
            FirestoreFields.deletedAt: null,
            FirestoreFields.createdAt: FieldValue.serverTimestamp(),
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          }),
        );
        return habit;
      });

  @override
  Future<void> updateHabit(Habit habit) => _guard(() async {
    await awaitWrite(
      _habitosRaw.doc(habit.id).update({
        ...HabitsMappers.habitToDto(habit).toEditableMap(),
        // `deletedAt` NO se envía: borrar tiene su propio método y la copia
        // que se edita puede ser antigua. Enviarla resucitaría un hábito
        // borrado mientras tanto desde otro dispositivo.
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        // Migración perezosa: cada hábito se deshace de los campos del
        // modelo antiguo (descansos, recuperación, historial con el nombre
        // viejo) la primera vez que se edita. Sin migración masiva ni
        // borrado de datos.
        ..._legacyFieldDeletions(),
      }),
    );
  });

  @override
  Future<void> reorderHabits(Map<String, int> orderById) => _guard(() async {
    if (orderById.isEmpty) return;
    // Un solo batch: o se aplica el orden entero o nada, sin dejar dos
    // hábitos con el mismo `orden`.
    final batch = _db.batch();
    orderById.forEach((habitId, order) {
      batch.update(_habitosRaw.doc(habitId), {
        FirestoreFields.orden: order,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    });
    await awaitWrite(batch.commit());
  });

  @override
  Future<void> softDeleteHabit(String habitId) => _guard(() async {
    final ref = _habitosRaw.doc(habitId);
    final data = await _getDocOrNull(ref);
    await awaitWrite(
      ref.update({
        FirestoreFields.deletedAt: FieldValue.serverTimestamp(),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        ..._legacyMigration(data),
      }),
    );
  });

  /// Un update se valida contra el documento COMPLETO resultante, así que un
  /// hábito con el formato anterior a la fase 5 (`periodicidad` como texto,
  /// sin `cambiosPeriodicidad`) no se podría borrar ni mover de ámbito con
  /// una escritura parcial. Estos campos lo dejan en el formato actual.
  static Map<String, dynamic> _legacyMigration(Map<String, dynamic>? data) {
    if (data == null) return const {};
    final isLegacy =
        data[FirestoreFields.periodicidad] is! Map ||
        data[FirestoreFields.cambiosPeriodicidad] is! List ||
        FirestoreFields.legacyHabitFields.any(data.containsKey);
    if (!isLegacy) return const {};
    return {
      FirestoreFields.periodicidad: HabitDto.normalizePeriodicidad(
        data[FirestoreFields.periodicidad],
      ),
      FirestoreFields.cambiosPeriodicidad: HabitDto.readTimeline(data),
      ..._legacyFieldDeletions(),
    };
  }

  static Map<String, dynamic> _legacyFieldDeletions() => {
    for (final field in FirestoreFields.legacyHabitFields)
      field: FieldValue.delete(),
  };

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
    await awaitWrite(
      ref.set({
        ...HabitsMappers.ambitoToDto(ambito).toEditableMap(),
        FirestoreFields.esPredefinido: false,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      }),
    );
    return ambito;
  });

  @override
  Future<void> updateAmbito(Ambito ambito) => _guard(() async {
    await awaitWrite(
      _ambitosRaw.doc(ambito.id).update({
        ...HabitsMappers.ambitoToDto(ambito).toEditableMap(),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      }),
    );
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
        ..._legacyMigration(doc.data()),
      });
    }
    batch.delete(_ambitosRaw.doc(ambitoId));
    await awaitWrite(batch.commit());
  });

  // -------------------------------------------------------------- registros

  @override
  Future<void> setHabitCompletion({
    required String habitId,
    required LogicalDate date,
    required bool completed,
  }) => _guard(() async {
    final ref = _registrosRaw.doc(HabitLogDto.idFor(habitId, date.key));
    final existing = await _getDocOrNull(ref);

    if (!completed) {
      // Desmarcar algo no marcado no hace nada (las reglas rechazarían un
      // delete sobre un documento inexistente).
      if (existing != null) await awaitWrite(ref.delete());
      return;
    }
    if (existing != null) {
      final count = (existing[FirestoreFields.completedCount] as num?) ?? 1;
      final target = (existing[FirestoreFields.targetCount] as num?) ?? 1;
      // Ya marcado: idempotente, sin escritura.
      if (count >= target) return;
      // Progreso parcial de cuando el hábito era de repeticiones y ha pasado
      // a simple a mitad de día: las reglas no dejan actualizarlo (el
      // objetivo histórico es inmutable), así que se sustituye.
      await awaitWrite(ref.delete());
    }

    await awaitWrite(
      ref.set({
        FirestoreFields.habitoId: habitId,
        FirestoreFields.dia: date.key,
        FirestoreFields.tipo: FirestoreFields.tipoCompleted,
        FirestoreFields.completedCount: 1,
        FirestoreFields.targetCount: 1,
        // Se guarda la zona con la que se resolvió el día, para poder auditar
        // cómo se decidió. No se usa para reinterpretar el día después (§13).
        FirestoreFields.tz: _timezone ?? _now().timeZoneName,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      }),
    );
  });

  @override
  Future<void> setHabitDailyCount({
    required String habitId,
    required LogicalDate date,
    required int completedCount,
    required int targetCount,
  }) => _guard(() async {
    final ref = _registrosRaw.doc(HabitLogDto.idFor(habitId, date.key));
    final safeTarget = targetCount.clamp(1, 999);
    final safeCount = completedCount.clamp(0, safeTarget);
    if (safeCount == 0) {
      if (await _getDocOrNull(ref) != null) await awaitWrite(ref.delete());
      return;
    }
    await awaitWrite(
      ref.set({
        FirestoreFields.habitoId: habitId,
        FirestoreFields.dia: date.key,
        FirestoreFields.tipo: FirestoreFields.tipoCompleted,
        FirestoreFields.completedCount: safeCount,
        FirestoreFields.targetCount: safeTarget,
        FirestoreFields.tz: _timezone ?? _now().timeZoneName,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      }),
    );
  });

  // ---------------------------------------------------------------- helpers

  static List<HabitLog> _mapLogs(
    List<QueryDocumentSnapshot<HabitLogDto>> docs,
  ) => [for (final doc in docs) ?HabitsMappers.logFromDto(doc.data())];

  static Set<LogicalDate> _activityDaysOf(
    List<QueryDocumentSnapshot<HabitLogDto>> docs,
  ) => {
    for (final doc in docs)
      if (HabitsMappers.logFromDto(doc.data()) case final log?)
        if (log.isActivity) log.date,
  };

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
