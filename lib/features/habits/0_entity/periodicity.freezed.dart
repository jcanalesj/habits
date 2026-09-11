// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'periodicity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Periodicity {

 PeriodicityType get type; int get timesPerPeriod;
/// Create a copy of Periodicity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodicityCopyWith<Periodicity> get copyWith => _$PeriodicityCopyWithImpl<Periodicity>(this as Periodicity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Periodicity&&(identical(other.type, type) || other.type == type)&&(identical(other.timesPerPeriod, timesPerPeriod) || other.timesPerPeriod == timesPerPeriod));
}


@override
int get hashCode => Object.hash(runtimeType,type,timesPerPeriod);

@override
String toString() {
  return 'Periodicity(type: $type, timesPerPeriod: $timesPerPeriod)';
}


}

/// @nodoc
abstract mixin class $PeriodicityCopyWith<$Res>  {
  factory $PeriodicityCopyWith(Periodicity value, $Res Function(Periodicity) _then) = _$PeriodicityCopyWithImpl;
@useResult
$Res call({
 PeriodicityType type, int timesPerPeriod
});




}
/// @nodoc
class _$PeriodicityCopyWithImpl<$Res>
    implements $PeriodicityCopyWith<$Res> {
  _$PeriodicityCopyWithImpl(this._self, this._then);

  final Periodicity _self;
  final $Res Function(Periodicity) _then;

/// Create a copy of Periodicity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? timesPerPeriod = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PeriodicityType,timesPerPeriod: null == timesPerPeriod ? _self.timesPerPeriod : timesPerPeriod // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Periodicity].
extension PeriodicityPatterns on Periodicity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Periodicity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Periodicity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Periodicity value)  $default,){
final _that = this;
switch (_that) {
case _Periodicity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Periodicity value)?  $default,){
final _that = this;
switch (_that) {
case _Periodicity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PeriodicityType type,  int timesPerPeriod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Periodicity() when $default != null:
return $default(_that.type,_that.timesPerPeriod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PeriodicityType type,  int timesPerPeriod)  $default,) {final _that = this;
switch (_that) {
case _Periodicity():
return $default(_that.type,_that.timesPerPeriod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PeriodicityType type,  int timesPerPeriod)?  $default,) {final _that = this;
switch (_that) {
case _Periodicity() when $default != null:
return $default(_that.type,_that.timesPerPeriod);case _:
  return null;

}
}

}

/// @nodoc


class _Periodicity extends Periodicity {
  const _Periodicity({required this.type, this.timesPerPeriod = 1}): super._();
  

@override final  PeriodicityType type;
@override@JsonKey() final  int timesPerPeriod;

/// Create a copy of Periodicity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodicityCopyWith<_Periodicity> get copyWith => __$PeriodicityCopyWithImpl<_Periodicity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Periodicity&&(identical(other.type, type) || other.type == type)&&(identical(other.timesPerPeriod, timesPerPeriod) || other.timesPerPeriod == timesPerPeriod));
}


@override
int get hashCode => Object.hash(runtimeType,type,timesPerPeriod);

@override
String toString() {
  return 'Periodicity(type: $type, timesPerPeriod: $timesPerPeriod)';
}


}

/// @nodoc
abstract mixin class _$PeriodicityCopyWith<$Res> implements $PeriodicityCopyWith<$Res> {
  factory _$PeriodicityCopyWith(_Periodicity value, $Res Function(_Periodicity) _then) = __$PeriodicityCopyWithImpl;
@override @useResult
$Res call({
 PeriodicityType type, int timesPerPeriod
});




}
/// @nodoc
class __$PeriodicityCopyWithImpl<$Res>
    implements _$PeriodicityCopyWith<$Res> {
  __$PeriodicityCopyWithImpl(this._self, this._then);

  final _Periodicity _self;
  final $Res Function(_Periodicity) _then;

/// Create a copy of Periodicity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? timesPerPeriod = null,}) {
  return _then(_Periodicity(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PeriodicityType,timesPerPeriod: null == timesPerPeriod ? _self.timesPerPeriod : timesPerPeriod // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PeriodicityEntry {

 Periodicity get periodicity; LogicalDate get since;
/// Create a copy of PeriodicityEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodicityEntryCopyWith<PeriodicityEntry> get copyWith => _$PeriodicityEntryCopyWithImpl<PeriodicityEntry>(this as PeriodicityEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodicityEntry&&(identical(other.periodicity, periodicity) || other.periodicity == periodicity)&&(identical(other.since, since) || other.since == since));
}


@override
int get hashCode => Object.hash(runtimeType,periodicity,since);

@override
String toString() {
  return 'PeriodicityEntry(periodicity: $periodicity, since: $since)';
}


}

/// @nodoc
abstract mixin class $PeriodicityEntryCopyWith<$Res>  {
  factory $PeriodicityEntryCopyWith(PeriodicityEntry value, $Res Function(PeriodicityEntry) _then) = _$PeriodicityEntryCopyWithImpl;
@useResult
$Res call({
 Periodicity periodicity, LogicalDate since
});


$PeriodicityCopyWith<$Res> get periodicity;

}
/// @nodoc
class _$PeriodicityEntryCopyWithImpl<$Res>
    implements $PeriodicityEntryCopyWith<$Res> {
  _$PeriodicityEntryCopyWithImpl(this._self, this._then);

  final PeriodicityEntry _self;
  final $Res Function(PeriodicityEntry) _then;

/// Create a copy of PeriodicityEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodicity = null,Object? since = null,}) {
  return _then(_self.copyWith(
periodicity: null == periodicity ? _self.periodicity : periodicity // ignore: cast_nullable_to_non_nullable
as Periodicity,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as LogicalDate,
  ));
}
/// Create a copy of PeriodicityEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodicityCopyWith<$Res> get periodicity {
  
  return $PeriodicityCopyWith<$Res>(_self.periodicity, (value) {
    return _then(_self.copyWith(periodicity: value));
  });
}
}


/// Adds pattern-matching-related methods to [PeriodicityEntry].
extension PeriodicityEntryPatterns on PeriodicityEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodicityEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodicityEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodicityEntry value)  $default,){
final _that = this;
switch (_that) {
case _PeriodicityEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodicityEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodicityEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Periodicity periodicity,  LogicalDate since)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodicityEntry() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Periodicity periodicity,  LogicalDate since)  $default,) {final _that = this;
switch (_that) {
case _PeriodicityEntry():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Periodicity periodicity,  LogicalDate since)?  $default,) {final _that = this;
switch (_that) {
case _PeriodicityEntry() when $default != null:
return $default(_that.periodicity,_that.since);case _:
  return null;

}
}

}

/// @nodoc


class _PeriodicityEntry implements PeriodicityEntry {
  const _PeriodicityEntry({required this.periodicity, required this.since});
  

@override final  Periodicity periodicity;
@override final  LogicalDate since;

/// Create a copy of PeriodicityEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodicityEntryCopyWith<_PeriodicityEntry> get copyWith => __$PeriodicityEntryCopyWithImpl<_PeriodicityEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodicityEntry&&(identical(other.periodicity, periodicity) || other.periodicity == periodicity)&&(identical(other.since, since) || other.since == since));
}


@override
int get hashCode => Object.hash(runtimeType,periodicity,since);

@override
String toString() {
  return 'PeriodicityEntry(periodicity: $periodicity, since: $since)';
}


}

/// @nodoc
abstract mixin class _$PeriodicityEntryCopyWith<$Res> implements $PeriodicityEntryCopyWith<$Res> {
  factory _$PeriodicityEntryCopyWith(_PeriodicityEntry value, $Res Function(_PeriodicityEntry) _then) = __$PeriodicityEntryCopyWithImpl;
@override @useResult
$Res call({
 Periodicity periodicity, LogicalDate since
});


@override $PeriodicityCopyWith<$Res> get periodicity;

}
/// @nodoc
class __$PeriodicityEntryCopyWithImpl<$Res>
    implements _$PeriodicityEntryCopyWith<$Res> {
  __$PeriodicityEntryCopyWithImpl(this._self, this._then);

  final _PeriodicityEntry _self;
  final $Res Function(_PeriodicityEntry) _then;

/// Create a copy of PeriodicityEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodicity = null,Object? since = null,}) {
  return _then(_PeriodicityEntry(
periodicity: null == periodicity ? _self.periodicity : periodicity // ignore: cast_nullable_to_non_nullable
as Periodicity,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as LogicalDate,
  ));
}

/// Create a copy of PeriodicityEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodicityCopyWith<$Res> get periodicity {
  
  return $PeriodicityCopyWith<$Res>(_self.periodicity, (value) {
    return _then(_self.copyWith(periodicity: value));
  });
}
}

// dart format on
