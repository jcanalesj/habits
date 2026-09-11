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

/// Día lógico de hoy en la zona horaria del perfil.
 LogicalDate get today;/// Racha general, calculada en vivo desde el histórico completo.
 StreakState get streak; WildcardBalance get wildcards; List<Ambito> get ambitos;/// Hábitos activos (sin soft delete).
 List<Habit> get habits;/// Progreso del objetivo de cada hábito activo en su periodo actual.
 List<GoalProgress> get progress;/// Registros de la semana en curso (lunes a domingo), para pintar los
/// puntos de la semana y decidir qué está marcado hoy.
 List<HabitLog> get weekLogs;
/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSummaryCopyWith<HomeSummary> get copyWith => _$HomeSummaryCopyWithImpl<HomeSummary>(this as HomeSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSummary&&(identical(other.today, today) || other.today == today)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.wildcards, wildcards) || other.wildcards == wildcards)&&const DeepCollectionEquality().equals(other.ambitos, ambitos)&&const DeepCollectionEquality().equals(other.habits, habits)&&const DeepCollectionEquality().equals(other.progress, progress)&&const DeepCollectionEquality().equals(other.weekLogs, weekLogs));
}


@override
int get hashCode => Object.hash(runtimeType,today,streak,wildcards,const DeepCollectionEquality().hash(ambitos),const DeepCollectionEquality().hash(habits),const DeepCollectionEquality().hash(progress),const DeepCollectionEquality().hash(weekLogs));

@override
String toString() {
  return 'HomeSummary(today: $today, streak: $streak, wildcards: $wildcards, ambitos: $ambitos, habits: $habits, progress: $progress, weekLogs: $weekLogs)';
}


}

/// @nodoc
abstract mixin class $HomeSummaryCopyWith<$Res>  {
  factory $HomeSummaryCopyWith(HomeSummary value, $Res Function(HomeSummary) _then) = _$HomeSummaryCopyWithImpl;
@useResult
$Res call({
 LogicalDate today, StreakState streak, WildcardBalance wildcards, List<Ambito> ambitos, List<Habit> habits, List<GoalProgress> progress, List<HabitLog> weekLogs
});


$StreakStateCopyWith<$Res> get streak;$WildcardBalanceCopyWith<$Res> get wildcards;

}
/// @nodoc
class _$HomeSummaryCopyWithImpl<$Res>
    implements $HomeSummaryCopyWith<$Res> {
  _$HomeSummaryCopyWithImpl(this._self, this._then);

  final HomeSummary _self;
  final $Res Function(HomeSummary) _then;

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? today = null,Object? streak = null,Object? wildcards = null,Object? ambitos = null,Object? habits = null,Object? progress = null,Object? weekLogs = null,}) {
  return _then(_self.copyWith(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LogicalDate,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakState,wildcards: null == wildcards ? _self.wildcards : wildcards // ignore: cast_nullable_to_non_nullable
as WildcardBalance,ambitos: null == ambitos ? _self.ambitos : ambitos // ignore: cast_nullable_to_non_nullable
as List<Ambito>,habits: null == habits ? _self.habits : habits // ignore: cast_nullable_to_non_nullable
as List<Habit>,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as List<GoalProgress>,weekLogs: null == weekLogs ? _self.weekLogs : weekLogs // ignore: cast_nullable_to_non_nullable
as List<HabitLog>,
  ));
}
/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakStateCopyWith<$Res> get streak {
  
  return $StreakStateCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WildcardBalanceCopyWith<$Res> get wildcards {
  
  return $WildcardBalanceCopyWith<$Res>(_self.wildcards, (value) {
    return _then(_self.copyWith(wildcards: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LogicalDate today,  StreakState streak,  WildcardBalance wildcards,  List<Ambito> ambitos,  List<Habit> habits,  List<GoalProgress> progress,  List<HabitLog> weekLogs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
return $default(_that.today,_that.streak,_that.wildcards,_that.ambitos,_that.habits,_that.progress,_that.weekLogs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LogicalDate today,  StreakState streak,  WildcardBalance wildcards,  List<Ambito> ambitos,  List<Habit> habits,  List<GoalProgress> progress,  List<HabitLog> weekLogs)  $default,) {final _that = this;
switch (_that) {
case _HomeSummary():
return $default(_that.today,_that.streak,_that.wildcards,_that.ambitos,_that.habits,_that.progress,_that.weekLogs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LogicalDate today,  StreakState streak,  WildcardBalance wildcards,  List<Ambito> ambitos,  List<Habit> habits,  List<GoalProgress> progress,  List<HabitLog> weekLogs)?  $default,) {final _that = this;
switch (_that) {
case _HomeSummary() when $default != null:
return $default(_that.today,_that.streak,_that.wildcards,_that.ambitos,_that.habits,_that.progress,_that.weekLogs);case _:
  return null;

}
}

}

/// @nodoc


class _HomeSummary extends HomeSummary {
  const _HomeSummary({required this.today, required this.streak, required this.wildcards, required final  List<Ambito> ambitos, required final  List<Habit> habits, required final  List<GoalProgress> progress, required final  List<HabitLog> weekLogs}): _ambitos = ambitos,_habits = habits,_progress = progress,_weekLogs = weekLogs,super._();
  

/// Día lógico de hoy en la zona horaria del perfil.
@override final  LogicalDate today;
/// Racha general, calculada en vivo desde el histórico completo.
@override final  StreakState streak;
@override final  WildcardBalance wildcards;
 final  List<Ambito> _ambitos;
@override List<Ambito> get ambitos {
  if (_ambitos is EqualUnmodifiableListView) return _ambitos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ambitos);
}

/// Hábitos activos (sin soft delete).
 final  List<Habit> _habits;
/// Hábitos activos (sin soft delete).
@override List<Habit> get habits {
  if (_habits is EqualUnmodifiableListView) return _habits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_habits);
}

/// Progreso del objetivo de cada hábito activo en su periodo actual.
 final  List<GoalProgress> _progress;
/// Progreso del objetivo de cada hábito activo en su periodo actual.
@override List<GoalProgress> get progress {
  if (_progress is EqualUnmodifiableListView) return _progress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_progress);
}

/// Registros de la semana en curso (lunes a domingo), para pintar los
/// puntos de la semana y decidir qué está marcado hoy.
 final  List<HabitLog> _weekLogs;
/// Registros de la semana en curso (lunes a domingo), para pintar los
/// puntos de la semana y decidir qué está marcado hoy.
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSummary&&(identical(other.today, today) || other.today == today)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.wildcards, wildcards) || other.wildcards == wildcards)&&const DeepCollectionEquality().equals(other._ambitos, _ambitos)&&const DeepCollectionEquality().equals(other._habits, _habits)&&const DeepCollectionEquality().equals(other._progress, _progress)&&const DeepCollectionEquality().equals(other._weekLogs, _weekLogs));
}


@override
int get hashCode => Object.hash(runtimeType,today,streak,wildcards,const DeepCollectionEquality().hash(_ambitos),const DeepCollectionEquality().hash(_habits),const DeepCollectionEquality().hash(_progress),const DeepCollectionEquality().hash(_weekLogs));

@override
String toString() {
  return 'HomeSummary(today: $today, streak: $streak, wildcards: $wildcards, ambitos: $ambitos, habits: $habits, progress: $progress, weekLogs: $weekLogs)';
}


}

/// @nodoc
abstract mixin class _$HomeSummaryCopyWith<$Res> implements $HomeSummaryCopyWith<$Res> {
  factory _$HomeSummaryCopyWith(_HomeSummary value, $Res Function(_HomeSummary) _then) = __$HomeSummaryCopyWithImpl;
@override @useResult
$Res call({
 LogicalDate today, StreakState streak, WildcardBalance wildcards, List<Ambito> ambitos, List<Habit> habits, List<GoalProgress> progress, List<HabitLog> weekLogs
});


@override $StreakStateCopyWith<$Res> get streak;@override $WildcardBalanceCopyWith<$Res> get wildcards;

}
/// @nodoc
class __$HomeSummaryCopyWithImpl<$Res>
    implements _$HomeSummaryCopyWith<$Res> {
  __$HomeSummaryCopyWithImpl(this._self, this._then);

  final _HomeSummary _self;
  final $Res Function(_HomeSummary) _then;

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? today = null,Object? streak = null,Object? wildcards = null,Object? ambitos = null,Object? habits = null,Object? progress = null,Object? weekLogs = null,}) {
  return _then(_HomeSummary(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LogicalDate,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakState,wildcards: null == wildcards ? _self.wildcards : wildcards // ignore: cast_nullable_to_non_nullable
as WildcardBalance,ambitos: null == ambitos ? _self._ambitos : ambitos // ignore: cast_nullable_to_non_nullable
as List<Ambito>,habits: null == habits ? _self._habits : habits // ignore: cast_nullable_to_non_nullable
as List<Habit>,progress: null == progress ? _self._progress : progress // ignore: cast_nullable_to_non_nullable
as List<GoalProgress>,weekLogs: null == weekLogs ? _self._weekLogs : weekLogs // ignore: cast_nullable_to_non_nullable
as List<HabitLog>,
  ));
}

/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakStateCopyWith<$Res> get streak {
  
  return $StreakStateCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}/// Create a copy of HomeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WildcardBalanceCopyWith<$Res> get wildcards {
  
  return $WildcardBalanceCopyWith<$Res>(_self.wildcards, (value) {
    return _then(_self.copyWith(wildcards: value));
  });
}
}

// dart format on
