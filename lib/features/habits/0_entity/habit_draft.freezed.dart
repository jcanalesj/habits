// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitDraft {

 String get name; String get ambitoId; Periodicity get periodicity; int get colorValue; String get emoji; String? get reminderTime;
/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitDraftCopyWith<HabitDraft> get copyWith => _$HabitDraftCopyWithImpl<HabitDraft>(this as HabitDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.ambitoId, ambitoId) || other.ambitoId == ambitoId)&&(identical(other.periodicity, periodicity) || other.periodicity == periodicity)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime));
}


@override
int get hashCode => Object.hash(runtimeType,name,ambitoId,periodicity,colorValue,emoji,reminderTime);

@override
String toString() {
  return 'HabitDraft(name: $name, ambitoId: $ambitoId, periodicity: $periodicity, colorValue: $colorValue, emoji: $emoji, reminderTime: $reminderTime)';
}


}

/// @nodoc
abstract mixin class $HabitDraftCopyWith<$Res>  {
  factory $HabitDraftCopyWith(HabitDraft value, $Res Function(HabitDraft) _then) = _$HabitDraftCopyWithImpl;
@useResult
$Res call({
 String name, String ambitoId, Periodicity periodicity, int colorValue, String emoji, String? reminderTime
});


$PeriodicityCopyWith<$Res> get periodicity;

}
/// @nodoc
class _$HabitDraftCopyWithImpl<$Res>
    implements $HabitDraftCopyWith<$Res> {
  _$HabitDraftCopyWithImpl(this._self, this._then);

  final HabitDraft _self;
  final $Res Function(HabitDraft) _then;

/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? ambitoId = null,Object? periodicity = null,Object? colorValue = null,Object? emoji = null,Object? reminderTime = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ambitoId: null == ambitoId ? _self.ambitoId : ambitoId // ignore: cast_nullable_to_non_nullable
as String,periodicity: null == periodicity ? _self.periodicity : periodicity // ignore: cast_nullable_to_non_nullable
as Periodicity,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,reminderTime: freezed == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodicityCopyWith<$Res> get periodicity {
  
  return $PeriodicityCopyWith<$Res>(_self.periodicity, (value) {
    return _then(_self.copyWith(periodicity: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitDraft].
extension HabitDraftPatterns on HabitDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitDraft value)  $default,){
final _that = this;
switch (_that) {
case _HabitDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitDraft value)?  $default,){
final _that = this;
switch (_that) {
case _HabitDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String ambitoId,  Periodicity periodicity,  int colorValue,  String emoji,  String? reminderTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitDraft() when $default != null:
return $default(_that.name,_that.ambitoId,_that.periodicity,_that.colorValue,_that.emoji,_that.reminderTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String ambitoId,  Periodicity periodicity,  int colorValue,  String emoji,  String? reminderTime)  $default,) {final _that = this;
switch (_that) {
case _HabitDraft():
return $default(_that.name,_that.ambitoId,_that.periodicity,_that.colorValue,_that.emoji,_that.reminderTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String ambitoId,  Periodicity periodicity,  int colorValue,  String emoji,  String? reminderTime)?  $default,) {final _that = this;
switch (_that) {
case _HabitDraft() when $default != null:
return $default(_that.name,_that.ambitoId,_that.periodicity,_that.colorValue,_that.emoji,_that.reminderTime);case _:
  return null;

}
}

}

/// @nodoc


class _HabitDraft implements HabitDraft {
  const _HabitDraft({required this.name, required this.ambitoId, this.periodicity = Periodicity.daily, required this.colorValue, required this.emoji, this.reminderTime});
  

@override final  String name;
@override final  String ambitoId;
@override@JsonKey() final  Periodicity periodicity;
@override final  int colorValue;
@override final  String emoji;
@override final  String? reminderTime;

/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitDraftCopyWith<_HabitDraft> get copyWith => __$HabitDraftCopyWithImpl<_HabitDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.ambitoId, ambitoId) || other.ambitoId == ambitoId)&&(identical(other.periodicity, periodicity) || other.periodicity == periodicity)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.reminderTime, reminderTime) || other.reminderTime == reminderTime));
}


@override
int get hashCode => Object.hash(runtimeType,name,ambitoId,periodicity,colorValue,emoji,reminderTime);

@override
String toString() {
  return 'HabitDraft(name: $name, ambitoId: $ambitoId, periodicity: $periodicity, colorValue: $colorValue, emoji: $emoji, reminderTime: $reminderTime)';
}


}

/// @nodoc
abstract mixin class _$HabitDraftCopyWith<$Res> implements $HabitDraftCopyWith<$Res> {
  factory _$HabitDraftCopyWith(_HabitDraft value, $Res Function(_HabitDraft) _then) = __$HabitDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String ambitoId, Periodicity periodicity, int colorValue, String emoji, String? reminderTime
});


@override $PeriodicityCopyWith<$Res> get periodicity;

}
/// @nodoc
class __$HabitDraftCopyWithImpl<$Res>
    implements _$HabitDraftCopyWith<$Res> {
  __$HabitDraftCopyWithImpl(this._self, this._then);

  final _HabitDraft _self;
  final $Res Function(_HabitDraft) _then;

/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? ambitoId = null,Object? periodicity = null,Object? colorValue = null,Object? emoji = null,Object? reminderTime = freezed,}) {
  return _then(_HabitDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ambitoId: null == ambitoId ? _self.ambitoId : ambitoId // ignore: cast_nullable_to_non_nullable
as String,periodicity: null == periodicity ? _self.periodicity : periodicity // ignore: cast_nullable_to_non_nullable
as Periodicity,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,reminderTime: freezed == reminderTime ? _self.reminderTime : reminderTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HabitDraft
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
