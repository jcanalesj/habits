// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'periodicity_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PeriodicityChange {

 Periodicity get periodicity;/// Día lógico desde el que aplica.
 DateTime get since;
/// Create a copy of PeriodicityChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodicityChangeCopyWith<PeriodicityChange> get copyWith => _$PeriodicityChangeCopyWithImpl<PeriodicityChange>(this as PeriodicityChange, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodicityChange&&(identical(other.periodicity, periodicity) || other.periodicity == periodicity)&&(identical(other.since, since) || other.since == since));
}


@override
int get hashCode => Object.hash(runtimeType,periodicity,since);

@override
String toString() {
  return 'PeriodicityChange(periodicity: $periodicity, since: $since)';
}


}

/// @nodoc
abstract mixin class $PeriodicityChangeCopyWith<$Res>  {
  factory $PeriodicityChangeCopyWith(PeriodicityChange value, $Res Function(PeriodicityChange) _then) = _$PeriodicityChangeCopyWithImpl;
@useResult
$Res call({
 Periodicity periodicity, DateTime since
});




}
/// @nodoc
class _$PeriodicityChangeCopyWithImpl<$Res>
    implements $PeriodicityChangeCopyWith<$Res> {
  _$PeriodicityChangeCopyWithImpl(this._self, this._then);

  final PeriodicityChange _self;
  final $Res Function(PeriodicityChange) _then;

/// Create a copy of PeriodicityChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodicity = null,Object? since = null,}) {
  return _then(_self.copyWith(
periodicity: null == periodicity ? _self.periodicity : periodicity // ignore: cast_nullable_to_non_nullable
as Periodicity,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodicityChange].
extension PeriodicityChangePatterns on PeriodicityChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodicityChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodicityChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodicityChange value)  $default,){
final _that = this;
switch (_that) {
case _PeriodicityChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodicityChange value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodicityChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Periodicity periodicity,  DateTime since)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodicityChange() when $default != null:
return $default(_that.periodicity,_that.since);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Periodicity periodicity,  DateTime since)  $default,) {final _that = this;
switch (_that) {
case _PeriodicityChange():
return $default(_that.periodicity,_that.since);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Periodicity periodicity,  DateTime since)?  $default,) {final _that = this;
switch (_that) {
case _PeriodicityChange() when $default != null:
return $default(_that.periodicity,_that.since);case _:
  return null;

}
}

}

/// @nodoc


class _PeriodicityChange implements PeriodicityChange {
  const _PeriodicityChange({required this.periodicity, required this.since});
  

@override final  Periodicity periodicity;
/// Día lógico desde el que aplica.
@override final  DateTime since;

/// Create a copy of PeriodicityChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodicityChangeCopyWith<_PeriodicityChange> get copyWith => __$PeriodicityChangeCopyWithImpl<_PeriodicityChange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodicityChange&&(identical(other.periodicity, periodicity) || other.periodicity == periodicity)&&(identical(other.since, since) || other.since == since));
}


@override
int get hashCode => Object.hash(runtimeType,periodicity,since);

@override
String toString() {
  return 'PeriodicityChange(periodicity: $periodicity, since: $since)';
}


}

/// @nodoc
abstract mixin class _$PeriodicityChangeCopyWith<$Res> implements $PeriodicityChangeCopyWith<$Res> {
  factory _$PeriodicityChangeCopyWith(_PeriodicityChange value, $Res Function(_PeriodicityChange) _then) = __$PeriodicityChangeCopyWithImpl;
@override @useResult
$Res call({
 Periodicity periodicity, DateTime since
});




}
/// @nodoc
class __$PeriodicityChangeCopyWithImpl<$Res>
    implements _$PeriodicityChangeCopyWith<$Res> {
  __$PeriodicityChangeCopyWithImpl(this._self, this._then);

  final _PeriodicityChange _self;
  final $Res Function(_PeriodicityChange) _then;

/// Create a copy of PeriodicityChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodicity = null,Object? since = null,}) {
  return _then(_PeriodicityChange(
periodicity: null == periodicity ? _self.periodicity : periodicity // ignore: cast_nullable_to_non_nullable
as Periodicity,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
