// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'predefined_ambito.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PredefinedAmbito {

 String get id; String get name; String get emoji; int get colorValue; int get order;
/// Create a copy of PredefinedAmbito
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredefinedAmbitoCopyWith<PredefinedAmbito> get copyWith => _$PredefinedAmbitoCopyWithImpl<PredefinedAmbito>(this as PredefinedAmbito, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredefinedAmbito&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,colorValue,order);

@override
String toString() {
  return 'PredefinedAmbito(id: $id, name: $name, emoji: $emoji, colorValue: $colorValue, order: $order)';
}


}

/// @nodoc
abstract mixin class $PredefinedAmbitoCopyWith<$Res>  {
  factory $PredefinedAmbitoCopyWith(PredefinedAmbito value, $Res Function(PredefinedAmbito) _then) = _$PredefinedAmbitoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String emoji, int colorValue, int order
});




}
/// @nodoc
class _$PredefinedAmbitoCopyWithImpl<$Res>
    implements $PredefinedAmbitoCopyWith<$Res> {
  _$PredefinedAmbitoCopyWithImpl(this._self, this._then);

  final PredefinedAmbito _self;
  final $Res Function(PredefinedAmbito) _then;

/// Create a copy of PredefinedAmbito
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? colorValue = null,Object? order = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PredefinedAmbito].
extension PredefinedAmbitoPatterns on PredefinedAmbito {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredefinedAmbito value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredefinedAmbito() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredefinedAmbito value)  $default,){
final _that = this;
switch (_that) {
case _PredefinedAmbito():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredefinedAmbito value)?  $default,){
final _that = this;
switch (_that) {
case _PredefinedAmbito() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String emoji,  int colorValue,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredefinedAmbito() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.colorValue,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String emoji,  int colorValue,  int order)  $default,) {final _that = this;
switch (_that) {
case _PredefinedAmbito():
return $default(_that.id,_that.name,_that.emoji,_that.colorValue,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String emoji,  int colorValue,  int order)?  $default,) {final _that = this;
switch (_that) {
case _PredefinedAmbito() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.colorValue,_that.order);case _:
  return null;

}
}

}

/// @nodoc


class _PredefinedAmbito implements PredefinedAmbito {
  const _PredefinedAmbito({required this.id, required this.name, required this.emoji, required this.colorValue, required this.order});
  

@override final  String id;
@override final  String name;
@override final  String emoji;
@override final  int colorValue;
@override final  int order;

/// Create a copy of PredefinedAmbito
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredefinedAmbitoCopyWith<_PredefinedAmbito> get copyWith => __$PredefinedAmbitoCopyWithImpl<_PredefinedAmbito>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredefinedAmbito&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,colorValue,order);

@override
String toString() {
  return 'PredefinedAmbito(id: $id, name: $name, emoji: $emoji, colorValue: $colorValue, order: $order)';
}


}

/// @nodoc
abstract mixin class _$PredefinedAmbitoCopyWith<$Res> implements $PredefinedAmbitoCopyWith<$Res> {
  factory _$PredefinedAmbitoCopyWith(_PredefinedAmbito value, $Res Function(_PredefinedAmbito) _then) = __$PredefinedAmbitoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String emoji, int colorValue, int order
});




}
/// @nodoc
class __$PredefinedAmbitoCopyWithImpl<$Res>
    implements _$PredefinedAmbitoCopyWith<$Res> {
  __$PredefinedAmbitoCopyWithImpl(this._self, this._then);

  final _PredefinedAmbito _self;
  final $Res Function(_PredefinedAmbito) _then;

/// Create a copy of PredefinedAmbito
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? colorValue = null,Object? order = null,}) {
  return _then(_PredefinedAmbito(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
