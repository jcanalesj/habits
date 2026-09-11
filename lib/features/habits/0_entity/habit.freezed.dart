// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Habit {

 String get id; String get name;/// Un hábito pertenece a un único ámbito. Los ámbitos organizan, pero
/// no tienen racha propia (§29).
 String get ambitoId;/// Línea temporal de objetivos, ordenada por `since` ascendente. La
/// primera entrada es la configuración inicial; las entradas con
/// `since` futura son cambios ya decididos pero todavía no vigentes.
///
/// Es la fuente de verdad de la periodicidad: no hay campo "actual"
/// denormalizado que pueda quedarse obsoleto (§10/§11), y conserva qué
/// objetivo había en cada fecha para las estadísticas y el futuro
/// sistema de rangos (§7).
 List<PeriodicityEntry> get periodicityTimeline;/// Color asignado de la paleta al crear el hábito, editable.
 int get colorValue; String get emoji;/// Hora fija de recordatorio en formato "HH:mm" (v1), opcional.
 String? get reminderTime;/// Posición en las listas.
 int get order; DateTime get createdAt;/// Soft delete: los hábitos borrados conservan su histórico de registros
/// y no aparecen en las consultas normales (§30).
 DateTime? get deletedAt;
/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitCopyWith<Habit> get copyWith => _$HabitCopyWithImpl<Habit>(this as Habit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ambitoId, ambitoId) || other.ambitoId == ambitoId)&&const DeepCollectionEquality().equals(other.periodicityTimeline, periodicityTimeline)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,ambitoId,const DeepCollectionEquality().hash(periodicityTimeline),colorValue,emoji,reminderTime,order,createdAt,deletedAt);

@override
String toString() {
  return 'Habit(id: $id, name: $name, ambitoId: $ambitoId, periodicityTimeline: $periodicityTimeline, colorValue: $colorValue, emoji: $emoji, reminderTime: $reminderTime, order: $order, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $HabitCopyWith<$Res>  {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) _then) = _$HabitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ambitoId, List<PeriodicityEntry> periodicityTimeline, int colorValue, String emoji, String? reminderTime, int order, DateTime createdAt, DateTime? deletedAt
});




}
/// @nodoc
class _$HabitCopyWithImpl<$Res>
    implements $HabitCopyWith<$Res> {
  _$HabitCopyWithImpl(this._self, this._then);

  final Habit _self;
  final $Res Function(Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ambitoId = null,Object? periodicityTimeline = null,Object? colorValue = null,Object? emoji = null,Object? reminderTime = freezed,Object? order = null,Object? createdAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ambitoId: null == ambitoId ? _self.ambitoId : ambitoId // ignore: cast_nullable_to_non_nullable
as String,periodicityTimeline: null == periodicityTimeline ? _self.periodicityTimeline : periodicityTimeline // ignore: cast_nullable_to_non_nullable
as List<PeriodicityEntry>,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,reminderTime: freezed == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Habit].
extension HabitPatterns on Habit {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Habit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Habit value)  $default,){
final _that = this;
switch (_that) {
case _Habit():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Habit value)?  $default,){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ambitoId,  List<PeriodicityEntry> periodicityTimeline,  int colorValue,  String emoji,  String? reminderTime,  int order,  DateTime createdAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.name,_that.ambitoId,_that.periodicityTimeline,_that.colorValue,_that.emoji,_that.reminderTime,_that.order,_that.createdAt,_that.deletedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ambitoId,  List<PeriodicityEntry> periodicityTimeline,  int colorValue,  String emoji,  String? reminderTime,  int order,  DateTime createdAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Habit():
return $default(_that.id,_that.name,_that.ambitoId,_that.periodicityTimeline,_that.colorValue,_that.emoji,_that.reminderTime,_that.order,_that.createdAt,_that.deletedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ambitoId,  List<PeriodicityEntry> periodicityTimeline,  int colorValue,  String emoji,  String? reminderTime,  int order,  DateTime createdAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.name,_that.ambitoId,_that.periodicityTimeline,_that.colorValue,_that.emoji,_that.reminderTime,_that.order,_that.createdAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Habit extends Habit {
  const _Habit({required this.id, required this.name, required this.ambitoId, required final  List<PeriodicityEntry> periodicityTimeline, required this.colorValue, required this.emoji, this.reminderTime, this.order = 0, required this.createdAt, this.deletedAt}): _periodicityTimeline = periodicityTimeline,super._();
  

@override final  String id;
@override final  String name;
/// Un hábito pertenece a un único ámbito. Los ámbitos organizan, pero
/// no tienen racha propia (§29).
@override final  String ambitoId;
/// Línea temporal de objetivos, ordenada por `since` ascendente. La
/// primera entrada es la configuración inicial; las entradas con
/// `since` futura son cambios ya decididos pero todavía no vigentes.
///
/// Es la fuente de verdad de la periodicidad: no hay campo "actual"
/// denormalizado que pueda quedarse obsoleto (§10/§11), y conserva qué
/// objetivo había en cada fecha para las estadísticas y el futuro
/// sistema de rangos (§7).
 final  List<PeriodicityEntry> _periodicityTimeline;
/// Línea temporal de objetivos, ordenada por `since` ascendente. La
/// primera entrada es la configuración inicial; las entradas con
/// `since` futura son cambios ya decididos pero todavía no vigentes.
///
/// Es la fuente de verdad de la periodicidad: no hay campo "actual"
/// denormalizado que pueda quedarse obsoleto (§10/§11), y conserva qué
/// objetivo había en cada fecha para las estadísticas y el futuro
/// sistema de rangos (§7).
@override List<PeriodicityEntry> get periodicityTimeline {
  if (_periodicityTimeline is EqualUnmodifiableListView) return _periodicityTimeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_periodicityTimeline);
}

/// Color asignado de la paleta al crear el hábito, editable.
@override final  int colorValue;
@override final  String emoji;
/// Hora fija de recordatorio en formato "HH:mm" (v1), opcional.
@override final  String? reminderTime;
/// Posición en las listas.
@override@JsonKey() final  int order;
@override final  DateTime createdAt;
/// Soft delete: los hábitos borrados conservan su histórico de registros
/// y no aparecen en las consultas normales (§30).
@override final  DateTime? deletedAt;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitCopyWith<_Habit> get copyWith => __$HabitCopyWithImpl<_Habit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ambitoId, ambitoId) || other.ambitoId == ambitoId)&&const DeepCollectionEquality().equals(other._periodicityTimeline, _periodicityTimeline)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,ambitoId,const DeepCollectionEquality().hash(_periodicityTimeline),colorValue,emoji,reminderTime,order,createdAt,deletedAt);

@override
String toString() {
  return 'Habit(id: $id, name: $name, ambitoId: $ambitoId, periodicityTimeline: $periodicityTimeline, colorValue: $colorValue, emoji: $emoji, reminderTime: $reminderTime, order: $order, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$HabitCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$HabitCopyWith(_Habit value, $Res Function(_Habit) _then) = __$HabitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ambitoId, List<PeriodicityEntry> periodicityTimeline, int colorValue, String emoji, String? reminderTime, int order, DateTime createdAt, DateTime? deletedAt
});




}
/// @nodoc
class __$HabitCopyWithImpl<$Res>
    implements _$HabitCopyWith<$Res> {
  __$HabitCopyWithImpl(this._self, this._then);

  final _Habit _self;
  final $Res Function(_Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ambitoId = null,Object? periodicityTimeline = null,Object? colorValue = null,Object? emoji = null,Object? reminderTime = freezed,Object? order = null,Object? createdAt = null,Object? deletedAt = freezed,}) {
  return _then(_Habit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ambitoId: null == ambitoId ? _self.ambitoId : ambitoId // ignore: cast_nullable_to_non_nullable
as String,periodicityTimeline: null == periodicityTimeline ? _self._periodicityTimeline : periodicityTimeline // ignore: cast_nullable_to_non_nullable
as List<PeriodicityEntry>,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,reminderTime: freezed == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
