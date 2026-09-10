// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NewUserProfile {

 String get userId; String get email; String? get displayName;/// Zona horaria IANA del dispositivo (p. ej. `Europe/Madrid`).
 String get timezone;/// `es` o `en`, únicos valores que aceptan las Security Rules.
 String get locale; List<PredefinedAmbito> get ambitos;
/// Create a copy of NewUserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewUserProfileCopyWith<NewUserProfile> get copyWith => _$NewUserProfileCopyWithImpl<NewUserProfile>(this as NewUserProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewUserProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other.ambitos, ambitos));
}


@override
int get hashCode => Object.hash(runtimeType,userId,email,displayName,timezone,locale,const DeepCollectionEquality().hash(ambitos));

@override
String toString() {
  return 'NewUserProfile(userId: $userId, email: $email, displayName: $displayName, timezone: $timezone, locale: $locale, ambitos: $ambitos)';
}


}

/// @nodoc
abstract mixin class $NewUserProfileCopyWith<$Res>  {
  factory $NewUserProfileCopyWith(NewUserProfile value, $Res Function(NewUserProfile) _then) = _$NewUserProfileCopyWithImpl;
@useResult
$Res call({
 String userId, String email, String? displayName, String timezone, String locale, List<PredefinedAmbito> ambitos
});




}
/// @nodoc
class _$NewUserProfileCopyWithImpl<$Res>
    implements $NewUserProfileCopyWith<$Res> {
  _$NewUserProfileCopyWithImpl(this._self, this._then);

  final NewUserProfile _self;
  final $Res Function(NewUserProfile) _then;

/// Create a copy of NewUserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? email = null,Object? displayName = freezed,Object? timezone = null,Object? locale = null,Object? ambitos = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,ambitos: null == ambitos ? _self.ambitos : ambitos // ignore: cast_nullable_to_non_nullable
as List<PredefinedAmbito>,
  ));
}

}


/// Adds pattern-matching-related methods to [NewUserProfile].
extension NewUserProfilePatterns on NewUserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewUserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewUserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewUserProfile value)  $default,){
final _that = this;
switch (_that) {
case _NewUserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewUserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _NewUserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String email,  String? displayName,  String timezone,  String locale,  List<PredefinedAmbito> ambitos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewUserProfile() when $default != null:
return $default(_that.userId,_that.email,_that.displayName,_that.timezone,_that.locale,_that.ambitos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String email,  String? displayName,  String timezone,  String locale,  List<PredefinedAmbito> ambitos)  $default,) {final _that = this;
switch (_that) {
case _NewUserProfile():
return $default(_that.userId,_that.email,_that.displayName,_that.timezone,_that.locale,_that.ambitos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String email,  String? displayName,  String timezone,  String locale,  List<PredefinedAmbito> ambitos)?  $default,) {final _that = this;
switch (_that) {
case _NewUserProfile() when $default != null:
return $default(_that.userId,_that.email,_that.displayName,_that.timezone,_that.locale,_that.ambitos);case _:
  return null;

}
}

}

/// @nodoc


class _NewUserProfile implements NewUserProfile {
  const _NewUserProfile({required this.userId, required this.email, this.displayName, required this.timezone, required this.locale, required final  List<PredefinedAmbito> ambitos}): _ambitos = ambitos;
  

@override final  String userId;
@override final  String email;
@override final  String? displayName;
/// Zona horaria IANA del dispositivo (p. ej. `Europe/Madrid`).
@override final  String timezone;
/// `es` o `en`, únicos valores que aceptan las Security Rules.
@override final  String locale;
 final  List<PredefinedAmbito> _ambitos;
@override List<PredefinedAmbito> get ambitos {
  if (_ambitos is EqualUnmodifiableListView) return _ambitos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ambitos);
}


/// Create a copy of NewUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewUserProfileCopyWith<_NewUserProfile> get copyWith => __$NewUserProfileCopyWithImpl<_NewUserProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewUserProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.locale, locale) || other.locale == locale)&&const DeepCollectionEquality().equals(other._ambitos, _ambitos));
}


@override
int get hashCode => Object.hash(runtimeType,userId,email,displayName,timezone,locale,const DeepCollectionEquality().hash(_ambitos));

@override
String toString() {
  return 'NewUserProfile(userId: $userId, email: $email, displayName: $displayName, timezone: $timezone, locale: $locale, ambitos: $ambitos)';
}


}

/// @nodoc
abstract mixin class _$NewUserProfileCopyWith<$Res> implements $NewUserProfileCopyWith<$Res> {
  factory _$NewUserProfileCopyWith(_NewUserProfile value, $Res Function(_NewUserProfile) _then) = __$NewUserProfileCopyWithImpl;
@override @useResult
$Res call({
 String userId, String email, String? displayName, String timezone, String locale, List<PredefinedAmbito> ambitos
});




}
/// @nodoc
class __$NewUserProfileCopyWithImpl<$Res>
    implements _$NewUserProfileCopyWith<$Res> {
  __$NewUserProfileCopyWithImpl(this._self, this._then);

  final _NewUserProfile _self;
  final $Res Function(_NewUserProfile) _then;

/// Create a copy of NewUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = null,Object? displayName = freezed,Object? timezone = null,Object? locale = null,Object? ambitos = null,}) {
  return _then(_NewUserProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,ambitos: null == ambitos ? _self._ambitos : ambitos // ignore: cast_nullable_to_non_nullable
as List<PredefinedAmbito>,
  ));
}


}

// dart format on
