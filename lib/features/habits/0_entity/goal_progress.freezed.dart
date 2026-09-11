// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoalPeriod {

 PeriodicityType get type; LogicalDate get start; LogicalDate get end;
/// Create a copy of GoalPeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalPeriodCopyWith<GoalPeriod> get copyWith => _$GoalPeriodCopyWithImpl<GoalPeriod>(this as GoalPeriod, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalPeriod&&(identical(other.type, type) || other.type == type)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,type,start,end);

@override
String toString() {
  return 'GoalPeriod(type: $type, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $GoalPeriodCopyWith<$Res>  {
  factory $GoalPeriodCopyWith(GoalPeriod value, $Res Function(GoalPeriod) _then) = _$GoalPeriodCopyWithImpl;
@useResult
$Res call({
 PeriodicityType type, LogicalDate start, LogicalDate end
});




}
/// @nodoc
class _$GoalPeriodCopyWithImpl<$Res>
    implements $GoalPeriodCopyWith<$Res> {
  _$GoalPeriodCopyWithImpl(this._self, this._then);

  final GoalPeriod _self;
  final $Res Function(GoalPeriod) _then;

/// Create a copy of GoalPeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? start = null,Object? end = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PeriodicityType,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as LogicalDate,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as LogicalDate,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalPeriod].
extension GoalPeriodPatterns on GoalPeriod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalPeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalPeriod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalPeriod value)  $default,){
final _that = this;
switch (_that) {
case _GoalPeriod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalPeriod value)?  $default,){
final _that = this;
switch (_that) {
case _GoalPeriod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PeriodicityType type,  LogicalDate start,  LogicalDate end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalPeriod() when $default != null:
return $default(_that.type,_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PeriodicityType type,  LogicalDate start,  LogicalDate end)  $default,) {final _that = this;
switch (_that) {
case _GoalPeriod():
return $default(_that.type,_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PeriodicityType type,  LogicalDate start,  LogicalDate end)?  $default,) {final _that = this;
switch (_that) {
case _GoalPeriod() when $default != null:
return $default(_that.type,_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc


class _GoalPeriod extends GoalPeriod {
  const _GoalPeriod({required this.type, required this.start, required this.end}): super._();
  

@override final  PeriodicityType type;
@override final  LogicalDate start;
@override final  LogicalDate end;

/// Create a copy of GoalPeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalPeriodCopyWith<_GoalPeriod> get copyWith => __$GoalPeriodCopyWithImpl<_GoalPeriod>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalPeriod&&(identical(other.type, type) || other.type == type)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,type,start,end);

@override
String toString() {
  return 'GoalPeriod(type: $type, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$GoalPeriodCopyWith<$Res> implements $GoalPeriodCopyWith<$Res> {
  factory _$GoalPeriodCopyWith(_GoalPeriod value, $Res Function(_GoalPeriod) _then) = __$GoalPeriodCopyWithImpl;
@override @useResult
$Res call({
 PeriodicityType type, LogicalDate start, LogicalDate end
});




}
/// @nodoc
class __$GoalPeriodCopyWithImpl<$Res>
    implements _$GoalPeriodCopyWith<$Res> {
  __$GoalPeriodCopyWithImpl(this._self, this._then);

  final _GoalPeriod _self;
  final $Res Function(_GoalPeriod) _then;

/// Create a copy of GoalPeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? start = null,Object? end = null,}) {
  return _then(_GoalPeriod(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PeriodicityType,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as LogicalDate,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as LogicalDate,
  ));
}


}

/// @nodoc
mixin _$GoalProgress {

 String get habitId;/// Objetivo vigente para este periodo. Si el usuario cambió la
/// frecuencia, sigue siendo el objetivo con el que empezó el periodo.
 Periodicity get target; GoalPeriod get period;/// Registros de actividad real del hábito dentro del periodo. Puede
/// superar el objetivo: se permite seguir registrando (§44).
 int get completed;
/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalProgressCopyWith<GoalProgress> get copyWith => _$GoalProgressCopyWithImpl<GoalProgress>(this as GoalProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalProgress&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.target, target) || other.target == target)&&(identical(other.period, period) || other.period == period)&&(identical(other.completed, completed) || other.completed == completed));
}


@override
int get hashCode => Object.hash(runtimeType,habitId,target,period,completed);

@override
String toString() {
  return 'GoalProgress(habitId: $habitId, target: $target, period: $period, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $GoalProgressCopyWith<$Res>  {
  factory $GoalProgressCopyWith(GoalProgress value, $Res Function(GoalProgress) _then) = _$GoalProgressCopyWithImpl;
@useResult
$Res call({
 String habitId, Periodicity target, GoalPeriod period, int completed
});


$PeriodicityCopyWith<$Res> get target;$GoalPeriodCopyWith<$Res> get period;

}
/// @nodoc
class _$GoalProgressCopyWithImpl<$Res>
    implements $GoalProgressCopyWith<$Res> {
  _$GoalProgressCopyWithImpl(this._self, this._then);

  final GoalProgress _self;
  final $Res Function(GoalProgress) _then;

/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habitId = null,Object? target = null,Object? period = null,Object? completed = null,}) {
  return _then(_self.copyWith(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Periodicity,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as GoalPeriod,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodicityCopyWith<$Res> get target {
  
  return $PeriodicityCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoalPeriodCopyWith<$Res> get period {
  
  return $GoalPeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [GoalProgress].
extension GoalProgressPatterns on GoalProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalProgress value)  $default,){
final _that = this;
switch (_that) {
case _GoalProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalProgress value)?  $default,){
final _that = this;
switch (_that) {
case _GoalProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String habitId,  Periodicity target,  GoalPeriod period,  int completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalProgress() when $default != null:
return $default(_that.habitId,_that.target,_that.period,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String habitId,  Periodicity target,  GoalPeriod period,  int completed)  $default,) {final _that = this;
switch (_that) {
case _GoalProgress():
return $default(_that.habitId,_that.target,_that.period,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String habitId,  Periodicity target,  GoalPeriod period,  int completed)?  $default,) {final _that = this;
switch (_that) {
case _GoalProgress() when $default != null:
return $default(_that.habitId,_that.target,_that.period,_that.completed);case _:
  return null;

}
}

}

/// @nodoc


class _GoalProgress extends GoalProgress {
  const _GoalProgress({required this.habitId, required this.target, required this.period, this.completed = 0}): super._();
  

@override final  String habitId;
/// Objetivo vigente para este periodo. Si el usuario cambió la
/// frecuencia, sigue siendo el objetivo con el que empezó el periodo.
@override final  Periodicity target;
@override final  GoalPeriod period;
/// Registros de actividad real del hábito dentro del periodo. Puede
/// superar el objetivo: se permite seguir registrando (§44).
@override@JsonKey() final  int completed;

/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalProgressCopyWith<_GoalProgress> get copyWith => __$GoalProgressCopyWithImpl<_GoalProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalProgress&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.target, target) || other.target == target)&&(identical(other.period, period) || other.period == period)&&(identical(other.completed, completed) || other.completed == completed));
}


@override
int get hashCode => Object.hash(runtimeType,habitId,target,period,completed);

@override
String toString() {
  return 'GoalProgress(habitId: $habitId, target: $target, period: $period, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$GoalProgressCopyWith<$Res> implements $GoalProgressCopyWith<$Res> {
  factory _$GoalProgressCopyWith(_GoalProgress value, $Res Function(_GoalProgress) _then) = __$GoalProgressCopyWithImpl;
@override @useResult
$Res call({
 String habitId, Periodicity target, GoalPeriod period, int completed
});


@override $PeriodicityCopyWith<$Res> get target;@override $GoalPeriodCopyWith<$Res> get period;

}
/// @nodoc
class __$GoalProgressCopyWithImpl<$Res>
    implements _$GoalProgressCopyWith<$Res> {
  __$GoalProgressCopyWithImpl(this._self, this._then);

  final _GoalProgress _self;
  final $Res Function(_GoalProgress) _then;

/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habitId = null,Object? target = null,Object? period = null,Object? completed = null,}) {
  return _then(_GoalProgress(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Periodicity,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as GoalPeriod,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodicityCopyWith<$Res> get target {
  
  return $PeriodicityCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of GoalProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoalPeriodCopyWith<$Res> get period {
  
  return $GoalPeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}

// dart format on
