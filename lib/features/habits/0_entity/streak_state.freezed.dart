// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RescueOpportunity {

/// Día a proteger. Siempre es `hoy - 1`.
 LogicalDate get day;/// Racha que se perderá si no se rescata: los días de actividad de la
/// cadena que terminó justo antes del hueco. Es el número que la Home
/// muestra mientras dura la ventana ("🔥 24 — tu racha está en peligro").
 int get streakAtRisk;/// Racha resultante si se usa el comodín ahora. Incluye la actividad de
/// hoy si ya la hay: el comodín protege pero no suma (§16), así que
/// 24 + comodín = 24, y 24 + comodín + actividad de hoy = 25.
 int get streakIfRescued;
/// Create a copy of RescueOpportunity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RescueOpportunityCopyWith<RescueOpportunity> get copyWith => _$RescueOpportunityCopyWithImpl<RescueOpportunity>(this as RescueOpportunity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RescueOpportunity&&(identical(other.day, day) || other.day == day)&&(identical(other.streakAtRisk, streakAtRisk) || other.streakAtRisk == streakAtRisk)&&(identical(other.streakIfRescued, streakIfRescued) || other.streakIfRescued == streakIfRescued));
}


@override
int get hashCode => Object.hash(runtimeType,day,streakAtRisk,streakIfRescued);

@override
String toString() {
  return 'RescueOpportunity(day: $day, streakAtRisk: $streakAtRisk, streakIfRescued: $streakIfRescued)';
}


}

/// @nodoc
abstract mixin class $RescueOpportunityCopyWith<$Res>  {
  factory $RescueOpportunityCopyWith(RescueOpportunity value, $Res Function(RescueOpportunity) _then) = _$RescueOpportunityCopyWithImpl;
@useResult
$Res call({
 LogicalDate day, int streakAtRisk, int streakIfRescued
});




}
/// @nodoc
class _$RescueOpportunityCopyWithImpl<$Res>
    implements $RescueOpportunityCopyWith<$Res> {
  _$RescueOpportunityCopyWithImpl(this._self, this._then);

  final RescueOpportunity _self;
  final $Res Function(RescueOpportunity) _then;

/// Create a copy of RescueOpportunity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? streakAtRisk = null,Object? streakIfRescued = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LogicalDate,streakAtRisk: null == streakAtRisk ? _self.streakAtRisk : streakAtRisk // ignore: cast_nullable_to_non_nullable
as int,streakIfRescued: null == streakIfRescued ? _self.streakIfRescued : streakIfRescued // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RescueOpportunity].
extension RescueOpportunityPatterns on RescueOpportunity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RescueOpportunity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RescueOpportunity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RescueOpportunity value)  $default,){
final _that = this;
switch (_that) {
case _RescueOpportunity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RescueOpportunity value)?  $default,){
final _that = this;
switch (_that) {
case _RescueOpportunity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LogicalDate day,  int streakAtRisk,  int streakIfRescued)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RescueOpportunity() when $default != null:
return $default(_that.day,_that.streakAtRisk,_that.streakIfRescued);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LogicalDate day,  int streakAtRisk,  int streakIfRescued)  $default,) {final _that = this;
switch (_that) {
case _RescueOpportunity():
return $default(_that.day,_that.streakAtRisk,_that.streakIfRescued);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LogicalDate day,  int streakAtRisk,  int streakIfRescued)?  $default,) {final _that = this;
switch (_that) {
case _RescueOpportunity() when $default != null:
return $default(_that.day,_that.streakAtRisk,_that.streakIfRescued);case _:
  return null;

}
}

}

/// @nodoc


class _RescueOpportunity implements RescueOpportunity {
  const _RescueOpportunity({required this.day, required this.streakAtRisk, required this.streakIfRescued});
  

/// Día a proteger. Siempre es `hoy - 1`.
@override final  LogicalDate day;
/// Racha que se perderá si no se rescata: los días de actividad de la
/// cadena que terminó justo antes del hueco. Es el número que la Home
/// muestra mientras dura la ventana ("🔥 24 — tu racha está en peligro").
@override final  int streakAtRisk;
/// Racha resultante si se usa el comodín ahora. Incluye la actividad de
/// hoy si ya la hay: el comodín protege pero no suma (§16), así que
/// 24 + comodín = 24, y 24 + comodín + actividad de hoy = 25.
@override final  int streakIfRescued;

/// Create a copy of RescueOpportunity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RescueOpportunityCopyWith<_RescueOpportunity> get copyWith => __$RescueOpportunityCopyWithImpl<_RescueOpportunity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RescueOpportunity&&(identical(other.day, day) || other.day == day)&&(identical(other.streakAtRisk, streakAtRisk) || other.streakAtRisk == streakAtRisk)&&(identical(other.streakIfRescued, streakIfRescued) || other.streakIfRescued == streakIfRescued));
}


@override
int get hashCode => Object.hash(runtimeType,day,streakAtRisk,streakIfRescued);

@override
String toString() {
  return 'RescueOpportunity(day: $day, streakAtRisk: $streakAtRisk, streakIfRescued: $streakIfRescued)';
}


}

/// @nodoc
abstract mixin class _$RescueOpportunityCopyWith<$Res> implements $RescueOpportunityCopyWith<$Res> {
  factory _$RescueOpportunityCopyWith(_RescueOpportunity value, $Res Function(_RescueOpportunity) _then) = __$RescueOpportunityCopyWithImpl;
@override @useResult
$Res call({
 LogicalDate day, int streakAtRisk, int streakIfRescued
});




}
/// @nodoc
class __$RescueOpportunityCopyWithImpl<$Res>
    implements _$RescueOpportunityCopyWith<$Res> {
  __$RescueOpportunityCopyWithImpl(this._self, this._then);

  final _RescueOpportunity _self;
  final $Res Function(_RescueOpportunity) _then;

/// Create a copy of RescueOpportunity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? streakAtRisk = null,Object? streakIfRescued = null,}) {
  return _then(_RescueOpportunity(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LogicalDate,streakAtRisk: null == streakAtRisk ? _self.streakAtRisk : streakAtRisk // ignore: cast_nullable_to_non_nullable
as int,streakIfRescued: null == streakIfRescued ? _self.streakIfRescued : streakIfRescued // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$StreakState {

/// Racha viva a día de hoy, contada en DÍAS CON ACTIVIDAD.
///
/// Es el valor determinista: si ayer quedó vacío y sin proteger, la
/// cadena anterior ya está rota y esto vale 0, o 1 si hoy hay actividad.
 int get currentStreak;/// Mejor racha histórica, con la misma semántica: días de actividad de
/// la cadena más larga. Los días protegidos mantienen la cadena pero no
/// se cuentan (§32).
 int get bestStreak;/// Último día con actividad real. Null si el usuario nunca completó un
/// hábito.
 LogicalDate? get lastActivityDay; StreakStatus get status; RescueOpportunity? get rescue;
/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakStateCopyWith<StreakState> get copyWith => _$StreakStateCopyWithImpl<StreakState>(this as StreakState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakState&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.bestStreak, bestStreak) || other.bestStreak == bestStreak)&&(identical(other.lastActivityDay, lastActivityDay) || other.lastActivityDay == lastActivityDay)&&(identical(other.status, status) || other.status == status)&&(identical(other.rescue, rescue) || other.rescue == rescue));
}


@override
int get hashCode => Object.hash(runtimeType,currentStreak,bestStreak,lastActivityDay,status,rescue);

@override
String toString() {
  return 'StreakState(currentStreak: $currentStreak, bestStreak: $bestStreak, lastActivityDay: $lastActivityDay, status: $status, rescue: $rescue)';
}


}

/// @nodoc
abstract mixin class $StreakStateCopyWith<$Res>  {
  factory $StreakStateCopyWith(StreakState value, $Res Function(StreakState) _then) = _$StreakStateCopyWithImpl;
@useResult
$Res call({
 int currentStreak, int bestStreak, LogicalDate? lastActivityDay, StreakStatus status, RescueOpportunity? rescue
});


$RescueOpportunityCopyWith<$Res>? get rescue;

}
/// @nodoc
class _$StreakStateCopyWithImpl<$Res>
    implements $StreakStateCopyWith<$Res> {
  _$StreakStateCopyWithImpl(this._self, this._then);

  final StreakState _self;
  final $Res Function(StreakState) _then;

/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStreak = null,Object? bestStreak = null,Object? lastActivityDay = freezed,Object? status = null,Object? rescue = freezed,}) {
  return _then(_self.copyWith(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,lastActivityDay: freezed == lastActivityDay ? _self.lastActivityDay : lastActivityDay // ignore: cast_nullable_to_non_nullable
as LogicalDate?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StreakStatus,rescue: freezed == rescue ? _self.rescue : rescue // ignore: cast_nullable_to_non_nullable
as RescueOpportunity?,
  ));
}
/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RescueOpportunityCopyWith<$Res>? get rescue {
    if (_self.rescue == null) {
    return null;
  }

  return $RescueOpportunityCopyWith<$Res>(_self.rescue!, (value) {
    return _then(_self.copyWith(rescue: value));
  });
}
}


/// Adds pattern-matching-related methods to [StreakState].
extension StreakStatePatterns on StreakState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakState value)  $default,){
final _that = this;
switch (_that) {
case _StreakState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakState value)?  $default,){
final _that = this;
switch (_that) {
case _StreakState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStreak,  int bestStreak,  LogicalDate? lastActivityDay,  StreakStatus status,  RescueOpportunity? rescue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakState() when $default != null:
return $default(_that.currentStreak,_that.bestStreak,_that.lastActivityDay,_that.status,_that.rescue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStreak,  int bestStreak,  LogicalDate? lastActivityDay,  StreakStatus status,  RescueOpportunity? rescue)  $default,) {final _that = this;
switch (_that) {
case _StreakState():
return $default(_that.currentStreak,_that.bestStreak,_that.lastActivityDay,_that.status,_that.rescue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStreak,  int bestStreak,  LogicalDate? lastActivityDay,  StreakStatus status,  RescueOpportunity? rescue)?  $default,) {final _that = this;
switch (_that) {
case _StreakState() when $default != null:
return $default(_that.currentStreak,_that.bestStreak,_that.lastActivityDay,_that.status,_that.rescue);case _:
  return null;

}
}

}

/// @nodoc


class _StreakState extends StreakState {
  const _StreakState({this.currentStreak = 0, this.bestStreak = 0, this.lastActivityDay, this.status = StreakStatus.none, this.rescue}): super._();
  

/// Racha viva a día de hoy, contada en DÍAS CON ACTIVIDAD.
///
/// Es el valor determinista: si ayer quedó vacío y sin proteger, la
/// cadena anterior ya está rota y esto vale 0, o 1 si hoy hay actividad.
@override@JsonKey() final  int currentStreak;
/// Mejor racha histórica, con la misma semántica: días de actividad de
/// la cadena más larga. Los días protegidos mantienen la cadena pero no
/// se cuentan (§32).
@override@JsonKey() final  int bestStreak;
/// Último día con actividad real. Null si el usuario nunca completó un
/// hábito.
@override final  LogicalDate? lastActivityDay;
@override@JsonKey() final  StreakStatus status;
@override final  RescueOpportunity? rescue;

/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakStateCopyWith<_StreakState> get copyWith => __$StreakStateCopyWithImpl<_StreakState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakState&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.bestStreak, bestStreak) || other.bestStreak == bestStreak)&&(identical(other.lastActivityDay, lastActivityDay) || other.lastActivityDay == lastActivityDay)&&(identical(other.status, status) || other.status == status)&&(identical(other.rescue, rescue) || other.rescue == rescue));
}


@override
int get hashCode => Object.hash(runtimeType,currentStreak,bestStreak,lastActivityDay,status,rescue);

@override
String toString() {
  return 'StreakState(currentStreak: $currentStreak, bestStreak: $bestStreak, lastActivityDay: $lastActivityDay, status: $status, rescue: $rescue)';
}


}

/// @nodoc
abstract mixin class _$StreakStateCopyWith<$Res> implements $StreakStateCopyWith<$Res> {
  factory _$StreakStateCopyWith(_StreakState value, $Res Function(_StreakState) _then) = __$StreakStateCopyWithImpl;
@override @useResult
$Res call({
 int currentStreak, int bestStreak, LogicalDate? lastActivityDay, StreakStatus status, RescueOpportunity? rescue
});


@override $RescueOpportunityCopyWith<$Res>? get rescue;

}
/// @nodoc
class __$StreakStateCopyWithImpl<$Res>
    implements _$StreakStateCopyWith<$Res> {
  __$StreakStateCopyWithImpl(this._self, this._then);

  final _StreakState _self;
  final $Res Function(_StreakState) _then;

/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStreak = null,Object? bestStreak = null,Object? lastActivityDay = freezed,Object? status = null,Object? rescue = freezed,}) {
  return _then(_StreakState(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,lastActivityDay: freezed == lastActivityDay ? _self.lastActivityDay : lastActivityDay // ignore: cast_nullable_to_non_nullable
as LogicalDate?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StreakStatus,rescue: freezed == rescue ? _self.rescue : rescue // ignore: cast_nullable_to_non_nullable
as RescueOpportunity?,
  ));
}

/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RescueOpportunityCopyWith<$Res>? get rescue {
    if (_self.rescue == null) {
    return null;
  }

  return $RescueOpportunityCopyWith<$Res>(_self.rescue!, (value) {
    return _then(_self.copyWith(rescue: value));
  });
}
}

// dart format on
