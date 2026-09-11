// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wildcard_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WildcardBalance {

/// Comodines disponibles ahora mismo, 0..[maxAvailable].
 int get available;/// Último mes en que se concedió el comodín gratuito, como `año*12+mes`.
/// Es monótono: nunca retrocede, lo que hace la concesión idempotente.
 int get lastGrantYearMonth;/// Total histórico concedido, solo para auditoría (§20).
 int get grantedTotal;/// Último día protegido. Las Security Rules lo usan para atar el
/// decremento del saldo a la creación del día protegido (§25).
 LogicalDate? get lastProtectedDay;
/// Create a copy of WildcardBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WildcardBalanceCopyWith<WildcardBalance> get copyWith => _$WildcardBalanceCopyWithImpl<WildcardBalance>(this as WildcardBalance, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WildcardBalance&&(identical(other.available, available) || other.available == available)&&(identical(other.lastGrantYearMonth, lastGrantYearMonth) || other.lastGrantYearMonth == lastGrantYearMonth)&&(identical(other.grantedTotal, grantedTotal) || other.grantedTotal == grantedTotal)&&(identical(other.lastProtectedDay, lastProtectedDay) || other.lastProtectedDay == lastProtectedDay));
}


@override
int get hashCode => Object.hash(runtimeType,available,lastGrantYearMonth,grantedTotal,lastProtectedDay);

@override
String toString() {
  return 'WildcardBalance(available: $available, lastGrantYearMonth: $lastGrantYearMonth, grantedTotal: $grantedTotal, lastProtectedDay: $lastProtectedDay)';
}


}

/// @nodoc
abstract mixin class $WildcardBalanceCopyWith<$Res>  {
  factory $WildcardBalanceCopyWith(WildcardBalance value, $Res Function(WildcardBalance) _then) = _$WildcardBalanceCopyWithImpl;
@useResult
$Res call({
 int available, int lastGrantYearMonth, int grantedTotal, LogicalDate? lastProtectedDay
});




}
/// @nodoc
class _$WildcardBalanceCopyWithImpl<$Res>
    implements $WildcardBalanceCopyWith<$Res> {
  _$WildcardBalanceCopyWithImpl(this._self, this._then);

  final WildcardBalance _self;
  final $Res Function(WildcardBalance) _then;

/// Create a copy of WildcardBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? available = null,Object? lastGrantYearMonth = null,Object? grantedTotal = null,Object? lastProtectedDay = freezed,}) {
  return _then(_self.copyWith(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as int,lastGrantYearMonth: null == lastGrantYearMonth ? _self.lastGrantYearMonth : lastGrantYearMonth // ignore: cast_nullable_to_non_nullable
as int,grantedTotal: null == grantedTotal ? _self.grantedTotal : grantedTotal // ignore: cast_nullable_to_non_nullable
as int,lastProtectedDay: freezed == lastProtectedDay ? _self.lastProtectedDay : lastProtectedDay // ignore: cast_nullable_to_non_nullable
as LogicalDate?,
  ));
}

}


/// Adds pattern-matching-related methods to [WildcardBalance].
extension WildcardBalancePatterns on WildcardBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WildcardBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WildcardBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WildcardBalance value)  $default,){
final _that = this;
switch (_that) {
case _WildcardBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WildcardBalance value)?  $default,){
final _that = this;
switch (_that) {
case _WildcardBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int available,  int lastGrantYearMonth,  int grantedTotal,  LogicalDate? lastProtectedDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WildcardBalance() when $default != null:
return $default(_that.available,_that.lastGrantYearMonth,_that.grantedTotal,_that.lastProtectedDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int available,  int lastGrantYearMonth,  int grantedTotal,  LogicalDate? lastProtectedDay)  $default,) {final _that = this;
switch (_that) {
case _WildcardBalance():
return $default(_that.available,_that.lastGrantYearMonth,_that.grantedTotal,_that.lastProtectedDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int available,  int lastGrantYearMonth,  int grantedTotal,  LogicalDate? lastProtectedDay)?  $default,) {final _that = this;
switch (_that) {
case _WildcardBalance() when $default != null:
return $default(_that.available,_that.lastGrantYearMonth,_that.grantedTotal,_that.lastProtectedDay);case _:
  return null;

}
}

}

/// @nodoc


class _WildcardBalance extends WildcardBalance {
  const _WildcardBalance({this.available = 0, this.lastGrantYearMonth = 0, this.grantedTotal = 0, this.lastProtectedDay}): super._();
  

/// Comodines disponibles ahora mismo, 0..[maxAvailable].
@override@JsonKey() final  int available;
/// Último mes en que se concedió el comodín gratuito, como `año*12+mes`.
/// Es monótono: nunca retrocede, lo que hace la concesión idempotente.
@override@JsonKey() final  int lastGrantYearMonth;
/// Total histórico concedido, solo para auditoría (§20).
@override@JsonKey() final  int grantedTotal;
/// Último día protegido. Las Security Rules lo usan para atar el
/// decremento del saldo a la creación del día protegido (§25).
@override final  LogicalDate? lastProtectedDay;

/// Create a copy of WildcardBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WildcardBalanceCopyWith<_WildcardBalance> get copyWith => __$WildcardBalanceCopyWithImpl<_WildcardBalance>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WildcardBalance&&(identical(other.available, available) || other.available == available)&&(identical(other.lastGrantYearMonth, lastGrantYearMonth) || other.lastGrantYearMonth == lastGrantYearMonth)&&(identical(other.grantedTotal, grantedTotal) || other.grantedTotal == grantedTotal)&&(identical(other.lastProtectedDay, lastProtectedDay) || other.lastProtectedDay == lastProtectedDay));
}


@override
int get hashCode => Object.hash(runtimeType,available,lastGrantYearMonth,grantedTotal,lastProtectedDay);

@override
String toString() {
  return 'WildcardBalance(available: $available, lastGrantYearMonth: $lastGrantYearMonth, grantedTotal: $grantedTotal, lastProtectedDay: $lastProtectedDay)';
}


}

/// @nodoc
abstract mixin class _$WildcardBalanceCopyWith<$Res> implements $WildcardBalanceCopyWith<$Res> {
  factory _$WildcardBalanceCopyWith(_WildcardBalance value, $Res Function(_WildcardBalance) _then) = __$WildcardBalanceCopyWithImpl;
@override @useResult
$Res call({
 int available, int lastGrantYearMonth, int grantedTotal, LogicalDate? lastProtectedDay
});




}
/// @nodoc
class __$WildcardBalanceCopyWithImpl<$Res>
    implements _$WildcardBalanceCopyWith<$Res> {
  __$WildcardBalanceCopyWithImpl(this._self, this._then);

  final _WildcardBalance _self;
  final $Res Function(_WildcardBalance) _then;

/// Create a copy of WildcardBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? available = null,Object? lastGrantYearMonth = null,Object? grantedTotal = null,Object? lastProtectedDay = freezed,}) {
  return _then(_WildcardBalance(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as int,lastGrantYearMonth: null == lastGrantYearMonth ? _self.lastGrantYearMonth : lastGrantYearMonth // ignore: cast_nullable_to_non_nullable
as int,grantedTotal: null == grantedTotal ? _self.grantedTotal : grantedTotal // ignore: cast_nullable_to_non_nullable
as int,lastProtectedDay: freezed == lastProtectedDay ? _self.lastProtectedDay : lastProtectedDay // ignore: cast_nullable_to_non_nullable
as LogicalDate?,
  ));
}


}

/// @nodoc
mixin _$ProtectedDay {

 LogicalDate get day; DateTime? get createdAt;
/// Create a copy of ProtectedDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProtectedDayCopyWith<ProtectedDay> get copyWith => _$ProtectedDayCopyWithImpl<ProtectedDay>(this as ProtectedDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProtectedDay&&(identical(other.day, day) || other.day == day)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,day,createdAt);

@override
String toString() {
  return 'ProtectedDay(day: $day, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProtectedDayCopyWith<$Res>  {
  factory $ProtectedDayCopyWith(ProtectedDay value, $Res Function(ProtectedDay) _then) = _$ProtectedDayCopyWithImpl;
@useResult
$Res call({
 LogicalDate day, DateTime? createdAt
});




}
/// @nodoc
class _$ProtectedDayCopyWithImpl<$Res>
    implements $ProtectedDayCopyWith<$Res> {
  _$ProtectedDayCopyWithImpl(this._self, this._then);

  final ProtectedDay _self;
  final $Res Function(ProtectedDay) _then;

/// Create a copy of ProtectedDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LogicalDate,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProtectedDay].
extension ProtectedDayPatterns on ProtectedDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProtectedDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProtectedDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProtectedDay value)  $default,){
final _that = this;
switch (_that) {
case _ProtectedDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProtectedDay value)?  $default,){
final _that = this;
switch (_that) {
case _ProtectedDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LogicalDate day,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProtectedDay() when $default != null:
return $default(_that.day,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LogicalDate day,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProtectedDay():
return $default(_that.day,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LogicalDate day,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProtectedDay() when $default != null:
return $default(_that.day,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProtectedDay implements ProtectedDay {
  const _ProtectedDay({required this.day, this.createdAt});
  

@override final  LogicalDate day;
@override final  DateTime? createdAt;

/// Create a copy of ProtectedDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProtectedDayCopyWith<_ProtectedDay> get copyWith => __$ProtectedDayCopyWithImpl<_ProtectedDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProtectedDay&&(identical(other.day, day) || other.day == day)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,day,createdAt);

@override
String toString() {
  return 'ProtectedDay(day: $day, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProtectedDayCopyWith<$Res> implements $ProtectedDayCopyWith<$Res> {
  factory _$ProtectedDayCopyWith(_ProtectedDay value, $Res Function(_ProtectedDay) _then) = __$ProtectedDayCopyWithImpl;
@override @useResult
$Res call({
 LogicalDate day, DateTime? createdAt
});




}
/// @nodoc
class __$ProtectedDayCopyWithImpl<$Res>
    implements _$ProtectedDayCopyWith<$Res> {
  __$ProtectedDayCopyWithImpl(this._self, this._then);

  final _ProtectedDay _self;
  final $Res Function(_ProtectedDay) _then;

/// Create a copy of ProtectedDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? createdAt = freezed,}) {
  return _then(_ProtectedDay(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LogicalDate,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
