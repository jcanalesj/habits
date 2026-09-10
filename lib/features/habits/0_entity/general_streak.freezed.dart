// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'general_streak.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeneralStreak {

 int get count; bool get comodinDisponible; DateTime? get lastLogDate;
/// Create a copy of GeneralStreak
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneralStreakCopyWith<GeneralStreak> get copyWith => _$GeneralStreakCopyWithImpl<GeneralStreak>(this as GeneralStreak, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneralStreak&&(identical(other.count, count) || other.count == count)&&(identical(other.comodinDisponible, comodinDisponible) || other.comodinDisponible == comodinDisponible)&&(identical(other.lastLogDate, lastLogDate) || other.lastLogDate == lastLogDate));
}


@override
int get hashCode => Object.hash(runtimeType,count,comodinDisponible,lastLogDate);

@override
String toString() {
  return 'GeneralStreak(count: $count, comodinDisponible: $comodinDisponible, lastLogDate: $lastLogDate)';
}


}

/// @nodoc
abstract mixin class $GeneralStreakCopyWith<$Res>  {
  factory $GeneralStreakCopyWith(GeneralStreak value, $Res Function(GeneralStreak) _then) = _$GeneralStreakCopyWithImpl;
@useResult
$Res call({
 int count, bool comodinDisponible, DateTime? lastLogDate
});




}
/// @nodoc
class _$GeneralStreakCopyWithImpl<$Res>
    implements $GeneralStreakCopyWith<$Res> {
  _$GeneralStreakCopyWithImpl(this._self, this._then);

  final GeneralStreak _self;
  final $Res Function(GeneralStreak) _then;

/// Create a copy of GeneralStreak
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? comodinDisponible = null,Object? lastLogDate = freezed,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,comodinDisponible: null == comodinDisponible ? _self.comodinDisponible : comodinDisponible // ignore: cast_nullable_to_non_nullable
as bool,lastLogDate: freezed == lastLogDate ? _self.lastLogDate : lastLogDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneralStreak].
extension GeneralStreakPatterns on GeneralStreak {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneralStreak value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneralStreak() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneralStreak value)  $default,){
final _that = this;
switch (_that) {
case _GeneralStreak():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneralStreak value)?  $default,){
final _that = this;
switch (_that) {
case _GeneralStreak() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  bool comodinDisponible,  DateTime? lastLogDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneralStreak() when $default != null:
return $default(_that.count,_that.comodinDisponible,_that.lastLogDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  bool comodinDisponible,  DateTime? lastLogDate)  $default,) {final _that = this;
switch (_that) {
case _GeneralStreak():
return $default(_that.count,_that.comodinDisponible,_that.lastLogDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  bool comodinDisponible,  DateTime? lastLogDate)?  $default,) {final _that = this;
switch (_that) {
case _GeneralStreak() when $default != null:
return $default(_that.count,_that.comodinDisponible,_that.lastLogDate);case _:
  return null;

}
}

}

/// @nodoc


class _GeneralStreak implements GeneralStreak {
  const _GeneralStreak({this.count = 0, this.comodinDisponible = true, this.lastLogDate});
  

@override@JsonKey() final  int count;
@override@JsonKey() final  bool comodinDisponible;
@override final  DateTime? lastLogDate;

/// Create a copy of GeneralStreak
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneralStreakCopyWith<_GeneralStreak> get copyWith => __$GeneralStreakCopyWithImpl<_GeneralStreak>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneralStreak&&(identical(other.count, count) || other.count == count)&&(identical(other.comodinDisponible, comodinDisponible) || other.comodinDisponible == comodinDisponible)&&(identical(other.lastLogDate, lastLogDate) || other.lastLogDate == lastLogDate));
}


@override
int get hashCode => Object.hash(runtimeType,count,comodinDisponible,lastLogDate);

@override
String toString() {
  return 'GeneralStreak(count: $count, comodinDisponible: $comodinDisponible, lastLogDate: $lastLogDate)';
}


}

/// @nodoc
abstract mixin class _$GeneralStreakCopyWith<$Res> implements $GeneralStreakCopyWith<$Res> {
  factory _$GeneralStreakCopyWith(_GeneralStreak value, $Res Function(_GeneralStreak) _then) = __$GeneralStreakCopyWithImpl;
@override @useResult
$Res call({
 int count, bool comodinDisponible, DateTime? lastLogDate
});




}
/// @nodoc
class __$GeneralStreakCopyWithImpl<$Res>
    implements _$GeneralStreakCopyWith<$Res> {
  __$GeneralStreakCopyWithImpl(this._self, this._then);

  final _GeneralStreak _self;
  final $Res Function(_GeneralStreak) _then;

/// Create a copy of GeneralStreak
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? comodinDisponible = null,Object? lastLogDate = freezed,}) {
  return _then(_GeneralStreak(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,comodinDisponible: null == comodinDisponible ? _self.comodinDisponible : comodinDisponible // ignore: cast_nullable_to_non_nullable
as bool,lastLogDate: freezed == lastLogDate ? _self.lastLogDate : lastLogDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
