// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentEvent {

 String get id; String get evidenceId; double get amount; DateTime get timestamp; String get providerName; String get referenceNumber; String get rawText; double get extractionConfidence; String get status;
/// Create a copy of PaymentEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentEventCopyWith<PaymentEvent> get copyWith => _$PaymentEventCopyWithImpl<PaymentEvent>(this as PaymentEvent, _$identity);

  /// Serializes this PaymentEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.evidenceId, evidenceId) || other.evidenceId == evidenceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.extractionConfidence, extractionConfidence) || other.extractionConfidence == extractionConfidence)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,evidenceId,amount,timestamp,providerName,referenceNumber,rawText,extractionConfidence,status);

@override
String toString() {
  return 'PaymentEvent(id: $id, evidenceId: $evidenceId, amount: $amount, timestamp: $timestamp, providerName: $providerName, referenceNumber: $referenceNumber, rawText: $rawText, extractionConfidence: $extractionConfidence, status: $status)';
}


}

/// @nodoc
abstract mixin class $PaymentEventCopyWith<$Res>  {
  factory $PaymentEventCopyWith(PaymentEvent value, $Res Function(PaymentEvent) _then) = _$PaymentEventCopyWithImpl;
@useResult
$Res call({
 String id, String evidenceId, double amount, DateTime timestamp, String providerName, String referenceNumber, String rawText, double extractionConfidence, String status
});




}
/// @nodoc
class _$PaymentEventCopyWithImpl<$Res>
    implements $PaymentEventCopyWith<$Res> {
  _$PaymentEventCopyWithImpl(this._self, this._then);

  final PaymentEvent _self;
  final $Res Function(PaymentEvent) _then;

/// Create a copy of PaymentEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? evidenceId = null,Object? amount = null,Object? timestamp = null,Object? providerName = null,Object? referenceNumber = null,Object? rawText = null,Object? extractionConfidence = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,evidenceId: null == evidenceId ? _self.evidenceId : evidenceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: null == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,extractionConfidence: null == extractionConfidence ? _self.extractionConfidence : extractionConfidence // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentEvent].
extension PaymentEventPatterns on PaymentEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentEvent value)  $default,){
final _that = this;
switch (_that) {
case _PaymentEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentEvent value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String evidenceId,  double amount,  DateTime timestamp,  String providerName,  String referenceNumber,  String rawText,  double extractionConfidence,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentEvent() when $default != null:
return $default(_that.id,_that.evidenceId,_that.amount,_that.timestamp,_that.providerName,_that.referenceNumber,_that.rawText,_that.extractionConfidence,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String evidenceId,  double amount,  DateTime timestamp,  String providerName,  String referenceNumber,  String rawText,  double extractionConfidence,  String status)  $default,) {final _that = this;
switch (_that) {
case _PaymentEvent():
return $default(_that.id,_that.evidenceId,_that.amount,_that.timestamp,_that.providerName,_that.referenceNumber,_that.rawText,_that.extractionConfidence,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String evidenceId,  double amount,  DateTime timestamp,  String providerName,  String referenceNumber,  String rawText,  double extractionConfidence,  String status)?  $default,) {final _that = this;
switch (_that) {
case _PaymentEvent() when $default != null:
return $default(_that.id,_that.evidenceId,_that.amount,_that.timestamp,_that.providerName,_that.referenceNumber,_that.rawText,_that.extractionConfidence,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentEvent implements PaymentEvent {
  const _PaymentEvent({required this.id, required this.evidenceId, required this.amount, required this.timestamp, required this.providerName, required this.referenceNumber, required this.rawText, required this.extractionConfidence, this.status = 'unmatched'});
  factory _PaymentEvent.fromJson(Map<String, dynamic> json) => _$PaymentEventFromJson(json);

@override final  String id;
@override final  String evidenceId;
@override final  double amount;
@override final  DateTime timestamp;
@override final  String providerName;
@override final  String referenceNumber;
@override final  String rawText;
@override final  double extractionConfidence;
@override@JsonKey() final  String status;

/// Create a copy of PaymentEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentEventCopyWith<_PaymentEvent> get copyWith => __$PaymentEventCopyWithImpl<_PaymentEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.evidenceId, evidenceId) || other.evidenceId == evidenceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.extractionConfidence, extractionConfidence) || other.extractionConfidence == extractionConfidence)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,evidenceId,amount,timestamp,providerName,referenceNumber,rawText,extractionConfidence,status);

@override
String toString() {
  return 'PaymentEvent(id: $id, evidenceId: $evidenceId, amount: $amount, timestamp: $timestamp, providerName: $providerName, referenceNumber: $referenceNumber, rawText: $rawText, extractionConfidence: $extractionConfidence, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PaymentEventCopyWith<$Res> implements $PaymentEventCopyWith<$Res> {
  factory _$PaymentEventCopyWith(_PaymentEvent value, $Res Function(_PaymentEvent) _then) = __$PaymentEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String evidenceId, double amount, DateTime timestamp, String providerName, String referenceNumber, String rawText, double extractionConfidence, String status
});




}
/// @nodoc
class __$PaymentEventCopyWithImpl<$Res>
    implements _$PaymentEventCopyWith<$Res> {
  __$PaymentEventCopyWithImpl(this._self, this._then);

  final _PaymentEvent _self;
  final $Res Function(_PaymentEvent) _then;

/// Create a copy of PaymentEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? evidenceId = null,Object? amount = null,Object? timestamp = null,Object? providerName = null,Object? referenceNumber = null,Object? rawText = null,Object? extractionConfidence = null,Object? status = null,}) {
  return _then(_PaymentEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,evidenceId: null == evidenceId ? _self.evidenceId : evidenceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: null == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,extractionConfidence: null == extractionConfidence ? _self.extractionConfidence : extractionConfidence // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
