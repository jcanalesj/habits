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

 String get id; String get name;/// Un hábito pertenece a un único ámbito (decisión cerrada, sección 4.4).
 String get ambitoId; Periodicity get periodicity;/// Cupo de descansos planificados dentro del periodo (ej. 2 de cada 7).
 int get restDaysAllowed;/// Tarea alternativa más ligera que salva la racha del ámbito.
 String? get recoveryTask;/// Límite de uso de la tarea de recuperación: 1 vez cada X días.
 int get recoveryCooldownDays;/// Color asignado de la paleta al crear el hábito, editable.
 int get colorValue; String get emoji;/// Hora fija de recordatorio en formato "HH:mm" (v1), opcional.
 String? get reminderTime; int get currentStreak; DateTime get createdAt;
/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitCopyWith<Habit> get copyWith => _$HabitCopyWithImpl<Habit>(this as Habit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ambitoId, ambitoId) || other.ambitoId == ambitoId)&&(identical(other.periodicity, periodicity) || other.periodicity == periodicity)&&(identical(other.restDaysAllowed, restDaysAllowed) || other.restDaysAllowed == restDaysAllowed)&&(identical(other.recoveryTask, recoveryTask) || other.recoveryTask == recoveryTask)&&(identical(other.recoveryCooldownDays, recoveryCooldownDays) || other.recoveryCooldownDays == recoveryCooldownDays)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,ambitoId,periodicity,restDaysAllowed,recoveryTask,recoveryCooldownDays,colorValue,emoji,reminderTime,currentStreak,createdAt);

@override
String toString() {
  return 'Habit(id: $id, name: $name, ambitoId: $ambitoId, periodicity: $periodicity, restDaysAllowed: $restDaysAllowed, recoveryTask: $recoveryTask, recoveryCooldownDays: $recoveryCooldownDays, colorValue: $colorValue, emoji: $emoji, reminderTime: $reminderTime, currentStreak: $currentStreak, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $HabitCopyWith<$Res>  {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) _then) = _$HabitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ambitoId, Periodicity periodicity, int restDaysAllowed, String? recoveryTask, int recoveryCooldownDays, int colorValue, String emoji, String? reminderTime, int currentStreak, DateTime createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ambitoId = null,Object? periodicity = null,Object? restDaysAllowed = null,Object? recoveryTask = freezed,Object? recoveryCooldownDays = null,Object? colorValue = null,Object? emoji = null,Object? reminderTime = freezed,Object? currentStreak = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ambitoId: null == ambitoId ? _self.ambitoId : ambitoId // ignore: cast_nullable_to_non_nullable
as String,periodicity: null == periodicity ? _self.periodicity : periodicity // ignore: cast_nullable_to_non_nullable
as Periodicity,restDaysAllowed: null == restDaysAllowed ? _self.restDaysAllowed : restDaysAllowed // ignore: cast_nullable_to_non_nullable
as int,recoveryTask: freezed == recoveryTask ? _self.recoveryTask : recoveryTask // ignore: cast_nullable_to_non_nullable
as String?,recoveryCooldownDays: null == recoveryCooldownDays ? _self.recoveryCooldownDays : recoveryCooldownDays // ignore: cast_nullable_to_non_nullable
as int,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,reminderTime: freezed == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as String?,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ambitoId,  Periodicity periodicity,  int restDaysAllowed,  String? recoveryTask,  int recoveryCooldownDays,  int colorValue,  String emoji,  String? reminderTime,  int currentStreak,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.name,_that.ambitoId,_that.periodicity,_that.restDaysAllowed,_that.recoveryTask,_that.recoveryCooldownDays,_that.colorValue,_that.emoji,_that.reminderTime,_that.currentStreak,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ambitoId,  Periodicity periodicity,  int restDaysAllowed,  String? recoveryTask,  int recoveryCooldownDays,  int colorValue,  String emoji,  String? reminderTime,  int currentStreak,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Habit():
return $default(_that.id,_that.name,_that.ambitoId,_that.periodicity,_that.restDaysAllowed,_that.recoveryTask,_that.recoveryCooldownDays,_that.colorValue,_that.emoji,_that.reminderTime,_that.currentStreak,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ambitoId,  Periodicity periodicity,  int restDaysAllowed,  String? recoveryTask,  int recoveryCooldownDays,  int colorValue,  String emoji,  String? reminderTime,  int currentStreak,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.name,_that.ambitoId,_that.periodicity,_that.restDaysAllowed,_that.recoveryTask,_that.recoveryCooldownDays,_that.colorValue,_that.emoji,_that.reminderTime,_that.currentStreak,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Habit implements Habit {
  const _Habit({required this.id, required this.name, required this.ambitoId, required this.periodicity, this.restDaysAllowed = 0, this.recoveryTask, this.recoveryCooldownDays = 7, required this.colorValue, required this.emoji, this.reminderTime, this.currentStreak = 0, required this.createdAt});
  

@override final  String id;
@override final  String name;
/// Un hábito pertenece a un único ámbito (decisión cerrada, sección 4.4).
@override final  String ambitoId;
@override final  Periodicity periodicity;
/// Cupo de descansos planificados dentro del periodo (ej. 2 de cada 7).
@override@JsonKey() final  int restDaysAllowed;
/// Tarea alternativa más ligera que salva la racha del ámbito.
@override final  String? recoveryTask;
/// Límite de uso de la tarea de recuperación: 1 vez cada X días.
@override@JsonKey() final  int recoveryCooldownDays;
/// Color asignado de la paleta al crear el hábito, editable.
@override final  int colorValue;
@override final  String emoji;
/// Hora fija de recordatorio en formato "HH:mm" (v1), opcional.
@override final  String? reminderTime;
@override@JsonKey() final  int currentStreak;
@override final  DateTime createdAt;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitCopyWith<_Habit> get copyWith => __$HabitCopyWithImpl<_Habit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ambitoId, ambitoId) || other.ambitoId == ambitoId)&&(identical(other.periodicity, periodicity) || other.periodicity == periodicity)&&(identical(other.restDaysAllowed, restDaysAllowed) || other.restDaysAllowed == restDaysAllowed)&&(identical(other.recoveryTask, recoveryTask) || other.recoveryTask == recoveryTask)&&(identical(other.recoveryCooldownDays, recoveryCooldownDays) || other.recoveryCooldownDays == recoveryCooldownDays)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,ambitoId,periodicity,restDaysAllowed,recoveryTask,recoveryCooldownDays,colorValue,emoji,reminderTime,currentStreak,createdAt);

@override
String toString() {
  return 'Habit(id: $id, name: $name, ambitoId: $ambitoId, periodicity: $periodicity, restDaysAllowed: $restDaysAllowed, recoveryTask: $recoveryTask, recoveryCooldownDays: $recoveryCooldownDays, colorValue: $colorValue, emoji: $emoji, reminderTime: $reminderTime, currentStreak: $currentStreak, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$HabitCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$HabitCopyWith(_Habit value, $Res Function(_Habit) _then) = __$HabitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ambitoId, Periodicity periodicity, int restDaysAllowed, String? recoveryTask, int recoveryCooldownDays, int colorValue, String emoji, String? reminderTime, int currentStreak, DateTime createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ambitoId = null,Object? periodicity = null,Object? restDaysAllowed = null,Object? recoveryTask = freezed,Object? recoveryCooldownDays = null,Object? colorValue = null,Object? emoji = null,Object? reminderTime = freezed,Object? currentStreak = null,Object? createdAt = null,}) {
  return _then(_Habit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ambitoId: null == ambitoId ? _self.ambitoId : ambitoId // ignore: cast_nullable_to_non_nullable
as String,periodicity: null == periodicity ? _self.periodicity : periodicity // ignore: cast_nullable_to_non_nullable
as Periodicity,restDaysAllowed: null == restDaysAllowed ? _self.restDaysAllowed : restDaysAllowed // ignore: cast_nullable_to_non_nullable
as int,recoveryTask: freezed == recoveryTask ? _self.recoveryTask : recoveryTask // ignore: cast_nullable_to_non_nullable
as String?,recoveryCooldownDays: null == recoveryCooldownDays ? _self.recoveryCooldownDays : recoveryCooldownDays // ignore: cast_nullable_to_non_nullable
as int,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,reminderTime: freezed == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as String?,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
