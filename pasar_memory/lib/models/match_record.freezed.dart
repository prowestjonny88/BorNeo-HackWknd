// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchRecord {

 String get id; String get paymentEventId; String get orderEventId; double get confidenceScore; List<String> get reasons; DateTime get matchedAt; bool get isManualCorrection;
/// Create a copy of MatchRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchRecordCopyWith<MatchRecord> get copyWith => _$MatchRecordCopyWithImpl<MatchRecord>(this as MatchRecord, _$identity);

  /// Serializes this MatchRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.paymentEventId, paymentEventId) || other.paymentEventId == paymentEventId)&&(identical(other.orderEventId, orderEventId) || other.orderEventId == orderEventId)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&const DeepCollectionEquality().equals(other.reasons, reasons)&&(identical(other.matchedAt, matchedAt) || other.matchedAt == matchedAt)&&(identical(other.isManualCorrection, isManualCorrection) || other.isManualCorrection == isManualCorrection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,paymentEventId,orderEventId,confidenceScore,const DeepCollectionEquality().hash(reasons),matchedAt,isManualCorrection);

@override
String toString() {
  return 'MatchRecord(id: $id, paymentEventId: $paymentEventId, orderEventId: $orderEventId, confidenceScore: $confidenceScore, reasons: $reasons, matchedAt: $matchedAt, isManualCorrection: $isManualCorrection)';
}


}

/// @nodoc
abstract mixin class $MatchRecordCopyWith<$Res>  {
  factory $MatchRecordCopyWith(MatchRecord value, $Res Function(MatchRecord) _then) = _$MatchRecordCopyWithImpl;
@useResult
$Res call({
 String id, String paymentEventId, String orderEventId, double confidenceScore, List<String> reasons, DateTime matchedAt, bool isManualCorrection
});




}
/// @nodoc
class _$MatchRecordCopyWithImpl<$Res>
    implements $MatchRecordCopyWith<$Res> {
  _$MatchRecordCopyWithImpl(this._self, this._then);

  final MatchRecord _self;
  final $Res Function(MatchRecord) _then;

/// Create a copy of MatchRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? paymentEventId = null,Object? orderEventId = null,Object? confidenceScore = null,Object? reasons = null,Object? matchedAt = null,Object? isManualCorrection = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,paymentEventId: null == paymentEventId ? _self.paymentEventId : paymentEventId // ignore: cast_nullable_to_non_nullable
as String,orderEventId: null == orderEventId ? _self.orderEventId : orderEventId // ignore: cast_nullable_to_non_nullable
as String,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,matchedAt: null == matchedAt ? _self.matchedAt : matchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isManualCorrection: null == isManualCorrection ? _self.isManualCorrection : isManualCorrection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchRecord].
extension MatchRecordPatterns on MatchRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchRecord value)  $default,){
final _that = this;
switch (_that) {
case _MatchRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchRecord value)?  $default,){
final _that = this;
switch (_that) {
case _MatchRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String paymentEventId,  String orderEventId,  double confidenceScore,  List<String> reasons,  DateTime matchedAt,  bool isManualCorrection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchRecord() when $default != null:
return $default(_that.id,_that.paymentEventId,_that.orderEventId,_that.confidenceScore,_that.reasons,_that.matchedAt,_that.isManualCorrection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String paymentEventId,  String orderEventId,  double confidenceScore,  List<String> reasons,  DateTime matchedAt,  bool isManualCorrection)  $default,) {final _that = this;
switch (_that) {
case _MatchRecord():
return $default(_that.id,_that.paymentEventId,_that.orderEventId,_that.confidenceScore,_that.reasons,_that.matchedAt,_that.isManualCorrection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String paymentEventId,  String orderEventId,  double confidenceScore,  List<String> reasons,  DateTime matchedAt,  bool isManualCorrection)?  $default,) {final _that = this;
switch (_that) {
case _MatchRecord() when $default != null:
return $default(_that.id,_that.paymentEventId,_that.orderEventId,_that.confidenceScore,_that.reasons,_that.matchedAt,_that.isManualCorrection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchRecord implements MatchRecord {
  const _MatchRecord({required this.id, required this.paymentEventId, required this.orderEventId, required this.confidenceScore, required final  List<String> reasons, required this.matchedAt, this.isManualCorrection = false}): _reasons = reasons;
  factory _MatchRecord.fromJson(Map<String, dynamic> json) => _$MatchRecordFromJson(json);

@override final  String id;
@override final  String paymentEventId;
@override final  String orderEventId;
@override final  double confidenceScore;
 final  List<String> _reasons;
@override List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

@override final  DateTime matchedAt;
@override@JsonKey() final  bool isManualCorrection;

/// Create a copy of MatchRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchRecordCopyWith<_MatchRecord> get copyWith => __$MatchRecordCopyWithImpl<_MatchRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.paymentEventId, paymentEventId) || other.paymentEventId == paymentEventId)&&(identical(other.orderEventId, orderEventId) || other.orderEventId == orderEventId)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&const DeepCollectionEquality().equals(other._reasons, _reasons)&&(identical(other.matchedAt, matchedAt) || other.matchedAt == matchedAt)&&(identical(other.isManualCorrection, isManualCorrection) || other.isManualCorrection == isManualCorrection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,paymentEventId,orderEventId,confidenceScore,const DeepCollectionEquality().hash(_reasons),matchedAt,isManualCorrection);

@override
String toString() {
  return 'MatchRecord(id: $id, paymentEventId: $paymentEventId, orderEventId: $orderEventId, confidenceScore: $confidenceScore, reasons: $reasons, matchedAt: $matchedAt, isManualCorrection: $isManualCorrection)';
}


}

/// @nodoc
abstract mixin class _$MatchRecordCopyWith<$Res> implements $MatchRecordCopyWith<$Res> {
  factory _$MatchRecordCopyWith(_MatchRecord value, $Res Function(_MatchRecord) _then) = __$MatchRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String paymentEventId, String orderEventId, double confidenceScore, List<String> reasons, DateTime matchedAt, bool isManualCorrection
});




}
/// @nodoc
class __$MatchRecordCopyWithImpl<$Res>
    implements _$MatchRecordCopyWith<$Res> {
  __$MatchRecordCopyWithImpl(this._self, this._then);

  final _MatchRecord _self;
  final $Res Function(_MatchRecord) _then;

/// Create a copy of MatchRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? paymentEventId = null,Object? orderEventId = null,Object? confidenceScore = null,Object? reasons = null,Object? matchedAt = null,Object? isManualCorrection = null,}) {
  return _then(_MatchRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,paymentEventId: null == paymentEventId ? _self.paymentEventId : paymentEventId // ignore: cast_nullable_to_non_nullable
as String,orderEventId: null == orderEventId ? _self.orderEventId : orderEventId // ignore: cast_nullable_to_non_nullable
as String,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,matchedAt: null == matchedAt ? _self.matchedAt : matchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isManualCorrection: null == isManualCorrection ? _self.isManualCorrection : isManualCorrection // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
