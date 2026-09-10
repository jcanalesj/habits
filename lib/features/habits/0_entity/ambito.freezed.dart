// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ambito.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Ambito {

 String get id; String get name; String get emoji; int get colorValue; bool get isPredefined; int get order; DateTime? get createdAt;
/// Create a copy of Ambito
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmbitoCopyWith<Ambito> get copyWith => _$AmbitoCopyWithImpl<Ambito>(this as Ambito, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ambito&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.isPredefined, isPredefined) || other.isPredefined == isPredefined)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,colorValue,isPredefined,order,createdAt);

@override
String toString() {
  return 'Ambito(id: $id, name: $name, emoji: $emoji, colorValue: $colorValue, isPredefined: $isPredefined, order: $order, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AmbitoCopyWith<$Res>  {
  factory $AmbitoCopyWith(Ambito value, $Res Function(Ambito) _then) = _$AmbitoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String emoji, int colorValue, bool isPredefined, int order, DateTime? createdAt
});




}
/// @nodoc
class _$AmbitoCopyWithImpl<$Res>
    implements $AmbitoCopyWith<$Res> {
  _$AmbitoCopyWithImpl(this._self, this._then);

  final Ambito _self;
  final $Res Function(Ambito) _then;

/// Create a copy of Ambito
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? colorValue = null,Object? isPredefined = null,Object? order = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,isPredefined: null == isPredefined ? _self.isPredefined : isPredefined // ignore: cast_nullable_to_non_nullable
as bool,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Ambito].
extension AmbitoPatterns on Ambito {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ambito value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ambito() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ambito value)  $default,){
final _that = this;
switch (_that) {
case _Ambito():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ambito value)?  $default,){
final _that = this;
switch (_that) {
case _Ambito() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String emoji,  int colorValue,  bool isPredefined,  int order,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ambito() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.colorValue,_that.isPredefined,_that.order,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String emoji,  int colorValue,  bool isPredefined,  int order,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Ambito():
return $default(_that.id,_that.name,_that.emoji,_that.colorValue,_that.isPredefined,_that.order,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String emoji,  int colorValue,  bool isPredefined,  int order,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Ambito() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.colorValue,_that.isPredefined,_that.order,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Ambito extends Ambito {
  const _Ambito({required this.id, required this.name, required this.emoji, required this.colorValue, this.isPredefined = false, this.order = 0, this.createdAt}): super._();
  

@override final  String id;
@override final  String name;
@override final  String emoji;
@override final  int colorValue;
@override@JsonKey() final  bool isPredefined;
@override@JsonKey() final  int order;
@override final  DateTime? createdAt;

/// Create a copy of Ambito
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmbitoCopyWith<_Ambito> get copyWith => __$AmbitoCopyWithImpl<_Ambito>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ambito&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.isPredefined, isPredefined) || other.isPredefined == isPredefined)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,colorValue,isPredefined,order,createdAt);

@override
String toString() {
  return 'Ambito(id: $id, name: $name, emoji: $emoji, colorValue: $colorValue, isPredefined: $isPredefined, order: $order, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AmbitoCopyWith<$Res> implements $AmbitoCopyWith<$Res> {
  factory _$AmbitoCopyWith(_Ambito value, $Res Function(_Ambito) _then) = __$AmbitoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String emoji, int colorValue, bool isPredefined, int order, DateTime? createdAt
});




}
/// @nodoc
class __$AmbitoCopyWithImpl<$Res>
    implements _$AmbitoCopyWith<$Res> {
  __$AmbitoCopyWithImpl(this._self, this._then);

  final _Ambito _self;
  final $Res Function(_Ambito) _then;

/// Create a copy of Ambito
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? emoji = null,Object? colorValue = null,Object? isPredefined = null,Object? order = null,Object? createdAt = freezed,}) {
  return _then(_Ambito(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,isPredefined: null == isPredefined ? _self.isPredefined : isPredefined // ignore: cast_nullable_to_non_nullable
as bool,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
