// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streaks_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitStreak {

 int get current; int get best;
/// Create a copy of HabitStreak
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitStreakCopyWith<HabitStreak> get copyWith => _$HabitStreakCopyWithImpl<HabitStreak>(this as HabitStreak, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitStreak&&(identical(other.current, current) || other.current == current)&&(identical(other.best, best) || other.best == best));
}


@override
int get hashCode => Object.hash(runtimeType,current,best);

@override
String toString() {
  return 'HabitStreak(current: $current, best: $best)';
}


}

/// @nodoc
abstract mixin class $HabitStreakCopyWith<$Res>  {
  factory $HabitStreakCopyWith(HabitStreak value, $Res Function(HabitStreak) _then) = _$HabitStreakCopyWithImpl;
@useResult
$Res call({
 int current, int best
});




}
/// @nodoc
class _$HabitStreakCopyWithImpl<$Res>
    implements $HabitStreakCopyWith<$Res> {
  _$HabitStreakCopyWithImpl(this._self, this._then);

  final HabitStreak _self;
  final $Res Function(HabitStreak) _then;

/// Create a copy of HabitStreak
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? best = null,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitStreak].
extension HabitStreakPatterns on HabitStreak {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitStreak value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitStreak() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitStreak value)  $default,){
final _that = this;
switch (_that) {
case _HabitStreak():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitStreak value)?  $default,){
final _that = this;
switch (_that) {
case _HabitStreak() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int best)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitStreak() when $default != null:
return $default(_that.current,_that.best);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int best)  $default,) {final _that = this;
switch (_that) {
case _HabitStreak():
return $default(_that.current,_that.best);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int best)?  $default,) {final _that = this;
switch (_that) {
case _HabitStreak() when $default != null:
return $default(_that.current,_that.best);case _:
  return null;

}
}

}

/// @nodoc


class _HabitStreak implements HabitStreak {
  const _HabitStreak({this.current = 0, this.best = 0});
  

@override@JsonKey() final  int current;
@override@JsonKey() final  int best;

/// Create a copy of HabitStreak
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitStreakCopyWith<_HabitStreak> get copyWith => __$HabitStreakCopyWithImpl<_HabitStreak>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitStreak&&(identical(other.current, current) || other.current == current)&&(identical(other.best, best) || other.best == best));
}


@override
int get hashCode => Object.hash(runtimeType,current,best);

@override
String toString() {
  return 'HabitStreak(current: $current, best: $best)';
}


}

/// @nodoc
abstract mixin class _$HabitStreakCopyWith<$Res> implements $HabitStreakCopyWith<$Res> {
  factory _$HabitStreakCopyWith(_HabitStreak value, $Res Function(_HabitStreak) _then) = __$HabitStreakCopyWithImpl;
@override @useResult
$Res call({
 int current, int best
});




}
/// @nodoc
class __$HabitStreakCopyWithImpl<$Res>
    implements _$HabitStreakCopyWith<$Res> {
  __$HabitStreakCopyWithImpl(this._self, this._then);

  final _HabitStreak _self;
  final $Res Function(_HabitStreak) _then;

/// Create a copy of HabitStreak
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? best = null,}) {
  return _then(_HabitStreak(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AmbitoStreak {

 int get current; int get best; bool get comodinDisponible;
/// Create a copy of AmbitoStreak
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmbitoStreakCopyWith<AmbitoStreak> get copyWith => _$AmbitoStreakCopyWithImpl<AmbitoStreak>(this as AmbitoStreak, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AmbitoStreak&&(identical(other.current, current) || other.current == current)&&(identical(other.best, best) || other.best == best)&&(identical(other.comodinDisponible, comodinDisponible) || other.comodinDisponible == comodinDisponible));
}


@override
int get hashCode => Object.hash(runtimeType,current,best,comodinDisponible);

@override
String toString() {
  return 'AmbitoStreak(current: $current, best: $best, comodinDisponible: $comodinDisponible)';
}


}

/// @nodoc
abstract mixin class $AmbitoStreakCopyWith<$Res>  {
  factory $AmbitoStreakCopyWith(AmbitoStreak value, $Res Function(AmbitoStreak) _then) = _$AmbitoStreakCopyWithImpl;
@useResult
$Res call({
 int current, int best, bool comodinDisponible
});




}
/// @nodoc
class _$AmbitoStreakCopyWithImpl<$Res>
    implements $AmbitoStreakCopyWith<$Res> {
  _$AmbitoStreakCopyWithImpl(this._self, this._then);

  final AmbitoStreak _self;
  final $Res Function(AmbitoStreak) _then;

/// Create a copy of AmbitoStreak
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? best = null,Object? comodinDisponible = null,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,comodinDisponible: null == comodinDisponible ? _self.comodinDisponible : comodinDisponible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AmbitoStreak].
extension AmbitoStreakPatterns on AmbitoStreak {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AmbitoStreak value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AmbitoStreak() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AmbitoStreak value)  $default,){
final _that = this;
switch (_that) {
case _AmbitoStreak():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AmbitoStreak value)?  $default,){
final _that = this;
switch (_that) {
case _AmbitoStreak() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int best,  bool comodinDisponible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AmbitoStreak() when $default != null:
return $default(_that.current,_that.best,_that.comodinDisponible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int best,  bool comodinDisponible)  $default,) {final _that = this;
switch (_that) {
case _AmbitoStreak():
return $default(_that.current,_that.best,_that.comodinDisponible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int best,  bool comodinDisponible)?  $default,) {final _that = this;
switch (_that) {
case _AmbitoStreak() when $default != null:
return $default(_that.current,_that.best,_that.comodinDisponible);case _:
  return null;

}
}

}

/// @nodoc


class _AmbitoStreak implements AmbitoStreak {
  const _AmbitoStreak({this.current = 0, this.best = 0, this.comodinDisponible = true});
  

@override@JsonKey() final  int current;
@override@JsonKey() final  int best;
@override@JsonKey() final  bool comodinDisponible;

/// Create a copy of AmbitoStreak
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmbitoStreakCopyWith<_AmbitoStreak> get copyWith => __$AmbitoStreakCopyWithImpl<_AmbitoStreak>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AmbitoStreak&&(identical(other.current, current) || other.current == current)&&(identical(other.best, best) || other.best == best)&&(identical(other.comodinDisponible, comodinDisponible) || other.comodinDisponible == comodinDisponible));
}


@override
int get hashCode => Object.hash(runtimeType,current,best,comodinDisponible);

@override
String toString() {
  return 'AmbitoStreak(current: $current, best: $best, comodinDisponible: $comodinDisponible)';
}


}

/// @nodoc
abstract mixin class _$AmbitoStreakCopyWith<$Res> implements $AmbitoStreakCopyWith<$Res> {
  factory _$AmbitoStreakCopyWith(_AmbitoStreak value, $Res Function(_AmbitoStreak) _then) = __$AmbitoStreakCopyWithImpl;
@override @useResult
$Res call({
 int current, int best, bool comodinDisponible
});




}
/// @nodoc
class __$AmbitoStreakCopyWithImpl<$Res>
    implements _$AmbitoStreakCopyWith<$Res> {
  __$AmbitoStreakCopyWithImpl(this._self, this._then);

  final _AmbitoStreak _self;
  final $Res Function(_AmbitoStreak) _then;

/// Create a copy of AmbitoStreak
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? best = null,Object? comodinDisponible = null,}) {
  return _then(_AmbitoStreak(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,comodinDisponible: null == comodinDisponible ? _self.comodinDisponible : comodinDisponible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$StreaksSnapshot {

 GeneralStreak get general; Map<String, HabitStreak> get habits; Map<String, AmbitoStreak> get ambitos;/// Último día lógico incluido en el cálculo, o null si no hay caché.
 DateTime? get calculatedThrough;
/// Create a copy of StreaksSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreaksSnapshotCopyWith<StreaksSnapshot> get copyWith => _$StreaksSnapshotCopyWithImpl<StreaksSnapshot>(this as StreaksSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreaksSnapshot&&(identical(other.general, general) || other.general == general)&&const DeepCollectionEquality().equals(other.habits, habits)&&const DeepCollectionEquality().equals(other.ambitos, ambitos)&&(identical(other.calculatedThrough, calculatedThrough) || other.calculatedThrough == calculatedThrough));
}


@override
int get hashCode => Object.hash(runtimeType,general,const DeepCollectionEquality().hash(habits),const DeepCollectionEquality().hash(ambitos),calculatedThrough);

@override
String toString() {
  return 'StreaksSnapshot(general: $general, habits: $habits, ambitos: $ambitos, calculatedThrough: $calculatedThrough)';
}


}

/// @nodoc
abstract mixin class $StreaksSnapshotCopyWith<$Res>  {
  factory $StreaksSnapshotCopyWith(StreaksSnapshot value, $Res Function(StreaksSnapshot) _then) = _$StreaksSnapshotCopyWithImpl;
@useResult
$Res call({
 GeneralStreak general, Map<String, HabitStreak> habits, Map<String, AmbitoStreak> ambitos, DateTime? calculatedThrough
});


$GeneralStreakCopyWith<$Res> get general;

}
/// @nodoc
class _$StreaksSnapshotCopyWithImpl<$Res>
    implements $StreaksSnapshotCopyWith<$Res> {
  _$StreaksSnapshotCopyWithImpl(this._self, this._then);

  final StreaksSnapshot _self;
  final $Res Function(StreaksSnapshot) _then;

/// Create a copy of StreaksSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? general = null,Object? habits = null,Object? ambitos = null,Object? calculatedThrough = freezed,}) {
  return _then(_self.copyWith(
general: null == general ? _self.general : general // ignore: cast_nullable_to_non_nullable
as GeneralStreak,habits: null == habits ? _self.habits : habits // ignore: cast_nullable_to_non_nullable
as Map<String, HabitStreak>,ambitos: null == ambitos ? _self.ambitos : ambitos // ignore: cast_nullable_to_non_nullable
as Map<String, AmbitoStreak>,calculatedThrough: freezed == calculatedThrough ? _self.calculatedThrough : calculatedThrough // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of StreaksSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralStreakCopyWith<$Res> get general {
  
  return $GeneralStreakCopyWith<$Res>(_self.general, (value) {
    return _then(_self.copyWith(general: value));
  });
}
}


/// Adds pattern-matching-related methods to [StreaksSnapshot].
extension StreaksSnapshotPatterns on StreaksSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreaksSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreaksSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreaksSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _StreaksSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreaksSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _StreaksSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GeneralStreak general,  Map<String, HabitStreak> habits,  Map<String, AmbitoStreak> ambitos,  DateTime? calculatedThrough)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreaksSnapshot() when $default != null:
return $default(_that.general,_that.habits,_that.ambitos,_that.calculatedThrough);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GeneralStreak general,  Map<String, HabitStreak> habits,  Map<String, AmbitoStreak> ambitos,  DateTime? calculatedThrough)  $default,) {final _that = this;
switch (_that) {
case _StreaksSnapshot():
return $default(_that.general,_that.habits,_that.ambitos,_that.calculatedThrough);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GeneralStreak general,  Map<String, HabitStreak> habits,  Map<String, AmbitoStreak> ambitos,  DateTime? calculatedThrough)?  $default,) {final _that = this;
switch (_that) {
case _StreaksSnapshot() when $default != null:
return $default(_that.general,_that.habits,_that.ambitos,_that.calculatedThrough);case _:
  return null;

}
}

}

/// @nodoc


class _StreaksSnapshot extends StreaksSnapshot {
  const _StreaksSnapshot({this.general = const GeneralStreak(), final  Map<String, HabitStreak> habits = const {}, final  Map<String, AmbitoStreak> ambitos = const {}, this.calculatedThrough}): _habits = habits,_ambitos = ambitos,super._();
  

@override@JsonKey() final  GeneralStreak general;
 final  Map<String, HabitStreak> _habits;
@override@JsonKey() Map<String, HabitStreak> get habits {
  if (_habits is EqualUnmodifiableMapView) return _habits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_habits);
}

 final  Map<String, AmbitoStreak> _ambitos;
@override@JsonKey() Map<String, AmbitoStreak> get ambitos {
  if (_ambitos is EqualUnmodifiableMapView) return _ambitos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ambitos);
}

/// Último día lógico incluido en el cálculo, o null si no hay caché.
@override final  DateTime? calculatedThrough;

/// Create a copy of StreaksSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreaksSnapshotCopyWith<_StreaksSnapshot> get copyWith => __$StreaksSnapshotCopyWithImpl<_StreaksSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreaksSnapshot&&(identical(other.general, general) || other.general == general)&&const DeepCollectionEquality().equals(other._habits, _habits)&&const DeepCollectionEquality().equals(other._ambitos, _ambitos)&&(identical(other.calculatedThrough, calculatedThrough) || other.calculatedThrough == calculatedThrough));
}


@override
int get hashCode => Object.hash(runtimeType,general,const DeepCollectionEquality().hash(_habits),const DeepCollectionEquality().hash(_ambitos),calculatedThrough);

@override
String toString() {
  return 'StreaksSnapshot(general: $general, habits: $habits, ambitos: $ambitos, calculatedThrough: $calculatedThrough)';
}


}

/// @nodoc
abstract mixin class _$StreaksSnapshotCopyWith<$Res> implements $StreaksSnapshotCopyWith<$Res> {
  factory _$StreaksSnapshotCopyWith(_StreaksSnapshot value, $Res Function(_StreaksSnapshot) _then) = __$StreaksSnapshotCopyWithImpl;
@override @useResult
$Res call({
 GeneralStreak general, Map<String, HabitStreak> habits, Map<String, AmbitoStreak> ambitos, DateTime? calculatedThrough
});


@override $GeneralStreakCopyWith<$Res> get general;

}
/// @nodoc
class __$StreaksSnapshotCopyWithImpl<$Res>
    implements _$StreaksSnapshotCopyWith<$Res> {
  __$StreaksSnapshotCopyWithImpl(this._self, this._then);

  final _StreaksSnapshot _self;
  final $Res Function(_StreaksSnapshot) _then;

/// Create a copy of StreaksSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? general = null,Object? habits = null,Object? ambitos = null,Object? calculatedThrough = freezed,}) {
  return _then(_StreaksSnapshot(
general: null == general ? _self.general : general // ignore: cast_nullable_to_non_nullable
as GeneralStreak,habits: null == habits ? _self._habits : habits // ignore: cast_nullable_to_non_nullable
as Map<String, HabitStreak>,ambitos: null == ambitos ? _self._ambitos : ambitos // ignore: cast_nullable_to_non_nullable
as Map<String, AmbitoStreak>,calculatedThrough: freezed == calculatedThrough ? _self.calculatedThrough : calculatedThrough // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of StreaksSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneralStreakCopyWith<$Res> get general {
  
  return $GeneralStreakCopyWith<$Res>(_self.general, (value) {
    return _then(_self.copyWith(general: value));
  });
}
}

// dart format on
