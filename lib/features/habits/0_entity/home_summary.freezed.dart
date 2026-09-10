// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeSummary {

 GeneralStreak get generalStreak; List<Ambito> get ambitos; List<Habit> get habits;/// Registros de la semana en curso (lunes a domingo).
 List<HabitLog> get weekLogs;
/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSummaryCopyWith<HomeSummary> get copyWith => _$HomeSummaryCopyWithImpl<HomeSummary>(this as HomeSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSummary&&(identical(other.generalStreak, generalStreak) || other.generalStreak == generalStreak)&&const DeepCollectionEquality().equals(other.ambitos, ambitos)&&const DeepCollectionEquality().equals(other.habits, habits)&&const DeepCollectionEquality().equals(other.weekLogs, weekLogs));
}


@override
int get hashCode => Object.hash(runtimeType,generalStreak,const DeepCollectionEquality().hash(ambitos),const DeepCollectionEquality().hash(habits),const DeepCollectionEquality().hash(weekLogs));

@override
String toString() {
  return 'HomeSummary(generalStreak: $generalStreak, ambitos: $ambitos, habits: $habits, weekLogs: $weekLogs)';
}


}

/// @nodoc
abstract mixin class $HomeSummaryCopyWith<$Res>  {
  factory $HomeSummaryCopyWith(HomeSummary value, $Res Function(HomeSummary) _then) = _$HomeSummaryCopyWithImpl;
@useResult
$Res call({
 GeneralStreak generalStreak, List<Ambito> ambitos, List<Habit> habits, List<HabitLog> weekLogs
});


$GeneralStreakCopyWith<$Res> get generalStreak;

}
/// @nodoc
class _$HomeSummaryCopyWithImpl<$Res>
    implements $HomeSummaryCopyWith<$Res> {
  _$HomeSummaryCopyWithImpl(this._self, this._then);

  final HomeSummary _self;
  final $Res Function(HomeSummary) _then;

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? generalStreak = null,Object? ambitos = null,Object? habits = null,Object? weekLogs = null,}) {
  return _then(_self.copyWith(
generalStreak: null == generalStreak ? _self.generalStreak : generalStreak // ignore: cast_nullable_to_non_nullable
as GeneralStreak,ambitos: null == ambitos ? _self.ambitos : ambitos // ignore: cast_nullable_to_non_nullable
as List<Ambito>,habits: null == habits ? _self.habits : habits // ignore: cast_nullable_to_non_nullable
as List<Habit>,weekLogs: null == weekLogs ? _self.weekLogs : weekLogs // ignore: cast_nullable_to_non_nullable
as List<HabitLog>,
  ));
}
/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralStreakCopyWith<$Res> get generalStreak {
  
  return $GeneralStreakCopyWith<$Res>(_self.generalStreak, (value) {
    return _then(_self.copyWith(generalStreak: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeSummary].
extension HomeSummaryPatterns on HomeSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeSummary value)  $default,){
final _that = this;
switch (_that) {
case _HomeSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeSummary value)?  $default,){
final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GeneralStreak generalStreak,  List<Ambito> ambitos,  List<Habit> habits,  List<HabitLog> weekLogs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
return $default(_that.generalStreak,_that.ambitos,_that.habits,_that.weekLogs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GeneralStreak generalStreak,  List<Ambito> ambitos,  List<Habit> habits,  List<HabitLog> weekLogs)  $default,) {final _that = this;
switch (_that) {
case _HomeSummary():
return $default(_that.generalStreak,_that.ambitos,_that.habits,_that.weekLogs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GeneralStreak generalStreak,  List<Ambito> ambitos,  List<Habit> habits,  List<HabitLog> weekLogs)?  $default,) {final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
return $default(_that.generalStreak,_that.ambitos,_that.habits,_that.weekLogs);case _:
  return null;

}
}

}

/// @nodoc


class _HomeSummary implements HomeSummary {
  const _HomeSummary({required this.generalStreak, required final  List<Ambito> ambitos, required final  List<Habit> habits, required final  List<HabitLog> weekLogs}): _ambitos = ambitos,_habits = habits,_weekLogs = weekLogs;
  

@override final  GeneralStreak generalStreak;
 final  List<Ambito> _ambitos;
@override List<Ambito> get ambitos {
  if (_ambitos is EqualUnmodifiableListView) return _ambitos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ambitos);
}

 final  List<Habit> _habits;
@override List<Habit> get habits {
  if (_habits is EqualUnmodifiableListView) return _habits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_habits);
}

/// Registros de la semana en curso (lunes a domingo).
 final  List<HabitLog> _weekLogs;
/// Registros de la semana en curso (lunes a domingo).
@override List<HabitLog> get weekLogs {
  if (_weekLogs is EqualUnmodifiableListView) return _weekLogs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weekLogs);
}


/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeSummaryCopyWith<_HomeSummary> get copyWith => __$HomeSummaryCopyWithImpl<_HomeSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSummary&&(identical(other.generalStreak, generalStreak) || other.generalStreak == generalStreak)&&const DeepCollectionEquality().equals(other._ambitos, _ambitos)&&const DeepCollectionEquality().equals(other._habits, _habits)&&const DeepCollectionEquality().equals(other._weekLogs, _weekLogs));
}


@override
int get hashCode => Object.hash(runtimeType,generalStreak,const DeepCollectionEquality().hash(_ambitos),const DeepCollectionEquality().hash(_habits),const DeepCollectionEquality().hash(_weekLogs));

@override
String toString() {
  return 'HomeSummary(generalStreak: $generalStreak, ambitos: $ambitos, habits: $habits, weekLogs: $weekLogs)';
}


}

/// @nodoc
abstract mixin class _$HomeSummaryCopyWith<$Res> implements $HomeSummaryCopyWith<$Res> {
  factory _$HomeSummaryCopyWith(_HomeSummary value, $Res Function(_HomeSummary) _then) = __$HomeSummaryCopyWithImpl;
@override @useResult
$Res call({
 GeneralStreak generalStreak, List<Ambito> ambitos, List<Habit> habits, List<HabitLog> weekLogs
});


@override $GeneralStreakCopyWith<$Res> get generalStreak;

}
/// @nodoc
class __$HomeSummaryCopyWithImpl<$Res>
    implements _$HomeSummaryCopyWith<$Res> {
  __$HomeSummaryCopyWithImpl(this._self, this._then);

  final _HomeSummary _self;
  final $Res Function(_HomeSummary) _then;

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? generalStreak = null,Object? ambitos = null,Object? habits = null,Object? weekLogs = null,}) {
  return _then(_HomeSummary(
generalStreak: null == generalStreak ? _self.generalStreak : generalStreak // ignore: cast_nullable_to_non_nullable
as GeneralStreak,ambitos: null == ambitos ? _self._ambitos : ambitos // ignore: cast_nullable_to_non_nullable
as List<Ambito>,habits: null == habits ? _self._habits : habits // ignore: cast_nullable_to_non_nullable
as List<Habit>,weekLogs: null == weekLogs ? _self._weekLogs : weekLogs // ignore: cast_nullable_to_non_nullable
as List<HabitLog>,
  ));
}

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralStreakCopyWith<$Res> get generalStreak {
  
  return $GeneralStreakCopyWith<$Res>(_self.generalStreak, (value) {
    return _then(_self.copyWith(generalStreak: value));
  });
}
}

// dart format on
