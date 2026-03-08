// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'correction_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CorrectionRecord {

 String get id; String get matchRecordId; String get oldOrderEventId; String get newOrderEventId; String get reason; DateTime get correctedAt;
/// Create a copy of CorrectionRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorrectionRecordCopyWith<CorrectionRecord> get copyWith => _$CorrectionRecordCopyWithImpl<CorrectionRecord>(this as CorrectionRecord, _$identity);

  /// Serializes this CorrectionRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorrectionRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.matchRecordId, matchRecordId) || other.matchRecordId == matchRecordId)&&(identical(other.oldOrderEventId, oldOrderEventId) || other.oldOrderEventId == oldOrderEventId)&&(identical(other.newOrderEventId, newOrderEventId) || other.newOrderEventId == newOrderEventId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.correctedAt, correctedAt) || other.correctedAt == correctedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,matchRecordId,oldOrderEventId,newOrderEventId,reason,correctedAt);

@override
String toString() {
  return 'CorrectionRecord(id: $id, matchRecordId: $matchRecordId, oldOrderEventId: $oldOrderEventId, newOrderEventId: $newOrderEventId, reason: $reason, correctedAt: $correctedAt)';
}


}

/// @nodoc
abstract mixin class $CorrectionRecordCopyWith<$Res>  {
  factory $CorrectionRecordCopyWith(CorrectionRecord value, $Res Function(CorrectionRecord) _then) = _$CorrectionRecordCopyWithImpl;
@useResult
$Res call({
 String id, String matchRecordId, String oldOrderEventId, String newOrderEventId, String reason, DateTime correctedAt
});




}
/// @nodoc
class _$CorrectionRecordCopyWithImpl<$Res>
    implements $CorrectionRecordCopyWith<$Res> {
  _$CorrectionRecordCopyWithImpl(this._self, this._then);

  final CorrectionRecord _self;
  final $Res Function(CorrectionRecord) _then;

/// Create a copy of CorrectionRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? matchRecordId = null,Object? oldOrderEventId = null,Object? newOrderEventId = null,Object? reason = null,Object? correctedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,matchRecordId: null == matchRecordId ? _self.matchRecordId : matchRecordId // ignore: cast_nullable_to_non_nullable
as String,oldOrderEventId: null == oldOrderEventId ? _self.oldOrderEventId : oldOrderEventId // ignore: cast_nullable_to_non_nullable
as String,newOrderEventId: null == newOrderEventId ? _self.newOrderEventId : newOrderEventId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,correctedAt: null == correctedAt ? _self.correctedAt : correctedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CorrectionRecord].
extension CorrectionRecordPatterns on CorrectionRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorrectionRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorrectionRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorrectionRecord value)  $default,){
final _that = this;
switch (_that) {
case _CorrectionRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorrectionRecord value)?  $default,){
final _that = this;
switch (_that) {
case _CorrectionRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String matchRecordId,  String oldOrderEventId,  String newOrderEventId,  String reason,  DateTime correctedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorrectionRecord() when $default != null:
return $default(_that.id,_that.matchRecordId,_that.oldOrderEventId,_that.newOrderEventId,_that.reason,_that.correctedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String matchRecordId,  String oldOrderEventId,  String newOrderEventId,  String reason,  DateTime correctedAt)  $default,) {final _that = this;
switch (_that) {
case _CorrectionRecord():
return $default(_that.id,_that.matchRecordId,_that.oldOrderEventId,_that.newOrderEventId,_that.reason,_that.correctedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String matchRecordId,  String oldOrderEventId,  String newOrderEventId,  String reason,  DateTime correctedAt)?  $default,) {final _that = this;
switch (_that) {
case _CorrectionRecord() when $default != null:
return $default(_that.id,_that.matchRecordId,_that.oldOrderEventId,_that.newOrderEventId,_that.reason,_that.correctedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CorrectionRecord implements CorrectionRecord {
  const _CorrectionRecord({required this.id, required this.matchRecordId, required this.oldOrderEventId, required this.newOrderEventId, required this.reason, required this.correctedAt});
  factory _CorrectionRecord.fromJson(Map<String, dynamic> json) => _$CorrectionRecordFromJson(json);

@override final  String id;
@override final  String matchRecordId;
@override final  String oldOrderEventId;
@override final  String newOrderEventId;
@override final  String reason;
@override final  DateTime correctedAt;

/// Create a copy of CorrectionRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorrectionRecordCopyWith<_CorrectionRecord> get copyWith => __$CorrectionRecordCopyWithImpl<_CorrectionRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorrectionRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorrectionRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.matchRecordId, matchRecordId) || other.matchRecordId == matchRecordId)&&(identical(other.oldOrderEventId, oldOrderEventId) || other.oldOrderEventId == oldOrderEventId)&&(identical(other.newOrderEventId, newOrderEventId) || other.newOrderEventId == newOrderEventId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.correctedAt, correctedAt) || other.correctedAt == correctedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,matchRecordId,oldOrderEventId,newOrderEventId,reason,correctedAt);

@override
String toString() {
  return 'CorrectionRecord(id: $id, matchRecordId: $matchRecordId, oldOrderEventId: $oldOrderEventId, newOrderEventId: $newOrderEventId, reason: $reason, correctedAt: $correctedAt)';
}


}

/// @nodoc
abstract mixin class _$CorrectionRecordCopyWith<$Res> implements $CorrectionRecordCopyWith<$Res> {
  factory _$CorrectionRecordCopyWith(_CorrectionRecord value, $Res Function(_CorrectionRecord) _then) = __$CorrectionRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String matchRecordId, String oldOrderEventId, String newOrderEventId, String reason, DateTime correctedAt
});




}
/// @nodoc
class __$CorrectionRecordCopyWithImpl<$Res>
    implements _$CorrectionRecordCopyWith<$Res> {
  __$CorrectionRecordCopyWithImpl(this._self, this._then);

  final _CorrectionRecord _self;
  final $Res Function(_CorrectionRecord) _then;

/// Create a copy of CorrectionRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? matchRecordId = null,Object? oldOrderEventId = null,Object? newOrderEventId = null,Object? reason = null,Object? correctedAt = null,}) {
  return _then(_CorrectionRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,matchRecordId: null == matchRecordId ? _self.matchRecordId : matchRecordId // ignore: cast_nullable_to_non_nullable
as String,oldOrderEventId: null == oldOrderEventId ? _self.oldOrderEventId : oldOrderEventId // ignore: cast_nullable_to_non_nullable
as String,newOrderEventId: null == newOrderEventId ? _self.newOrderEventId : newOrderEventId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,correctedAt: null == correctedAt ? _self.correctedAt : correctedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
