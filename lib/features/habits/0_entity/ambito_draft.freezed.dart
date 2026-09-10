// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ambito_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AmbitoDraft {

 String get name; String get emoji; int get colorValue;
/// Create a copy of AmbitoDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmbitoDraftCopyWith<AmbitoDraft> get copyWith => _$AmbitoDraftCopyWithImpl<AmbitoDraft>(this as AmbitoDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AmbitoDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}


@override
int get hashCode => Object.hash(runtimeType,name,emoji,colorValue);

@override
String toString() {
  return 'AmbitoDraft(name: $name, emoji: $emoji, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class $AmbitoDraftCopyWith<$Res>  {
  factory $AmbitoDraftCopyWith(AmbitoDraft value, $Res Function(AmbitoDraft) _then) = _$AmbitoDraftCopyWithImpl;
@useResult
$Res call({
 String name, String emoji, int colorValue
});




}
/// @nodoc
class _$AmbitoDraftCopyWithImpl<$Res>
    implements $AmbitoDraftCopyWith<$Res> {
  _$AmbitoDraftCopyWithImpl(this._self, this._then);

  final AmbitoDraft _self;
  final $Res Function(AmbitoDraft) _then;

/// Create a copy of AmbitoDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? emoji = null,Object? colorValue = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AmbitoDraft].
extension AmbitoDraftPatterns on AmbitoDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AmbitoDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AmbitoDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AmbitoDraft value)  $default,){
final _that = this;
switch (_that) {
case _AmbitoDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AmbitoDraft value)?  $default,){
final _that = this;
switch (_that) {
case _AmbitoDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String emoji,  int colorValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AmbitoDraft() when $default != null:
return $default(_that.name,_that.emoji,_that.colorValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String emoji,  int colorValue)  $default,) {final _that = this;
switch (_that) {
case _AmbitoDraft():
return $default(_that.name,_that.emoji,_that.colorValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String emoji,  int colorValue)?  $default,) {final _that = this;
switch (_that) {
case _AmbitoDraft() when $default != null:
return $default(_that.name,_that.emoji,_that.colorValue);case _:
  return null;

}
}

}

/// @nodoc


class _AmbitoDraft implements AmbitoDraft {
  const _AmbitoDraft({required this.name, required this.emoji, required this.colorValue});
  

@override final  String name;
@override final  String emoji;
@override final  int colorValue;

/// Create a copy of AmbitoDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmbitoDraftCopyWith<_AmbitoDraft> get copyWith => __$AmbitoDraftCopyWithImpl<_AmbitoDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AmbitoDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue));
}


@override
int get hashCode => Object.hash(runtimeType,name,emoji,colorValue);

@override
String toString() {
  return 'AmbitoDraft(name: $name, emoji: $emoji, colorValue: $colorValue)';
}


}

/// @nodoc
abstract mixin class _$AmbitoDraftCopyWith<$Res> implements $AmbitoDraftCopyWith<$Res> {
  factory _$AmbitoDraftCopyWith(_AmbitoDraft value, $Res Function(_AmbitoDraft) _then) = __$AmbitoDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String emoji, int colorValue
});




}
/// @nodoc
class __$AmbitoDraftCopyWithImpl<$Res>
    implements _$AmbitoDraftCopyWith<$Res> {
  __$AmbitoDraftCopyWithImpl(this._self, this._then);

  final _AmbitoDraft _self;
  final $Res Function(_AmbitoDraft) _then;

/// Create a copy of AmbitoDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? emoji = null,Object? colorValue = null,}) {
  return _then(_AmbitoDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
